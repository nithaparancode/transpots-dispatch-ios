import SwiftUI

public struct SimpleCard<Content: View>: View {
    @Environment(\.theme) var theme
    
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(theme.spacing.lg)
            .background(theme.colors.secondaryBackground)
            .cornerRadius(theme.radius.lg)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
