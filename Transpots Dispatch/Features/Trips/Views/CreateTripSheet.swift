import SwiftUI
import TranspotsUI

struct CreateTripSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.theme) var theme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: theme.spacing.lg) {
                    
                }
                .padding(theme.spacing.md)
            }
            .background(theme.colors.background)
            .navigationTitle("Create Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createTrip()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func createTrip() {
        dismiss()
    }
}

#if DEBUG
struct CreateTripSheet_Previews: PreviewProvider {
    static var previews: some View {
        CreateTripSheet()
    }
}
#endif
