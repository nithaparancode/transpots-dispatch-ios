import SwiftUI

public struct StatCard: View {
    @Environment(\.theme) var theme
    
    let title: String
    let value: String
    let icon: Image
    let iconColor: Color
    
    public init(title: String, value: String, icon: Image, iconColor: Color) {
        self.title = title
        self.value = value
        self.icon = icon
        self.iconColor = iconColor
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                icon
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(iconColor.opacity(0.12))
                    )
                
                Spacer()
            }
            .padding(.bottom, theme.spacing.lg)
            
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(theme.colors.text)
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(theme.colors.secondaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(theme.spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 140)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg)
                .fill(theme.colors.secondaryBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg)
                .strokeBorder(theme.colors.border.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}
