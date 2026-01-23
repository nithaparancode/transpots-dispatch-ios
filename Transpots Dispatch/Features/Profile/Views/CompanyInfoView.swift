import SwiftUI
import TranspotsUI

struct CompanyInfoView: View {
    @Environment(\.theme) var theme
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        contentView
            .navigationTitle("Company Information")
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
            companyInfoContent(user)
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading company information...")
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
    
    private func companyInfoContent(_ user: User) -> some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                companyHeader()
                
                companyInfoCard(user)
            }
            .padding(theme.spacing.lg)
        }
        .background(theme.colors.background)
    }
    
    private func companyHeader() -> some View {
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
                
                AppSymbols.profileSettings
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
            
            Text("Company Details")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(theme.colors.text)
            
            Text("Your organization information")
                .font(theme.fonts.caption)
                .foregroundColor(theme.colors.secondaryText)
        }
        .padding(.vertical, theme.spacing.md)
    }
    
    private func companyInfoCard(_ user: User) -> some View {
        VStack(spacing: theme.spacing.lg) {
            ReadOnlyFormField(
                label: "Company Name",
                value: user.companyName ?? "",
                icon: "building.2.fill"
            )
            
            ReadOnlyFormField(
                label: "Company ID",
                value: user.companyId != nil ? "\(user.companyId!)" : "",
                icon: "number"
            )
        }
        .padding(theme.spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.xl)
                .fill(theme.colors.secondaryBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
        )
    }
}

#if DEBUG
struct CompanyInfoView_Previews: PreviewProvider {
    static var previews: some View {
        CompanyInfoView()
    }
}
#endif
