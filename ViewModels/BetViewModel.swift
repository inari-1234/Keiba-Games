import SwiftUI

@MainActor
final class BetViewModel: ObservableObject {
    @Published var kind: BetKind = .win { didSet { if kind != oldValue { numbers = [] } } }
    @Published var numbers: [Int] = []
    @Published var amount = 100
    @Published var error: String?
    func select(_ id: Int) {
        if let index = numbers.firstIndex(of: id) { numbers.remove(at: index) }
        else if numbers.count < kind.selectionCount { numbers.append(id) }
    }
    func add(_ value: Int) {
        guard amount <= Int.max - value else { return }
        amount += value
    }
    var odds: Int? { BetEngine.odds(kind: kind, numbers: numbers) }
    var selectionText: String { numbers.map(String.init).joined(separator: kind.ordered ? " → " : " − ") }
    func buy(using race: RaceViewModel) {
        do { try race.purchase(kind: kind, numbers: numbers, stake: amount); error = nil }
        catch { self.error = error.localizedDescription }
    }
}
