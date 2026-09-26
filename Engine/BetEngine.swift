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
}
