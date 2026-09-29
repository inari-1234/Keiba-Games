import Foundation

/// 脚質
public enum RunningStyle: Int, CaseIterable, Sendable {
    case frontRunner = 0   // 逃げ
    case stalker = 1       // 先行
    case closer = 2        // 差し
    case deepCloser = 3    // 追込

    public var label: String {
        switch self {
        case .frontRunner: return "逃げ"
        case .stalker: return "先行"
        case .closer: return "差し"
        case .deepCloser: return "追込"
        }
    }

    /// 仕様21: レース前半の目標位置（番手）
    public var targetPositions: ClosedRange<Int> {
        switch self {
        case .frontRunner: return 1...2
        case .stalker: return 2...5
        case .closer: return 4...8
        case .deepCloser: return 7...10
        }
    }
}

/// 調子（仕様23）
public enum Condition: Int, CaseIterable, Sendable {
    case up = 0, flat = 1, down = 2

    public var arrow: String {
        switch self {
        case .up: return "↑"
        case .flat: return "→"
        case .down: return "↓"
        }
    }

    public var multiplier: Double {
        switch self {
        case .up: return 1.04
        case .flat: return 1.00
        case .down: return 0.96
        }
    }
}

/// 内部能力値（仕様20）。画面には表示しない。
public struct HorseAbility: Sendable, Equatable {
    public let speed: Double
    public let stamina: Double
    public let acceleration: Double
    public let finishingKick: Double
    /// 0 = LOW, 1 = NORMAL, 2 = HIGH
    public let pacePreference: Int
    public let distanceAffinity: Double
    /// 0...1。大きいほど乱数の振れ幅が小さい。
    public let consistency: Double
}

public struct Horse: Identifiable, Sendable, Equatable {
    public var id: Int { number }
    public let number: Int
    public let name: String
    public let jockey: Jockey
    public let popularity: Int
    /// 単勝オッズ（0.1倍単位の整数。58 = 5.8倍）
    public let winOddsTenths: Int
    public let style: RunningStyle
    public let condition: Condition
    /// 前4走の着順
    public let recentFinishes: [Int]
    public let shortComment: String
    public let paddockComment: String
    public let coatColorHex: String
    public let maneColorHex: String
    public let ability: HorseAbility

    public var winOddsText: String { OddsFormat.text(tenths: winOddsTenths) }
    public var recentFinishesText: String { recentFinishes.map(String.init).joined(separator: "-") }
}

public enum OddsFormat {
    /// 58 -> "5.8"
    public static func text(tenths: Int) -> String {
        "\(tenths / 10).\(tenths % 10)"
    }
}
