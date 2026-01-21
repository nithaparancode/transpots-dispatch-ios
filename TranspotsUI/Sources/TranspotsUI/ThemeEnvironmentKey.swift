import SwiftUI

public struct ThemeKey: EnvironmentKey {
    public static let defaultValue: Theme = Theme.light
}

public extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
