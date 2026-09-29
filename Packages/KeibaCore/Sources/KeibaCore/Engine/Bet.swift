import Foundation

/// 馬券種（仕様12）
public enum BetType: String, CaseIterable, Sendable, Hashable {
    case win, place, quinella, wide, exacta, trio, trifecta

    public var label: String {
        switch self {
        case .win: return "単勝"
        case .place: return "複勝"
        case .quinella: return "馬連"
        case .wide: return "ワイド"
        case .exacta: return "馬単"
        case .trio: return "三連複"
        case .trifecta: return "三連単"
        }
    }

    /// 選ぶ頭数
    public var selectionCount: Int {
        switch self {
        case .win, .place: return 1
        case .quinella, .wide, .exacta: return 2
        case .trio, .trifecta: return 3
        }
    }

    /// 着順の並びを区別するか
    public var isOrdered: Bool {
        switch self {
        case .exacta, .trifecta: return true
        default: return false
        }
    }
}

/// 検証済みの買い目。BetEngine.makeSelection 以外からは作れない。
public struct BetSelection: Hashable, Sendable {
    public let type: BetType
    /// 順序なし券種は昇順に正規化済み
    public let numbers: [Int]

    init(validatedType: BetType, numbers: [Int]) {
        self.type = validatedType
        self.numbers = numbers
    }

    public var key: String { numbers.map(String.init).joined(separator: "-") }

    public var displayText: String {
        numbers.map(String.init).joined(separator: type.isOrdered ? "→" : "-")
    }
}

public struct Bet: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let selection: BetSelection
    public let amount: Int

    public init(id: UUID = UUID(), selection: BetSelection, amount: Int) {
        self.id = id
        self.selection = selection
        self.amount = amount
    }
}

public enum BetError: Error, Equatable {
    case wrongSelectionCount
    case unknownHorse
    case duplicateHorse
    case amountNotPositive
    case amountBelowMinimum
    case amountNotMultipleOfUnit
    case insufficientBalance
    case oddsUnavailable
}
