import Foundation

/// 騎手（仕様8）。能力はレース結果に影響しない。視覚的差別化専用。
public struct Jockey: Sendable, Equatable {
    public let name: String
    public let silkPrimaryHex: String
    public let silkSecondaryHex: String
    public let capHex: String
}
