import Foundation

enum BetError: LocalizedError, Equatable {
    case amount, selection, insufficientBalance, unavailable, closed
    var errorDescription: String? {
        switch self {
        case .amount: return "購入額は100pt以上、100pt単位で指定してください。"
        case .selection: return "必要な頭数を、重複しない馬番で選んでください。"
        case .insufficientBalance: return "所持ポイントが足りません。"
        case .unavailable: return "この買い目のオッズを取得できません。"
        case .closed: return "このレースの購入受付は終了しました。"
        }
    }
}
struct BetEngine {
    static func numbers(_ numbers: [Int], kind: BetKind) -> [Int] { kind.ordered ? numbers : numbers.sorted() }
    static func odds(kind: BetKind, numbers selected: [Int]) -> Int? {
        let ns = numbers(selected, kind: kind)
        return FixedOdds.values[kind.rawValue + ":" + ns.map(String.init).joined(separator: ",")]
    }
    static func purchase(kind: BetKind, numbers: [Int], stake: Int, balance: Int, horseIDs: Set<Int>) throws -> Bet {
        guard stake >= 100, stake % 100 == 0 else { throw BetError.amount }
        guard stake <= balance else { throw BetError.insufficientBalance }
        guard numbers.count == kind.selectionCount, Set(numbers).count == numbers.count,
              Set(numbers).isSubset(of: horseIDs) else { throw BetError.selection }
        guard let odds = odds(kind: kind, numbers: numbers), odds > 10 else { throw BetError.unavailable }
        // Check payout representability before any balance mutation.
        guard stake <= Int.max / odds else { throw BetError.amount }
        return Bet(id: UUID(), kind: kind, numbers: self.numbers(numbers, kind: kind), stake: stake, oddsTenths: odds)
    }
    static func settle(_ bet: Bet, result: RaceResult) -> BetSettlement {
        let order = result.order
        guard order.count == 10, Set(order).count == 10,
              bet.numbers.count == bet.kind.selectionCount,
              Set(bet.numbers).count == bet.numbers.count,
              bet.stake >= 100, bet.stake % 100 == 0, bet.oddsTenths > 10,
              bet.stake <= Int.max / bet.oddsTenths else {
            return BetSettlement(bet: bet, payout: 0)
        }
        let selected = Set(bet.numbers)
        let hit: Bool
        switch bet.kind {
        case .win: hit = bet.numbers.first == order.first
        case .place: hit = selected.isSubset(of: Set(order.prefix(3)))
        case .quinella: hit = selected == Set(order.prefix(2))
        case .wide: hit = selected.isSubset(of: Set(order.prefix(3)))
        case .exacta: hit = bet.numbers == Array(order.prefix(2))
        case .trio: hit = selected == Set(order.prefix(3))
        case .trifecta: hit = bet.numbers == Array(order.prefix(3))
        }
        return BetSettlement(bet: bet, payout: hit ? bet.stake * bet.oddsTenths / 10 : 0)
    }

}
