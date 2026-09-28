import Foundation

enum BetKind: String, CaseIterable, Identifiable, Codable {
    case win = "単勝", place = "複勝", quinella = "馬連", wide = "ワイド"
    case exacta = "馬単", trio = "三連複", trifecta = "三連単"
    var id: String { rawValue }
    var selectionCount: Int {
        switch self { case .win, .place: return 1; case .quinella, .wide, .exacta: return 2; case .trio, .trifecta: return 3 }
    }
    var ordered: Bool { self == .exacta || self == .trifecta }
}
struct Bet: Identifiable, Equatable {
    let id: UUID
    let kind: BetKind
    let numbers: [Int]
    let stake: Int
    let oddsTenths: Int
    var selectionText: String { numbers.map(String.init).joined(separator: kind.ordered ? " → " : " − ") }
}
struct BetSettlement: Identifiable, Equatable {
    let bet: Bet
    let payout: Int
    var id: UUID { bet.id }
    var hit: Bool { payout > 0 }
}
