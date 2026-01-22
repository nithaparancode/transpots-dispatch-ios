import SwiftUI
import TranspotsUI

struct LaunchScreenView: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        ZStack {
            theme.colors.primary
                .ignoresSafeArea()
            
            VStack(spacing: theme.spacing.lg) {
                AppSymbols.launchTruck
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text("Transpots Dispatch")
                    .font(theme.fonts.largeTitle)
                    .foregroundColor(.white)
                
                Text("Delivery Management System")
                    .font(theme.fonts.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}
