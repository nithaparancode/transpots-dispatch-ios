import SwiftUI

public struct PrimaryButton: View {
    @Environment(\.theme) var theme
    
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    public init(title: String, isLoading: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundColor(.white)
            .background(theme.colors.primary)
            .cornerRadius(theme.radius.md)
            .shadow(color: theme.colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}
