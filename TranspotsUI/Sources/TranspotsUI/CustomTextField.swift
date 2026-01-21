import SwiftUI

public struct CustomTextField: View {
    @Environment(\.theme) var theme
    
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .words
    var isSecure: Bool = false
    
    @State private var isSecureVisible: Bool = false
    
    public init(
        title: String,
        text: Binding<String>,
        placeholder: String,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .words,
        isSecure: Bool = false
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self.isSecure = isSecure
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(theme.colors.text)
            
            HStack {
                if isSecure && !isSecureVisible {
                    SecureField(placeholder, text: $text)
                        .textInputAutocapitalization(.never)
                        .keyboardType(keyboardType)
                } else {
                    TextField(placeholder, text: $text)
                        .textInputAutocapitalization(autocapitalization)
                        .keyboardType(keyboardType)
                }
                
                if isSecure {
                    Button(action: {
                        isSecureVisible.toggle()
                    }) {
                        Image(systemName: isSecureVisible ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 16))
                            .foregroundColor(theme.colors.secondaryText)
                    }
                }
            }
            .padding(theme.spacing.md)
            .background(theme.colors.secondaryBackground)
            .cornerRadius(theme.radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md)
                    .strokeBorder(theme.colors.border.opacity(0.2), lineWidth: 1)
            )
        }
    }
}
