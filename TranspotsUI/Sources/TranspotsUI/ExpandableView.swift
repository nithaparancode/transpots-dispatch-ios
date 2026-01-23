import SwiftUI

public struct ExpandableView<LeadingContent: View, ExpandedContent: View, TrailingIcon: View>: View {
    @Environment(\.theme) var theme
    @State private var isExpanded: Bool
    
    let leadingContent: LeadingContent
    let expandedContent: ExpandedContent
    let trailingIcon: TrailingIcon
    let onToggle: ((Bool) -> Void)?
    
    public init(
        isExpanded: Bool = false,
        @ViewBuilder leadingContent: () -> LeadingContent,
        @ViewBuilder expandedContent: () -> ExpandedContent,
        @ViewBuilder trailingIcon: () -> TrailingIcon,
        onToggle: ((Bool) -> Void)? = nil
    ) {
        self._isExpanded = State(initialValue: isExpanded)
        self.leadingContent = leadingContent()
        self.expandedContent = expandedContent()
        self.trailingIcon = trailingIcon()
        self.onToggle = onToggle
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                    onToggle?(isExpanded)
                }
            }) {
                HStack(spacing: theme.spacing.md) {
                    leadingContent
                    
                    Spacer()
                    
                    trailingIcon
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                expandedContent
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                        removal: .opacity
                    ))
            }
        }
        .clipped()
    }
}

public extension ExpandableView where TrailingIcon == Image {
    init(
        isExpanded: Bool = false,
        @ViewBuilder leadingContent: () -> LeadingContent,
        @ViewBuilder expandedContent: () -> ExpandedContent,
        onToggle: ((Bool) -> Void)? = nil
    ) {
        self._isExpanded = State(initialValue: isExpanded)
        self.leadingContent = leadingContent()
        self.expandedContent = expandedContent()
        self.trailingIcon = Image(systemName: "chevron.down")
        self.onToggle = onToggle
    }
}
