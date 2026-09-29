import Foundation

public struct BetResultLine: Sendable, Equatable {
    public let bet: Bet
    public let oddsTenths: Int
    public let isHit: Bool
    public let payout: Int
}

public struct Settlement: Sendable, Equatable {
    public let lines: [BetResultLine]
    public var totalStake: Int { lines.reduce(0) { $0 + $1.bet.amount } }
    public var totalPayout: Int { lines.reduce(0) { $0 + $1.payout } }
    public var net: Int { totalPayout - totalStake }
}

/// 馬券の検証・購入・的中判定・払戻（仕様12〜15, 29）
public struct BetEngine: Sendable {
    public static let unit = 100

    public let odds: OddsTable
    public let validNumbers: Set<Int>

    public init(race: Race, odds: OddsTable = .generated) {
        self.odds = odds
        self.validNumbers = Set(race.horses.map(\.number))
    }

    public func makeSelection(type: BetType, numbers: [Int]) throws -> BetSelection {
        guard numbers.count == type.selectionCount else { throw BetError.wrongSelectionCount }
        guard numbers.allSatisfy({ validNumbers.contains($0) }) else { throw BetError.unknownHorse }
        guard Set(numbers).count == numbers.count else { throw BetError.duplicateHorse }
        let normalized = type.isOrdered ? numbers : numbers.sorted()
        let selection = BetSelection(validatedType: type, numbers: normalized)
        guard odds.tenths(for: selection) != nil else { throw BetError.oddsUnavailable }
        return selection
    }

    public func validate(amount: Int, balance: Int) throws {
        guard amount > 0 else { throw BetError.amountNotPositive }
        guard amount >= Self.unit else { throw BetError.amountBelowMinimum }
        guard amount % Self.unit == 0 else { throw BetError.amountNotMultipleOfUnit }
        guard amount <= balance else { throw BetError.insufficientBalance }
    }

    /// 購入後の残高を返す。検証に失敗した場合は何も変えずに throw する。
    public func purchase(selection: BetSelection, amount: Int, balance: Int) throws -> (bet: Bet, newBalance: Int) {
        try validate(amount: amount, balance: balance)
        return (Bet(selection: selection, amount: amount), balance - amount)
    }

    public func isHit(_ selection: BetSelection, finishOrder: [Int]) -> Bool {
        guard finishOrder.count >= 3 else { return false }
        let top1 = finishOrder[0]
        let top2 = Array(finishOrder.prefix(2))
        let top3 = Array(finishOrder.prefix(3))
        let picked = selection.numbers
        switch selection.type {
        case .win: return picked == [top1]
        case .place: return picked.allSatisfy { top3.contains($0) }
        case .quinella: return Set(picked) == Set(top2)
        case .wide: return picked.allSatisfy { top3.contains($0) }
        case .exacta: return picked == top2
        case .trio: return Set(picked) == Set(top3)
        case .trifecta: return picked == top3
        }
    }

    /// 払戻 = 購入額 × オッズ。購入額が100pt単位・オッズが0.1倍単位なので常に整数（10pt単位）。
    public func payout(for bet: Bet, finishOrder: [Int]) -> Int {
        guard isHit(bet.selection, finishOrder: finishOrder),
              let tenths = odds.tenths(for: bet.selection) else { return 0 }
        return bet.amount * tenths / 10
    }

    public func settle(bets: [Bet], finishOrder: [Int]) -> Settlement {
        Settlement(lines: bets.map { bet in
            BetResultLine(
                bet: bet,
                oddsTenths: odds.tenths(for: bet.selection) ?? 0,
                isHit: isHit(bet.selection, finishOrder: finishOrder),
                payout: payout(for: bet, finishOrder: finishOrder)
            )
        })
    }
}
