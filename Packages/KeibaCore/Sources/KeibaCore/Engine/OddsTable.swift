import Foundation

/// 事前生成された固定オッズ（仕様15, 仕様追補 v1.0.1）。値は0.1倍単位の整数。
public struct OddsTable: Sendable {
    private let entries: [BetType: [String: Int]]

    public init(entries: [BetType: [String: Int]]) {
        self.entries = entries
    }

    public func tenths(for selection: BetSelection) -> Int? {
        entries[selection.type]?[selection.key]
    }

    public func count(for type: BetType) -> Int {
        entries[type]?.count ?? 0
    }
}
