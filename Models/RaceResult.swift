import Foundation

struct HorseFinish: Identifiable, Equatable {
    let horseID: Int
    let rank: Int
    let time: Double
    var id: Int { horseID }
}
struct RaceResult: Equatable {
    let finishes: [HorseFinish]
    let pace: RacePace
    let seed: UInt64
    var order: [Int] { finishes.sorted { $0.rank < $1.rank }.map(\.horseID) }
}
