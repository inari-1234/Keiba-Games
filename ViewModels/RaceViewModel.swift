import SwiftUI

enum RacePhase { case betting, racing, finished }

@MainActor
final class RaceViewModel: ObservableObject {
    let race: Race
    @Published private(set) var bets: [Bet] = []
    @Published private(set) var balance: Int
    @Published private(set) var phase: RacePhase = .betting
    @Published var message: String?
    @Published private(set) var engine: RaceEngine?
    @Published private(set) var result: RaceResult?
    @Published var playbackSpeed: Double = 1
    func start(seed: UInt64? = nil) {
        guard phase == .betting else { return }
        #if DEBUG
        let selectedSeed = seed ?? 20260927
        #else
        let selectedSeed = seed ?? UInt64.random(in: UInt64.min...UInt64.max)
        #endif
        do {
            engine = try RaceEngine(race: race, seed: selectedSeed)
            phase = .racing
            message = nil
        } catch { message = error.localizedDescription }
    }
    func tick(seconds: Double) {
        guard phase == .racing, var current = engine else { return }
        current.advance(seconds: seconds * playbackSpeed)
        engine = current
        if let finished = current.result {
            result = finished
            phase = .finished
        }
    }
    var commentary: String {
        guard let current = engine else { return "まもなく発走です。" }
        let leader = current.standings.first.flatMap { runner in race.horses.first { $0.id == runner.id } }?.name ?? "先頭の馬"
        if current.isFinished { return "全馬ゴール！着順が確定しました。" }
        if current.elapsed < 5 { return "さあ、スタート！10頭が一斉に飛び出しました。" }
        if current.elapsed < 30 { return "\(leader)が先頭。\(current.pace == .high ? "速い流れで進みます。" : "隊列が落ち着いてきました。")" }
        if current.elapsed < 48 { return "勝負はここから。後続も差を詰めてきます！" }
        return "さあ、最後の直線！\(leader)が先頭だ！"
    }
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
