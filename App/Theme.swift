import SwiftUI

/// 仕様33〜35の基本色・角丸
enum Theme {
    static let background = Color(hex: "#F4F6F9")
    static let header = Color(hex: "#20344F")
    static let card = Color.white
    static let blue = Color(hex: "#24A8E0")
    static let pink = Color(hex: "#F58EA8")
    static let green = Color(hex: "#45B649")
    static let red = Color(hex: "#F05C5C")
    static let yellow = Color(hex: "#F6C84C")
    static let cornerRadius: CGFloat = 14
    static let shadowOpacity = 0.10
}

extension Color {
    /// "#RRGGBB"。不正な値は灰色にフォールバック（クラッシュさせない）。
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard cleaned.count == 6, let value = UInt32(cleaned, radix: 16) else {
            self = .gray
            return
        }
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}
