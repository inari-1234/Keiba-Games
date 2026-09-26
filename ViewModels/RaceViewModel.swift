import SwiftUI

enum RacePhase { case betting, racing, finished }

@MainActor
final class RaceViewModel: ObservableObject {
    let race: Race
    @Published private(set) var bets: [Bet] = []
    @Published private(set) var balance: Int
    @Published private(set) var phase: RacePhase = .betting
    @Published var message: String?
    init(race: Race = SampleRaceData.race, balance: Int = 12300) {
        self.race = race
        self.balance = max(0, balance)
    }
    var totalStake: Int { bets.reduce(0) { $0 + $1.stake } }
    func purchase(kind: BetKind, numbers: [Int], stake: Int) throws {
        guard phase == .betting else { throw BetError.closed }
        let bet = try BetEngine.purchase(kind: kind, numbers: numbers, stake: stake, balance: balance, horseIDs: Set(race.horses.map(\.id)))
        balance -= bet.stake
        bets.append(bet)
    }
}
