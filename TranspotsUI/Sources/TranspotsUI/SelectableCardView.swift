import SwiftUI

public struct SelectableCardView: View {
    @Environment(\.theme) var theme
    
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    public init(
        title: String,
        icon: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(spacing: icon != nil ? 8 : 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : theme.colors.text)
                }
                
                Text(title)
                    .font(theme.fonts.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : theme.colors.text)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: icon != nil ? 60 : 50)
            .padding(.vertical, icon != nil ? 12 : 8)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.lg)
                    .fill(isSelected ? theme.colors.primary : theme.colors.secondaryBackground)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
  
#Preview {
    VStack(spacing: 20) {
        // Language-style cards (no icon)
        HStack(spacing: 8) {
            SelectableCardView(title: "System", isSelected: false) {}
            SelectableCardView(title: "English", isSelected: true) {}
            SelectableCardView(title: "Spanish", isSelected: false) {}
            SelectableCardView(title: "French", isSelected: false) {}
        }
        
        // Appearance-style cards (with icon)
        HStack(spacing: 12) {
            SelectableCardView(title: "System", icon: "gear", isSelected: false) {}
            SelectableCardView(title: "Light", icon: "sun.max.fill", isSelected: true) {}
            SelectableCardView(title: "Dark", icon: "moon.fill", isSelected: false) {}
        }
    }
    .padding()
    .environment(\.theme, .light)
}
