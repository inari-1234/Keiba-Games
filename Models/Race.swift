import Foundation

enum RacePace: String, Codable { case low = "LOW", normal = "NORMAL", high = "HIGH" }
struct Race {
    let name: String
    let grade: String
    let distance: Double
    let direction: String
    let surface: String
    let going: String
    let startTime: String
    let horses: [Horse]
    func validate() -> String? {
        guard horses.count == 10 else { return "出走馬データは10頭必要です。" }
        guard Set(horses.map(\.id)) == Set(1...10) else { return "馬番データを確認してください。" }
        guard Set(horses.map(\.popularity)) == Set(1...10) else { return "人気データを確認してください。" }
        guard horses.allSatisfy({ $0.winOddsTenths > 10 && $0.recentResults.count == 4 }) else { return "オッズまたは前4走データを確認してください。" }
        return nil
    }
}
