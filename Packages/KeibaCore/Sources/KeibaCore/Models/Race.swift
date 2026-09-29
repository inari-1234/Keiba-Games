import Foundation

public enum Pace: Int, Sendable {
    case low = 0, normal = 1, high = 2

    public var label: String {
        switch self {
        case .low: return "スロー"
        case .normal: return "平均"
        case .high: return "ハイ"
        }
    }
}

public struct Race: Sendable, Equatable {
    public let name: String
    public let grade: String
    public let surface: String
    public let distance: Int
    public let direction: String
    public let going: String
    public let postTime: String
    public let horses: [Horse]
    /// レース固有値。乱数シードと合成して使う（仕様追補 v1.0.1）。
    public let salt: UInt64

    public static let requiredFieldSize = 10

    public var distanceText: String { "\(surface)\(distance)m" }

    public func horse(number: Int) -> Horse? {
        horses.first { $0.number == number }
    }
}
