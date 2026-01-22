import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

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
    @Namespace private var animation
    
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
                    #if canImport(UIKit)
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    #endif
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
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
                        .symbolRenderingMode(.hierarchical)
                }
                
                Text(item.title)
                    .font(.system(size: style.fontSize, weight: isSelected(item) ? .semibold : .regular))
                    .lineLimit(1)
            }
            .foregroundColor(isSelected(item) ? style.selectedColor(theme) : style.unselectedColor(theme))
            .padding(.vertical, style.verticalPadding)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isSelected(item) {
                        style.selectedBackgroundColor(theme)
                            .matchedGeometryEffect(id: "selectedTab", in: animation)
                    } else {
                        Color.clear
                    }
                }
            )
            .cornerRadius(style.cornerRadius)
            .scaleEffect(isSelected(item) ? 1.0 : 0.95)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected(item))
            
            if style.showIndicator {
                ZStack {
                    if isSelected(item) {
                        RoundedRectangle(cornerRadius: style.indicatorHeight / 2)
                            .fill(style.indicatorColor(theme))
                            .frame(height: style.indicatorHeight)
                            .matchedGeometryEffect(id: "indicator", in: animation)
                            .shadow(color: style.indicatorColor(theme).opacity(0.3), radius: 2, y: 1)
                    } else {
                        Color.clear
                            .frame(height: style.indicatorHeight)
                    }
                }
            }
        }
        .contentShape(Rectangle())
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
    
    public static let `default` = TabBarStyle(
        fontSize: 15,
        verticalPadding: 14,
        indicatorHeight: 3
    )
    
    public static let rounded = TabBarStyle(
        fontSize: 15,
        verticalPadding: 12,
        spacing: 4,
        cornerRadius: 10,
        showIndicator: false,
        selectedColor: { _ in .white },
        selectedBackgroundColor: { $0.colors.primary }
    )
    
    public static let pills = TabBarStyle(
        fontSize: 14,
        verticalPadding: 10,
        spacing: 6,
        cornerRadius: 20,
        showIndicator: false,
        selectedColor: { _ in .white },
        selectedBackgroundColor: { $0.colors.primary },
        backgroundColor: { $0.colors.background }
    )
    
    public static let minimal = TabBarStyle(
        fontSize: 15,
        verticalPadding: 12,
        showIndicator: false,
        selectedBackgroundColor: { _ in Color.clear }
    )
    
    public static let underline = TabBarStyle(
        fontSize: 15,
        verticalPadding: 14,
        indicatorHeight: 3,
        selectedBackgroundColor: { _ in Color.clear },
        backgroundColor: { _ in Color.clear }
    )
    
    public static let modern = TabBarStyle(
        fontSize: 14,
        verticalPadding: 12,
        spacing: 2,
        cornerRadius: 12,
        showIndicator: false,
        selectedColor: { $0.colors.primary },
        unselectedColor: { $0.colors.secondaryText },
        selectedBackgroundColor: { $0.colors.primary.opacity(0.12) },
        backgroundColor: { $0.colors.secondaryBackground }
    )
    
    public static let gradient = TabBarStyle(
        fontSize: 15,
        verticalPadding: 14,
        spacing: 2,
        cornerRadius: 10,
        showIndicator: false,
        selectedColor: { _ in .white },
        selectedBackgroundColor: { $0.colors.primary },
        backgroundColor: { $0.colors.secondaryBackground }
    )
}

// MARK: - Preview
#if DEBUG
struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Default Style
                TabBarPreview(style: .default, title: "Default Style")
                
                // Modern Style
                TabBarPreview(style: .modern, title: "Modern Style")
                
                // Rounded Style
                TabBarPreview(style: .rounded, title: "Rounded Style")
                
                // Pills Style
                TabBarPreview(style: .pills, title: "Pills Style")
                
                // Gradient Style
                TabBarPreview(style: .gradient, title: "Gradient Style")
                
                // Minimal Style
                TabBarPreview(style: .minimal, title: "Minimal Style")
                
                // Underline Style
                TabBarPreview(style: .underline, title: "Underline Style")
            }
            .padding()
        }
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
