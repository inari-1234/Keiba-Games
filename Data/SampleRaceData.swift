import Foundation

enum SampleRaceData {
    static let race = Race(name: "第1回 さくらステークス", grade: "GIII", distance: 1600,
                           direction: "左回り", surface: "芝", going: "良", startTime: "15:40", horses: horses)
    static let tipsters = [
        Tipster(id: "hinata", name: "桜井ひなた", style: "安定型", picks: [3, 6, 1],
                comment: "安定感が抜群で軸に最適です。先行力もあり、今回のメンバーならしっかり粘り込めると思います。"),
        Tipster(id: "ren", name: "黒川レン", style: "末脚重視", picks: [6, 1, 9],
                comment: "前走の内容が秀逸。今回は展開が向きそうで、差し切りに期待します。")
    ]
    static let horses: [Horse] = [
        make(1, 1, "ハルノキセキ", "佐藤", 3, 58, .forward, .up, [2,1,3,1], "前走惜敗も内容良し。今回も上位争い。", 0xC9BA9E, 0xEAEFF5, 85, 86, 84, 84),
        make(2, 2, "ミルキースカイ", "松山", 6, 124, .closer, .normal, [5,2,1,3], "末脚確か。展開次第で突き抜けも。", 0xE9D9C1, 0xB286D4, 78, 79, 83, 87),
        make(3, 3, "サクラノハナ", "川田", 1, 28, .forward, .up, [1,1,2,1], "安定感抜群。ここも中心視。", 0x9C5A32, 0xF58EA8, 93, 94, 90, 90),
        make(4, 4, "コスモドリーム", "横山武", 8, 246, .deepCloser, .normal, [6,3,4,2], "末脚は確か。流れが向けば一発。", 0x785041, 0x38B7A5, 73, 75, 77, 84),
        make(5, 5, "メイショウハピネス", "浜中", 5, 101, .forward, .up, [3,1,5,2], "芝替わりで前進。粘り込み注意。", 0xAE713C, 0xF6C84C, 81, 82, 80, 78),
        make(6, 6, "ラブリーショコラ", "ルメール", 2, 41, .closer, .up, [1,2,1,2], "前走強い内容。上位争い濃厚。", 0x885031, 0x278DDF, 89, 89, 93, 96),
        make(7, 7, "テンノオトメ", "戸崎", 9, 367, .front, .down, [7,6,3,5], "ハナに行ければしぶとい。", 0x80472F, 0xF05C5C, 76, 64, 89, 65),
        make(8, 7, "スターライト", "岩田望", 4, 89, .closer, .normal, [2,4,2,1], "近走安定。末脚切れ味あり。", 0xC6905F, 0xF4A8C5, 84, 83, 88, 90),
        make(9, 8, "ニシノフラワー", "武豊", 7, 183, .deepCloser, .up, [4,3,6,2], "展開がハマれば一気に差し込む。", 0x745341, 0xEEE8DC, 74, 77, 81, 87),
        make(10, 8, "アオゾラチャーム", "横山和", 10, 521, .forward, .normal, [8,7,5,4], "まだ良化途上。今回は様子見。", 0xD4C7B2, 0xEFAB4B, 64, 66, 65, 64)
    ]
    private static func make(_ id: Int, _ frame: Int, _ name: String, _ jockey: String, _ popularity: Int,
                             _ odds: Int, _ style: RunningStyle, _ condition: HorseCondition, _ results: [Int],
                             _ comment: String, _ coat: UInt32, _ silk: UInt32,
                             _ speed: Double, _ stamina: Double, _ acceleration: Double, _ kick: Double) -> Horse {
        Horse(id: id, frame: frame, name: name, jockey: Jockey(name: jockey, silkHex: silk, capHex: silk),
              popularity: popularity, winOddsTenths: odds, style: style, condition: condition,
              recentResults: results, comment: comment, coatHex: coat,
              ability: HorseAbility(speed: speed, stamina: stamina, acceleration: acceleration,
                                    finishingKick: kick, pacePreference: style == .closer || style == .deepCloser ? 1 : -0.5,
                                    distanceAffinity: 1, consistency: popularity <= 3 ? 0.88 : 0.7))
    }
}
