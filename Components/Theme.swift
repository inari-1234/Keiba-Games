import SwiftUI

enum RaceTheme {
    static let navy = Color(hex: 0x20344F)
    static let background = Color(hex: 0xF4F6F9)
    static let blue = Color(hex: 0x24A8E0)
    static let pink = Color(hex: 0xF58EA8)
    static let green = Color(hex: 0x45B649)
}
extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 255) / 255, green: Double((hex >> 8) & 255) / 255, blue: Double(hex & 255) / 255)
    }
}
struct RaceCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        content.padding(14).frame(maxWidth: .infinity, alignment: .leading)
            .background(.white, in: RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.08), radius: 5, y: 2)
    }
}
struct NumberBadge: View {
    let horse: Horse
    var body: some View {
        Text(String(horse.id)).font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(horse.frame == 1 || horse.frame == 5 ? Color.black : Color.white)
            .frame(width: 29, height: 29)
            .background(color, in: RoundedRectangle(cornerRadius: 7))
            .overlay(RoundedRectangle(cornerRadius: 7).stroke(.black.opacity(0.1)))
            .accessibilityLabel("馬番\(horse.id)、\(horse.frame)枠")
    }
    private var color: Color {
        switch horse.frame {
        case 1: return .white
        case 2: return Color(hex: 0x343D4B)
        case 3: return Color(hex: 0xF05C5C)
        case 4: return Color(hex: 0x24A8E0)
        case 5: return Color(hex: 0xF6C84C)
        case 6: return RaceTheme.green
        case 7: return .orange
        default: return RaceTheme.pink
        }
    }
}
struct ConditionArrow: View {
    let condition: HorseCondition
    var body: some View {
        Text(condition.rawValue).font(.title3.bold())
            .foregroundStyle(condition == .up ? Color(hex: 0xF05C5C) : condition == .down ? RaceTheme.blue : .secondary)
            .accessibilityLabel("調子 \(condition.rawValue)")
    }
}
