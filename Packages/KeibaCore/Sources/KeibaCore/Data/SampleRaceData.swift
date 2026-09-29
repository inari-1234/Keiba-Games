import Foundation

/// 第1版の固定レースデータ（仕様4〜10）。
/// 能力値 speed は tools/prototype で「勝率 ≒ 単勝オッズの示す確率」になるよう校正済み。
public enum SampleRaceData {
    public static let initialBalance = 12_300

    public static let race = Race(
        name: "第1回 さくらステークス",
        grade: "GIII",
        surface: "芝",
        distance: 1600,
        direction: "左回り",
        going: "良",
        postTime: "15:40",
        horses: horses,
        salt: 2029
    )

    public static let horses: [Horse] = [
        make(1, "ハルノキセキ", Jockey(name: "佐藤", silkPrimaryHex: "#F6C84C", silkSecondaryHex: "#20344F", capHex: "#FFFFFF"),
             pop: 3, odds: 58, .stalker, .up, [2, 1, 3, 1],
             "前走惜敗も内容良し。今回も上位争い。", "落ち着いた周回。気配上々。",
             coat: "#A0673A", mane: "#3B2415",
             HorseAbility(speed: 0.9752, stamina: 0.82, acceleration: 0.32, finishingKick: 0.55, pacePreference: 1, distanceAffinity: 1.00, consistency: 0.80)),
        make(2, "ミルキースカイ", Jockey(name: "松山", silkPrimaryHex: "#8FD3F4", silkSecondaryHex: "#FFFFFF", capHex: "#1C1C1C"),
             pop: 6, odds: 124, .closer, .flat, [5, 2, 1, 3],
             "末脚確か。展開次第で突き抜けも。", "ゆったり歩いてリラックス。",
             coat: "#C9C3BC", mane: "#8C8680",
             HorseAbility(speed: 1.0118, stamina: 0.75, acceleration: 0.30, finishingKick: 0.80, pacePreference: 2, distanceAffinity: 1.00, consistency: 0.60)),
        make(3, "サクラノハナ", Jockey(name: "川田", silkPrimaryHex: "#F58EA8", silkSecondaryHex: "#FFFFFF", capHex: "#F05C5C"),
             pop: 1, odds: 28, .stalker, .up, [1, 1, 2, 1],
             "安定感抜群。ここも中心視。", "毛ヅヤ抜群。貫禄の周回。",
             coat: "#8A4B2A", mane: "#2E1A10",
             HorseAbility(speed: 0.9673, stamina: 0.88, acceleration: 0.34, finishingKick: 0.60, pacePreference: 1, distanceAffinity: 1.01, consistency: 0.90)),
        make(4, "コスモドリーム", Jockey(name: "横山武", silkPrimaryHex: "#24A8E0", silkSecondaryHex: "#20344F", capHex: "#24A8E0"),
             pop: 8, odds: 246, .deepCloser, .flat, [6, 3, 4, 2],
             "末脚は確か。流れが向けば一発。", "マイペースに周回中。",
             coat: "#2B2B33", mane: "#111114",
             HorseAbility(speed: 1.0279, stamina: 0.70, acceleration: 0.28, finishingKick: 0.90, pacePreference: 2, distanceAffinity: 0.99, consistency: 0.50)),
        make(5, "メイショウハピネス", Jockey(name: "浜中", silkPrimaryHex: "#F6C84C", silkSecondaryHex: "#F05C5C", capHex: "#F6C84C"),
             pop: 5, odds: 101, .stalker, .up, [3, 1, 5, 2],
             "芝替わりで前進。粘り込み注意。", "踏み込み力強く好気配。",
             coat: "#B5773F", mane: "#5A3418",
             HorseAbility(speed: 0.9732, stamina: 0.78, acceleration: 0.33, finishingKick: 0.50, pacePreference: 1, distanceAffinity: 1.00, consistency: 0.70)),
        make(6, "ラブリーショコラ", Jockey(name: "ルメール", silkPrimaryHex: "#45B649", silkSecondaryHex: "#FFFFFF", capHex: "#45B649"),
             pop: 2, odds: 41, .closer, .up, [1, 2, 1, 2],
             "前走強い内容。上位争い濃厚。", "軽やかな足取り。気合十分。",
             coat: "#5C3A22", mane: "#24160C",
             HorseAbility(speed: 0.9671, stamina: 0.85, acceleration: 0.31, finishingKick: 0.85, pacePreference: 2, distanceAffinity: 1.01, consistency: 0.85)),
        make(7, "テンノオトメ", Jockey(name: "戸崎", silkPrimaryHex: "#F39A3D", silkSecondaryHex: "#20344F", capHex: "#F39A3D"),
             pop: 9, odds: 367, .frontRunner, .down, [7, 6, 3, 5],
             "ハナに行ければしぶとい。", "少しイレ込み気味。",
             coat: "#D9D4CE", mane: "#A9A39C",
             HorseAbility(speed: 1.0649, stamina: 0.65, acceleration: 0.36, finishingKick: 0.35, pacePreference: 0, distanceAffinity: 0.99, consistency: 0.50)),
        make(8, "スターライト", Jockey(name: "岩田望", silkPrimaryHex: "#F58EA8", silkSecondaryHex: "#20344F", capHex: "#F58EA8"),
             pop: 4, odds: 89, .closer, .flat, [2, 4, 2, 1],
             "近走安定。末脚切れ味あり。", "いつも通りの落ち着き。",
             coat: "#9E5A30", mane: "#4A2A15",
             HorseAbility(speed: 1.0143, stamina: 0.80, acceleration: 0.30, finishingKick: 0.75, pacePreference: 2, distanceAffinity: 1.00, consistency: 0.80)),
        make(9, "ニシノフラワー", Jockey(name: "武豊", silkPrimaryHex: "#FFFFFF", silkSecondaryHex: "#F05C5C", capHex: "#F6C84C"),
             pop: 7, odds: 183, .deepCloser, .up, [4, 3, 6, 2],
             "展開がハマれば一気に差し込む。", "尻尾をふって上機嫌。",
             coat: "#C1824A", mane: "#6B3F1D",
             HorseAbility(speed: 0.9794, stamina: 0.72, acceleration: 0.29, finishingKick: 0.88, pacePreference: 2, distanceAffinity: 1.00, consistency: 0.55)),
        make(10, "アオゾラチャーム", Jockey(name: "横山和", silkPrimaryHex: "#24A8E0", silkSecondaryHex: "#FFFFFF", capHex: "#FFFFFF"),
             pop: 10, odds: 521, .stalker, .flat, [8, 7, 5, 4],
             "まだ良化途上。今回は様子見。", "のんびり周回。まだこれから。",
             coat: "#6E4A33", mane: "#2F1E12",
             HorseAbility(speed: 1.0190, stamina: 0.70, acceleration: 0.32, finishingKick: 0.45, pacePreference: 1, distanceAffinity: 0.99, consistency: 0.60)),
    ]

