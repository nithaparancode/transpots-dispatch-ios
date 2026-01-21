import SwiftUI
import Combine

final class AppTheme: ObservableObject {
    static let shared = AppTheme()
    
    @Published var currentTheme: ThemeMode = .light
    
    private init() {}
    
    enum ThemeMode {
        case light
        case dark
    }
}

struct Theme {
    let colors: ThemeColors
    let fonts: ThemeFonts
    let spacing: ThemeSpacing
    let radius: ThemeRadius
    
    static let light = Theme(
        colors: .light,
        fonts: .default,
        spacing: .default,
        radius: .default
    )
    
    static let dark = Theme(
        colors: .dark,
        fonts: .default,
        spacing: .default,
        radius: .default
    )
}

struct ThemeColors {
    let primary: Color
    let secondary: Color
    let accent: Color
    let background: Color
    let secondaryBackground: Color
    let text: Color
    let secondaryText: Color
    let success: Color
    let warning: Color
    let error: Color
    let border: Color
    
    static let light = ThemeColors(
        primary: Color(hex: "007AFF"),
        secondary: Color(hex: "5856D6"),
        accent: Color(hex: "FF9500"),
        background: .white,
        secondaryBackground: Color(hex: "F2F2F7"),
        text: Color(hex: "000000"),
        secondaryText: Color(hex: "8E8E93"),
        success: Color(hex: "34C759"),
        warning: Color(hex: "FF9500"),
        error: Color(hex: "FF3B30"),
        border: Color(hex: "C6C6C8")
    )
    
    static let dark = ThemeColors(
        primary: Color(hex: "0A84FF"),
        secondary: Color(hex: "5E5CE6"),
        accent: Color(hex: "FF9F0A"),
        background: Color(hex: "000000"),
        secondaryBackground: Color(hex: "1C1C1E"),
        text: Color(hex: "FFFFFF"),
        secondaryText: Color(hex: "8E8E93"),
        success: Color(hex: "30D158"),
        warning: Color(hex: "FF9F0A"),
        error: Color(hex: "FF453A"),
        border: Color(hex: "38383A")
    )
}

struct ThemeFonts {
    let largeTitle: Font
    let title: Font
    let title2: Font
    let title3: Font
    let headline: Font
    let body: Font
    let callout: Font
    let subheadline: Font
    let footnote: Font
    let caption: Font
    let caption2: Font
    
    static let `default` = ThemeFonts(
        largeTitle: .system(size: 34, weight: .bold),
        title: .system(size: 28, weight: .bold),
        title2: .system(size: 22, weight: .bold),
        title3: .system(size: 20, weight: .semibold),
        headline: .system(size: 17, weight: .semibold),
        body: .system(size: 17, weight: .regular),
        callout: .system(size: 16, weight: .regular),
        subheadline: .system(size: 15, weight: .regular),
        footnote: .system(size: 13, weight: .regular),
        caption: .system(size: 12, weight: .regular),
        caption2: .system(size: 11, weight: .regular)
    )
}

struct ThemeSpacing {
    let xs: CGFloat = 4
    let sm: CGFloat = 8
    let md: CGFloat = 16
    let lg: CGFloat = 24
    let xl: CGFloat = 32
    let xxl: CGFloat = 48
    
    static let `default` = ThemeSpacing()
}

struct ThemeRadius {
    let sm: CGFloat = 4
    let md: CGFloat = 8
    let lg: CGFloat = 12
    let xl: CGFloat = 16
    let xxl: CGFloat = 24
    let full: CGFloat = 9999
    
    static let `default` = ThemeRadius()
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
