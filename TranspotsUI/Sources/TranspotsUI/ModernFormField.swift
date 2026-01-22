import SwiftUI

// MARK: - Modern Form Field Component
public struct ModernFormField: View {
    let label: String
    @Binding var value: String
    let isEditMode: Bool
    var isMultiline: Bool
    var prefix: String
    var icon: String
    var placeholder: String
    var emptyText: String
    var keyboardType: UIKeyboardType
    @Environment(\.theme) var theme
    @FocusState private var isFocused: Bool
    
    public init(
        label: String,
        value: Binding<String>,
        isEditMode: Bool = false,
        isMultiline: Bool = false,
        prefix: String = "",
        icon: String = "",
        placeholder: String = "",
        emptyText: String = "Not set",
        keyboardType: UIKeyboardType = .default
    ) {
        self.label = label
        self._value = value
        self.isEditMode = isEditMode
        self.isMultiline = isMultiline
        self.prefix = prefix
        self.icon = icon
        self.placeholder = placeholder
        self.emptyText = emptyText
        self.keyboardType = keyboardType
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label with icon
            HStack(spacing: 6) {
                if !icon.isEmpty {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(theme.colors.primary)
                }
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(theme.colors.secondaryText)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            
            // Input field
            if isEditMode {
                editModeView
            } else {
                readOnlyView
            }
        }
    }
    
    @ViewBuilder
    private var editModeView: some View {
        if isMultiline {
            TextEditor(text: $value)
                .frame(minHeight: 100)
                .padding(theme.spacing.md)
                .background(theme.colors.background)
                .cornerRadius(theme.radius.lg)
                .focused($isFocused)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radius.lg)
                        .stroke(isFocused ? theme.colors.primary : theme.colors.primary.opacity(0.3), lineWidth: isFocused ? 2.5 : 2)
                        .animation(.easeInOut(duration: 0.2), value: isFocused)
                )
                .shadow(color: isFocused ? theme.colors.primary.opacity(0.2) : Color.clear, radius: isFocused ? 8 : 0, y: 0)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        } else {
            HStack(spacing: 8) {
                if !prefix.isEmpty {
                    Text(prefix)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isFocused ? theme.colors.primary : theme.colors.primary.opacity(0.7))
                        .animation(.easeInOut(duration: 0.2), value: isFocused)
                }
                TextField(placeholder, text: $value)
                    .font(.system(size: 16))
                    .keyboardType(keyboardType)
                    .focused($isFocused)
            }
            .padding(theme.spacing.md)
            .background(isFocused ? theme.colors.background : theme.colors.background.opacity(0.8))
            .cornerRadius(theme.radius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.lg)
                    .stroke(isFocused ? theme.colors.primary : theme.colors.primary.opacity(0.3), lineWidth: isFocused ? 2.5 : 2)
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
            )
            .shadow(color: isFocused ? theme.colors.primary.opacity(0.2) : Color.clear, radius: isFocused ? 8 : 0, y: 0)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
    
    private var readOnlyView: some View {
        let displayValue = value.isEmpty ? emptyText : (prefix + value)
        return HStack {
            Text(displayValue)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(value.isEmpty ? theme.colors.secondaryText : theme.colors.text)
            Spacer()
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.colors.background.opacity(0.5))
        .cornerRadius(theme.radius.lg)
    }
}

// MARK: - Read-Only Form Field
public struct ReadOnlyFormField: View {
    let label: String
    let value: String
    var icon: String
    var emptyText: String
    var prefix: String
    @Environment(\.theme) var theme
    
    public init(
        label: String,
        value: String,
        icon: String = "",
        emptyText: String = "Not set",
        prefix: String = ""
    ) {
        self.label = label
        self.value = value
        self.icon = icon
        self.emptyText = emptyText
        self.prefix = prefix
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                if !icon.isEmpty {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(theme.colors.primary)
                }
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(theme.colors.secondaryText)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            
            let displayValue = value.isEmpty ? emptyText : (prefix + value)
            HStack {
                Text(displayValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(value.isEmpty ? theme.colors.secondaryText : theme.colors.text)
                Spacer()
            }
            .padding(theme.spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.colors.background.opacity(0.5))
            .cornerRadius(theme.radius.lg)
        }
    }
}

// MARK: - Preview
#if DEBUG
struct ModernFormField_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Edit Mode
                Group {
                    Text("Edit Mode")
                        .font(.headline)
                    
                    ModernFormFieldPreview(
                        label: "Customer Name",
                        value: "Acme Corporation",
                        isEditMode: true,
                        icon: "person.fill"
                    )
                    
                    ModernFormFieldPreview(
                        label: "Base Rate",
                        value: "2500",
                        isEditMode: true,
                        prefix: "$",
                        icon: "banknote",
                        keyboardType: .numberPad
                    )
                    
                    ModernFormFieldPreview(
                        label: "Email",
                        value: "contact@acme.com",
                        isEditMode: true,
                        icon: "envelope.fill",
                        keyboardType: .emailAddress
                    )
                }
                
                Divider()
                
                // Read-Only Mode
                Group {
                    Text("Read-Only Mode")
                        .font(.headline)
                    
                    ModernFormFieldPreview(
                        label: "Customer Name",
                        value: "Acme Corporation",
                        isEditMode: false,
                        icon: "person.fill"
                    )
                    
                    ModernFormFieldPreview(
                        label: "Base Rate",
                        value: "2500",
                        isEditMode: false,
                        prefix: "$",
                        icon: "banknote"
                    )
                    
                    ModernFormFieldPreview(
                        label: "Optional Field",
                        value: "",
                        isEditMode: false,
                        icon: "questionmark.circle"
                    )
                }
                
                Divider()
                
                // Read-Only Component
                Group {
                    Text("Read-Only Component")
                        .font(.headline)
                    
                    ReadOnlyFormField(
                        label: "Order Status",
                        value: "ACTIVE",
                        icon: "checkmark.circle.fill"
                    )
                    
                    ReadOnlyFormField(
                        label: "Total Amount",
                        value: "5000",
                        icon: "dollarsign.circle.fill",
                        prefix: "$"
                    )
                }
            }
            .padding()
        }
    }
}

struct ModernFormFieldPreview: View {
    let label: String
    @State var value: String
    let isEditMode: Bool
    var prefix: String = ""
    var icon: String = ""
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        ModernFormField(
            label: label,
            value: $value,
            isEditMode: isEditMode,
            prefix: prefix,
            icon: icon,
            keyboardType: keyboardType
        )
    }
}
#endif
