import Foundation

struct SeededGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func unit() -> Double {
        state &+= 0x9E3779B97F4A7C15
        var value = state
        value = (value ^ (value >> 30)) &* 0xBF58476D1CE4E5B9
        value = (value ^ (value >> 27)) &* 0x94D049BB133111EB
        return Double((value ^ (value >> 31)) >> 11) / 9_007_199_254_740_992
    }
}

struct RunnerState: Identifiable, Equatable {
    let id: Int
    var raceProgress: Double = 0
    var velocity: Double = 0
    var finishTime: Double?
    let performance: Double
}

enum RaceEngineError: LocalizedError {
    case invalidData(String)
    var errorDescription: String? {
        switch self { case .invalidData(let message): return message }
    }
}

/// Fixed 50 ms integration makes the result independent of rendering and playback speed.
struct RaceEngine {
    let race: Race
    let seed: UInt64
    let pace: RacePace
    private(set) var elapsed: Double = 0
    private(set) var runners: [RunnerState]
    private var accumulator: Double = 0
    private static let step = 0.05

    init(race: Race, seed: UInt64) throws {
        if let error = race.validate() { throw RaceEngineError.invalidData(error) }
        guard race.distance.isFinite, race.distance > 0,
              race.horses.allSatisfy({ horse in
                  let a = horse.ability
                  return [a.speed, a.stamina, a.acceleration, a.finishingKick].allSatisfy { $0.isFinite && (0...100).contains($0) }
                      && a.pacePreference.isFinite && (-1...1).contains(a.pacePreference)
                      && a.distanceAffinity.isFinite && (0.5...1.5).contains(a.distanceAffinity)
                      && a.consistency.isFinite && (0...1).contains(a.consistency)
              }) else { throw RaceEngineError.invalidData("距離または能力データを確認してください。") }
        self.race = race
        self.seed = seed
        let pressure = race.horses.reduce(0) { count, horse in
            count + (horse.style == .front ? 2 : horse.style == .forward ? 1 : 0)
        }
        pace = pressure >= 6 ? .high : pressure <= 2 ? .low : .normal
        var generator = SeededGenerator(seed: seed)
        runners = race.horses.map { horse in
            let deviation = (generator.unit() * 2 - 1) * 0.04 * (1 - horse.ability.consistency * 0.5)
            return RunnerState(id: horse.id, performance: 1 + deviation)
        }
    }

    var isFinished: Bool { runners.allSatisfy { $0.finishTime != nil } }
    var standings: [RunnerState] {
        runners.sorted { lhs, rhs in
            if let left = lhs.finishTime, let right = rhs.finishTime {
                return left == right ? lhs.id < rhs.id : left < right
            }
            if lhs.finishTime != nil { return true }
            if rhs.finishTime != nil { return false }
            return lhs.raceProgress == rhs.raceProgress ? lhs.id < rhs.id : lhs.raceProgress > rhs.raceProgress
        }
    }
    var result: RaceResult? {
        guard isFinished else { return nil }
        let finishes = standings.enumerated().compactMap { index, runner -> HorseFinish? in
            guard let time = runner.finishTime else { return nil }
            return HorseFinish(horseID: runner.id, rank: index + 1, time: time)
        }
        return RaceResult(finishes: finishes, pace: pace, seed: seed)
    }

    mutating func advance(seconds: Double) {
        guard seconds.isFinite, seconds > 0, isFinished == false else { return }
        // Ignore extreme caller intervals; real playback feeds small elapsed intervals.
        accumulator += min(seconds, 90)
        while accumulator + 0.000000001 >= Self.step && isFinished == false {
            integrate()
            accumulator = max(0, accumulator - Self.step)
        }
    }

    private mutating func integrate() {
        let late = min(1, max(0, (elapsed - 30) / 24))
        let paceFactor = pace == .high ? 1.0 : pace == .low ? -1.0 : 0.0
        for index in runners.indices {
            guard runners[index].finishTime == nil,
                  let horse = race.horses.first(where: { $0.id == runners[index].id }) else { continue }
            let a = horse.ability
            let range = horse.style.targetPosition
            let targetRank = Double(range.lowerBound + range.upperBound) / 2
            let earlySpeed = 23.8 + (paceFactor - 1) * 0.4 - (targetRank - 1) * 0.13
            let capacity = (10 + a.speed * 0.15 + a.finishingKick * 0.012)
                * horse.condition.multiplier * runners[index].performance * a.distanceAffinity
            let fatigue = (100 - a.stamina) * 0.014 * (targetRank < 5 ? 1 : 0.55)
                * max(0, (elapsed - 35) / 35) * (1 + (paceFactor - 1) * 0.2)
            let targetSpeed = earlySpeed * (1 - late)
                + (capacity + a.pacePreference * paceFactor * 0.55 - fatigue) * late
            let oldProgress = runners[index].raceProgress
            runners[index].velocity += (max(5, targetSpeed) - runners[index].velocity)
                * min(1, Self.step * (1.3 + a.acceleration / 100))
            let next = oldProgress + runners[index].velocity * Self.step
            if next >= race.distance {
                runners[index].finishTime = elapsed + (race.distance - oldProgress) / runners[index].velocity
            }
            runners[index].raceProgress = min(race.distance, next)
        }
        elapsed += Self.step
    }
}
