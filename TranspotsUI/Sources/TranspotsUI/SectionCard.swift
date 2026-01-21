import SwiftUI

public struct SectionCard<Content: View>: View {
    @Environment(\.theme) var theme
    
    let title: String
    let content: Content
    
    public init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(theme.colors.text)
            
            content
        }
        .padding(theme.spacing.lg)
        .background(theme.colors.secondaryBackground)
        .cornerRadius(theme.radius.lg)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
