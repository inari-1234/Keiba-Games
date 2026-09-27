import Foundation

func require(_ condition: Bool, _ description: String) {
    if condition == false { fputs("FAIL: \(description)\n", stderr); exit(1) }
}
func run(_ seed: UInt64, interval: Double = 0.05) throws -> RaceResult {
    var engine = try RaceEngine(race: SampleRaceData.race, seed: seed)
    var previous = engine.runners
    var orders = Set<[Int]>()
    while engine.isFinished == false && engine.elapsed < 90 {
        engine.advance(seconds: interval)
        for runner in engine.runners {
            let old = previous.first { $0.id == runner.id }?.raceProgress ?? 0
            require(runner.raceProgress.isFinite && runner.raceProgress >= old, "finite monotonic progress")
            require((0.96...1.04).contains(runner.performance), "bounded variation")
        }
        previous = engine.runners
        orders.insert(engine.standings.map(\.id))
    }
    guard let result = engine.result else { fatalError("All horses must finish") }
    require((60...90).contains(engine.elapsed), "60–90 second duration")
    require(Set(result.finishes.map(\.rank)) == Set(1...10), "unique ranks")
    require(orders.count > 2, "position changes during running")
    return result
}
do {
    let fixed = try run(20260927)
    print("DEBUG order:", fixed.order)
    print("Finish times:", fixed.finishes.map { $0.time })
    require(Array(fixed.order.prefix(5)) == [3,6,1,8,5], "reference seed top five")
    let repeated = try run(20260927)
    let batched = try run(20260927, interval: 0.1)
    require(fixed == repeated && fixed == batched, "determinism and 2x playback")
    var uniqueOrders = Set<[Int]>()
    for seed in UInt64(0)..<100 { uniqueOrders.insert(try run(seed).order) }
    require(uniqueOrders.count > 1, "different seeds vary outcomes")
    print("PASS: race integration checks; distinct orders:", uniqueOrders.count)
} catch { fputs("FAIL: \(error)\n", stderr); exit(1) }
