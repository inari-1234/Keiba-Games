import Foundation

public enum RaceEngineError: Error, Equatable {
    case invalidFieldSize(Int)
    case duplicateNumbers
}

/// レース1回分のシミュレーション結果。描画はこの値を再生するだけ。
public struct RaceSimulation: Sendable {
    public let seed: UInt64
    public let pace: Pace
    /// 馬番（出走表の並び順）。frames の列インデックスと対応する。
    public let horseNumbers: [Int]
    /// 着順（馬番の配列）。raceProgress（到達時刻）で判定する。
    public let finishOrder: [Int]
    /// 馬番 -> ゴール到達時刻（秒）
    public let finishTimes: [Int: Double]
    /// フレームごとの raceProgress（0 = スタート, 1 = ゴール）。1を超えてもゴール後の流しとして扱う。
    public let frames: [[Double]]
    public let tickInterval: Double

    public var duration: Double { Double(max(frames.count - 1, 0)) * tickInterval }

    public func position(of number: Int, inFinishOrder order: [Int]) -> Int? {
        order.firstIndex(of: number).map { $0 + 1 }
    }
}

/// 仕様20〜27のレースロジック。完全ランダムではなく、内部能力値・脚質・ペース・調子・小さな乱数（最大±4%）で決まる。
///
/// 注意: 演算の順序は tools/prototype/engine.py と一致させている（固定シードの着順を保証するため）。
/// 数式を変える場合はプロトタイプで再校正し、SampleRaceData の speed と Race.salt を更新すること。
public enum RaceEngine {
    static let baseSpeed = 21.0
    static let tick = 0.25
    static let segments = 16
    static let maxSteps = 2000
    static let styleEarly: [Double] = [1.03, 1.015, 0.99, 0.975]
    static let paceBoost: [Double] = [0.02, 0.04, 0.06]
    static let paceFade: [Double] = [0.03, 0.05, 0.08]

    public static let debugSeed: UInt64 = 20_260_927

    /// 逃げ馬・先行馬の数からペースを決定（仕様22）
    public static func pace(for horses: [Horse]) -> Pace {
        var score = 0
        for horse in horses {
            switch horse.style {
            case .frontRunner: score = score + 2
            case .stalker: score = score + 1
            case .closer, .deepCloser: break
            }
        }
        if score >= 6 { return .high }
        if score >= 3 { return .normal }
        return .low
    }

    public static func simulate(race: Race, seed: UInt64, recordFrames: Bool = true) throws -> RaceSimulation {
        let horses = race.horses.sorted { $0.number < $1.number }
        guard horses.count == Race.requiredFieldSize else {
            throw RaceEngineError.invalidFieldSize(horses.count)
        }
        guard Set(horses.map(\.number)).count == horses.count else {
            throw RaceEngineError.duplicateNumbers
        }

        let n = horses.count
        let fieldPace = Self.pace(for: horses)
        let paceIndex = fieldPace.rawValue
        var rng = SplitMix64(seed: seed ^ (race.salt &* 0x9E37_79B9_7F4A_7C15))

        // レース全体の出来（最大 ±4% のうち 60%）
        var amplitude = [Double](repeating: 0, count: n)
        var raceFactor = [Double](repeating: 1, count: n)
        for i in 0..<n {
            let a = 0.04 * (1.0 - 0.5 * horses[i].ability.consistency)
            amplitude[i] = a
            let u = rng.nextDouble()
            raceFactor[i] = 1.0 + a * 0.6 * (2.0 * u - 1.0)
        }
        // 100mごとの揺らぎ（残り 40%）
        var wobble = [[Double]](repeating: [Double](repeating: 0, count: n), count: segments)
        for seg in 0..<segments {
            for i in 0..<n {
                let u = rng.nextDouble()
                wobble[seg][i] = amplitude[i] * 0.4 * (2.0 * u - 1.0)
            }
        }

        var base = [Double](repeating: 0, count: n)
        for i in 0..<n {
            let ab = horses[i].ability
            let paceMatch = 1.0 - 0.01 * Double(abs(ab.pacePreference - paceIndex))
            base[i] = baseSpeed * ab.speed * horses[i].condition.multiplier * ab.distanceAffinity * paceMatch * raceFactor[i]
        }

        let distance = Double(race.distance)
        var x = [Double](repeating: 0, count: n)
        var finish = [Double](repeating: -1, count: n)
        var t = 0.0
        var remaining = n
        var steps = 0
        var frames: [[Double]] = recordFrames ? [[Double](repeating: 0, count: n)] : []

        while remaining > 0 && steps < maxSteps {
            for i in 0..<n {
                let h = horses[i]
                var p = x[i] / distance
                if p >= 1.0 { p = 0.9999 }
                let seg = min(max(Int(p * 16.0), 0), segments - 1)
                let se = styleEarly[h.style.rawValue]
                let phase: Double
                if p < 0.55 {
                    phase = se
                } else {
                    let q = (p - 0.55) / 0.45
                    phase = se + q * (2.0 * (1.0 - se)) + q * (h.ability.finishingKick * paceBoost[paceIndex] - (1.0 - h.ability.stamina) * paceFade[paceIndex])
                }
                var ramp = 0.35 + t * h.ability.acceleration
                if ramp > 1.0 { ramp = 1.0 }
                var v = base[i] * (1.0 + wobble[seg][i]) * phase * ramp
                if v < 1.0 { v = 1.0 }
                let nx = x[i] + v * tick
                if finish[i] < 0.0 && nx >= distance {
                    finish[i] = t + (distance - x[i]) / v
                    remaining = remaining - 1
                }
                x[i] = nx
            }
            t = t + tick
            steps = steps + 1
            if recordFrames {
                frames.append(x.map { $0 / distance })
            }
        }

        // 万一ゴールしない馬がいても落とさず最後尾扱いにする
        for i in 0..<n where finish[i] < 0.0 {
            finish[i] = t + Double(i)
        }

        let order = (0..<n).sorted { a, b in
            finish[a] != finish[b] ? finish[a] < finish[b] : a < b
        }
        var times: [Int: Double] = [:]
        for i in 0..<n { times[horses[i].number] = finish[i] }

        return RaceSimulation(
            seed: seed, pace: fieldPace,
            horseNumbers: horses.map(\.number),
            finishOrder: order.map { horses[$0].number },
            finishTimes: times, frames: frames, tickInterval: tick
        )
    }
}
