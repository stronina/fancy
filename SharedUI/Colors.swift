import SwiftUI

extension Color {
    /// Акцент и кнопки
    static let accentColor       = Color(hex: "#F1DDBF")
    /// Основной фон
    static let backgroundColor   = Color(hex: "#525E75")
    /// Цвет кнопок в HubView после прохождения уровня
    static let completedLevel    = Color(hex: "#78938A")
    /// Дополнительный цвет (правильный ответ, экран победы)
    static let successColor      = Color(hex: "#92BA92")

    /// Инициализатор из HEX-строки
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