    public static let tipsters: [Tipster] = [
        Tipster(
            name: "桜井ひなた", styleLabel: "安定型",
            picks: [TipPick(mark: .honmei, horseNumber: 3), TipPick(mark: .taikou, horseNumber: 6), TipPick(mark: .tanana, horseNumber: 1)],
            comment: "安定感が抜群で軸に最適です。先行力もあり、今回のメンバーならしっかり粘り込めると思います。",
            themeHex: "#F58EA8"
        ),
        Tipster(
            name: "黒川レン", styleLabel: "末脚重視",
            picks: [TipPick(mark: .honmei, horseNumber: 6), TipPick(mark: .taikou, horseNumber: 1), TipPick(mark: .tanana, horseNumber: 9)],
            comment: "前走の内容が秀逸。今回は展開が向きそうで、差し切りに期待します。",
            themeHex: "#20344F"
        ),
    ]

    private static func make(
        _ number: Int, _ name: String, _ jockey: Jockey,
        pop: Int, odds: Int, _ style: RunningStyle, _ condition: Condition, _ recent: [Int],
        _ comment: String, _ paddock: String, coat: String, mane: String, _ ability: HorseAbility
    ) -> Horse {
        Horse(number: number, name: name, jockey: jockey, popularity: pop, winOddsTenths: odds,
              style: style, condition: condition, recentFinishes: recent, shortComment: comment,
              paddockComment: paddock, coatColorHex: coat, maneColorHex: mane, ability: ability)
    }
}
