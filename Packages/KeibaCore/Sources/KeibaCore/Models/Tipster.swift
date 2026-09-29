import Foundation

public enum TipMark: String, Sendable {
    case honmei = "◎", taikou = "○", tanana = "▲"
}

public struct TipPick: Sendable, Equatable {
    public let mark: TipMark
    public let horseNumber: Int
}

/// 予想家（仕様10, 11）。印はレース結果に一切影響しない。
public struct Tipster: Identifiable, Sendable, Equatable {
    public var id: String { name }
    public let name: String
    public let styleLabel: String
    public let picks: [TipPick]
    public let comment: String
    public let themeHex: String
}
