import SwiftUI
import Combine

public final class AppTheme: ObservableObject {
    public static let shared = AppTheme()
    
    @Published public var currentTheme: ThemeMode = .light
    
    private init() {}
    
    public enum ThemeMode {
        case light
        case dark
    }
}

public struct Theme {
    public let colors: ThemeColors
    public let fonts: ThemeFonts
    public let spacing: ThemeSpacing
    public let radius: ThemeRadius
    
    public static let light = Theme(
        colors: .light,
        fonts: .default,
        spacing: .default,
        radius: .default
    )
    
    public static let dark = Theme(
        colors: .dark,
        fonts: .default,
        spacing: .default,
        radius: .default
    )
}

public struct ThemeColors {
    public let primary: Color
    public let secondary: Color
    public let accent: Color
    public let background: Color
    public let secondaryBackground: Color
    public let text: Color
    public let secondaryText: Color
    public let success: Color
    public let warning: Color
    public let error: Color
    public let border: Color
    
    public static let light = ThemeColors(
        primary: Color(hex: "1077c1"),
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
    
    public static let dark = ThemeColors(
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

public struct ThemeFonts {
    public let largeTitle: Font
    public let title: Font
    public let title2: Font
    public let title3: Font
    public let headline: Font
    public let body: Font
    public let callout: Font
    public let subheadline: Font
    public let footnote: Font
    public let caption: Font
    public let caption2: Font
    
    public static let `default` = ThemeFonts(
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

public struct ThemeSpacing {
    public let xs: CGFloat = 4
    public let sm: CGFloat = 8
    public let md: CGFloat = 16
    public let lg: CGFloat = 24
    public let xl: CGFloat = 32
    public let xxl: CGFloat = 48
    
    public static let `default` = ThemeSpacing()
}

public struct ThemeRadius {
    public let sm: CGFloat = 4
    public let md: CGFloat = 8
    public let lg: CGFloat = 12
    public let xl: CGFloat = 16
    public let xxl: CGFloat = 24
    public let full: CGFloat = 9999
    
    public static let `default` = ThemeRadius()
}

public extension Color {
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
