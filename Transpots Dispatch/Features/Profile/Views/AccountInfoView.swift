import SwiftUI
import TranspotsUI

struct AccountInfoView: View {
    @Environment(\.theme) var theme
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        contentView
            .navigationTitle("Account Information")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .onAppear {
                if viewModel.state == .idle {
                    viewModel.loadUserProfile()
                }
            }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .idle:
            Color.clear
        case .loading:
            loadingView
        case .failed(let error):
            errorView(message: error)
        case .loaded(let user):
            accountInfoContent(user)
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading account information...")
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.secondaryText)
                .padding(.top, theme.spacing.md)
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: theme.spacing.lg) {
            AppSymbols.statusError
                .font(.system(size: 50))
                .foregroundColor(theme.colors.error)
            
            Text("Something went wrong")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(theme.colors.text)
            
            Text(message)
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, theme.spacing.xl)
            
            Button("Try Again") {
                viewModel.loadUserProfile()
            }
            .font(theme.fonts.headline)
            .foregroundColor(.white)
            .frame(width: 140, height: 44)
            .background(theme.colors.primary)
            .cornerRadius(theme.radius.md)
        }
    }
    
    private func accountInfoContent(_ user: User) -> some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                accountHeader()
                
                accountInfoCard(user)
            }
            .padding(theme.spacing.lg)
        }
        .background(theme.colors.background)
    }
    
    private func accountHeader() -> some View {
        VStack(spacing: theme.spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: theme.radius.xl)
                    .fill(
                        LinearGradient(
                            colors: [theme.colors.primary, theme.colors.primary.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: theme.colors.primary.opacity(0.3), radius: 12, y: 4)
                
                AppSymbols.statusInfo
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
            
            Text("Account Details")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(theme.colors.text)
            
            Text("Your account status and information")
                .font(theme.fonts.caption)
                .foregroundColor(theme.colors.secondaryText)
        }
        .padding(.vertical, theme.spacing.md)
    }
    
    private func accountInfoCard(_ user: User) -> some View {
        VStack(spacing: theme.spacing.lg) {
            ReadOnlyFormField(
                label: "User ID",
                value: user.id,
                icon: "number.circle"
            )
            
            if let status = user.status {
                HStack {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        HStack(spacing: theme.spacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(theme.colors.primary)
                            Text("Account Status")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(theme.colors.secondaryText)
                                .textCase(.uppercase)
                                .tracking(0.5)
                        }
                        
                        Text(status.capitalized)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(status.lowercased() == "active" ? theme.colors.success : theme.colors.secondaryText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: theme.radius.lg)
                                    .fill(status.lowercased() == "active" ? theme.colors.success.opacity(0.1) : theme.colors.secondaryBackground)
                            )
                    }
                    Spacer()
                }
            }
            
            if let createdAt = user.createdAt {
                ReadOnlyFormField(
                    label: "Member Since",
                    value: formatDate(createdAt),
                    icon: "calendar"
                )
            }
        }
        .padding(theme.spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.xl)
                .fill(theme.colors.secondaryBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
        )
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM d, yyyy"
        return displayFormatter.string(from: date)
    }
}

#if DEBUG
struct AccountInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AccountInfoView()
    }
}
#endif
