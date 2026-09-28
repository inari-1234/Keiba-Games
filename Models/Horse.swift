import Foundation

enum RunningStyle: String, CaseIterable, Codable {
    case front = "逃げ", forward = "先行", closer = "差し", deepCloser = "追込"
    var targetPosition: ClosedRange<Int> {
        switch self {
        case .front: return 1...2
        case .forward: return 2...5
        case .closer: return 4...8
        case .deepCloser: return 7...10
        }
    }
}
enum HorseCondition: String, Codable {
    case up = "↑", normal = "→", down = "↓"
    var multiplier: Double {
        switch self { case .up: return 1.04; case .normal: return 1; case .down: return 0.96 }
    }
}
struct HorseAbility: Codable, Equatable {
    let speed: Double
    let stamina: Double
    let acceleration: Double
    let finishingKick: Double
    let pacePreference: Double
    let distanceAffinity: Double
    let consistency: Double
}
struct Horse: Identifiable, Codable, Equatable {
    let id: Int
    let frame: Int
    let name: String
    let jockey: Jockey
    let popularity: Int
    let winOddsTenths: Int
    let style: RunningStyle
    let condition: HorseCondition
    let recentResults: [Int]
    let comment: String
    let coatHex: UInt32
    let ability: HorseAbility
    var winOdds: Double { Double(winOddsTenths) / 10 }
}
