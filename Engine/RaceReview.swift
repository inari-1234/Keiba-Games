import Foundation

struct RaceReview {
    let race: Race
    let result: RaceResult
    var topHorses: [Horse] {
        result.order.prefix(3).compactMap { id in race.horses.first { $0.id == id } }
    }
    var summary: String {
        let paceText: String
        switch result.pace {
        case .high: paceText = "ハイペースの展開となりました。"
        case .normal: paceText = "平均的なペースで進みました。"
        case .low: paceText = "落ち着いたペースの展開となりました。"
        }
        let finishText = topHorses.enumerated().map { index, horse in
            switch index {
            case 0:
                switch horse.style {
                case .front: return "逃げた\(horse.name)が、最後まで粘り切りました。"
                case .forward: return "先行馬の\(horse.name)が好位から抜け出し、そのまま押し切りました。"
                case .closer: return "\(horse.name)が中団から鋭く伸びて、差し切りました。"
                case .deepCloser: return "\(horse.name)が後方から末脚を伸ばし、追い込みを決めました。"
                }
            case 1:
                if horse.style == .closer || horse.style == .deepCloser {
                    return "\(horse.name)は\(horse.id <= 3 ? "内" : "外")から鋭く伸びて2着。"
                }
                return "\(horse.name)は前でしぶとく粘って2着。"
            default:
                return "\(horse.name)も\(horse.id <= 3 ? "内" : "外")から伸びて3着に入りました。"
            }
        }.joined()
        return paceText + finishText
    }
    func point(horse: Horse, rank: Int) -> String {
        if rank == 1 {
            switch horse.style {
            case .front: return "先手を奪って最後まで粘り切りました。"
            case .forward: return "好位から抜け出す完璧なレース。安定感の高さを見せました。"
            case .closer: return "中団から鋭く伸び、差し切りを決めました。"
            case .deepCloser: return "後方から力強く追い込み、勝利をつかみました。"
            }
        }
        if rank == 2 {
            if horse.style == .closer || horse.style == .deepCloser {
                return "\(horse.id <= 3 ? "内" : "外")から鋭く伸びて2着。\(result.pace == .high ? "展開も向きました。" : "末脚を見せました。")"
            }
            return "前で粘って2着。最後までしぶとく走りました。"
        }
        return "最後までよく伸びて3着。もう一押しでした。"
    }
}
