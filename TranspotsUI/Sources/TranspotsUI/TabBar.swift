import SwiftUI

// MARK: - Tab Bar Item Model
public struct TabBarItem: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let icon: String?
    
    public init(id: String, title: String, icon: String? = nil) {
        self.id = id
        self.title = title
        self.icon = icon
    }
}

// MARK: - Tab Bar Component
public struct TabBar: View {
    @Binding var selectedTab: String
    let items: [TabBarItem]
    let style: TabBarStyle
    @Environment(\.theme) var theme
    
    public init(
        selectedTab: Binding<String>,
        items: [TabBarItem],
        style: TabBarStyle = .default
    ) {
        self._selectedTab = selectedTab
        self.items = items
        self.style = style
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = item.id
                    }
                }) {
                    tabItemView(item)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(style.backgroundColor(theme))
    }
    
    @ViewBuilder
    private func tabItemView(_ item: TabBarItem) -> some View {
        VStack(spacing: style.spacing) {
            HStack(spacing: 6) {
                if let icon = item.icon {
                    Image(systemName: icon)
                        .font(.system(size: style.iconSize, weight: isSelected(item) ? .semibold : .regular))
                }
                
                Text(item.title)
                    .font(.system(size: style.fontSize, weight: isSelected(item) ? .semibold : .regular))
            }
            .foregroundColor(isSelected(item) ? style.selectedColor(theme) : style.unselectedColor(theme))
            .padding(.vertical, style.verticalPadding)
            .frame(maxWidth: .infinity)
            .background(isSelected(item) ? style.selectedBackgroundColor(theme) : Color.clear)
            .cornerRadius(style.cornerRadius)
            
            if style.showIndicator {
                Rectangle()
                    .fill(isSelected(item) ? style.indicatorColor(theme) : Color.clear)
                    .frame(height: style.indicatorHeight)
            }
        }
    }
    
    private func isSelected(_ item: TabBarItem) -> Bool {
        selectedTab == item.id
    }
}

// MARK: - Tab Bar Style
public struct TabBarStyle {
    public let fontSize: CGFloat
    public let iconSize: CGFloat
    public let verticalPadding: CGFloat
    public let spacing: CGFloat
    public let cornerRadius: CGFloat
    public let showIndicator: Bool
    public let indicatorHeight: CGFloat
    public let selectedColor: (Theme) -> Color
    public let unselectedColor: (Theme) -> Color
    public let selectedBackgroundColor: (Theme) -> Color
    public let backgroundColor: (Theme) -> Color
    public let indicatorColor: (Theme) -> Color
    
    public init(
        fontSize: CGFloat = 15,
        iconSize: CGFloat = 16,
        verticalPadding: CGFloat = 12,
        spacing: CGFloat = 0,
        cornerRadius: CGFloat = 0,
        showIndicator: Bool = true,
        indicatorHeight: CGFloat = 2,
        selectedColor: @escaping (Theme) -> Color = { $0.colors.primary },
        unselectedColor: @escaping (Theme) -> Color = { $0.colors.secondaryText },
        selectedBackgroundColor: @escaping (Theme) -> Color = { $0.colors.primary.opacity(0.1) },
        backgroundColor: @escaping (Theme) -> Color = { $0.colors.secondaryBackground },
        indicatorColor: @escaping (Theme) -> Color = { $0.colors.primary }
    ) {
        self.fontSize = fontSize
        self.iconSize = iconSize
        self.verticalPadding = verticalPadding
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.showIndicator = showIndicator
        self.indicatorHeight = indicatorHeight
        self.selectedColor = selectedColor
        self.unselectedColor = unselectedColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.backgroundColor = backgroundColor
        self.indicatorColor = indicatorColor
    }
    
    public static let `default` = TabBarStyle()
    
    public static let rounded = TabBarStyle(
        verticalPadding: 10,
        spacing: 4,
        cornerRadius: 8,
        showIndicator: false,
        selectedColor: { _ in .white }, selectedBackgroundColor: { $0.colors.primary }
    )
    
    public static let pills = TabBarStyle(
        verticalPadding: 8,
        spacing: 4,
        cornerRadius: 20,
        showIndicator: false,
        selectedColor: { _ in .white }, selectedBackgroundColor: { $0.colors.primary },
        backgroundColor: { $0.colors.background }
    )
    
    public static let minimal = TabBarStyle(
        showIndicator: false,
        selectedBackgroundColor: { _ in Color.clear }
    )
    
    public static let underline = TabBarStyle(
        selectedBackgroundColor: { _ in Color.clear },
        backgroundColor: { _ in Color.clear }
    )
}

// MARK: - Preview
#if DEBUG
struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            // Default Style
            TabBarPreview(style: .default, title: "Default Style")
            
            // Rounded Style
            TabBarPreview(style: .rounded, title: "Rounded Style")
            
            // Pills Style
            TabBarPreview(style: .pills, title: "Pills Style")
            
            // Minimal Style
            TabBarPreview(style: .minimal, title: "Minimal Style")
            
            // Underline Style
            TabBarPreview(style: .underline, title: "Underline Style")
        }
        .padding()
    }
}

struct TabBarPreview: View {
    @State private var selectedTab = "customer"
    let style: TabBarStyle
    let title: String
    
    let items = [
        TabBarItem(id: "customer", title: "Customer", icon: "person.fill"),
        TabBarItem(id: "rate", title: "Rate", icon: "dollarsign.circle.fill"),
        TabBarItem(id: "pickup", title: "Pickup", icon: "arrow.up.circle.fill"),
        TabBarItem(id: "delivery", title: "Delivery", icon: "arrow.down.circle.fill"),
        TabBarItem(id: "notes", title: "Notes", icon: "note.text")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            TabBar(selectedTab: $selectedTab, items: items, style: style)
        }
    }
}
#endif
