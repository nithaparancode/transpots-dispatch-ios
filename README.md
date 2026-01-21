# Transpots Dispatch iOS

A dispatch management iOS application built with SwiftUI, following MVVM architecture with Coordinator pattern.

---

## 🤖 AI Coding Rules & Guidelines

**IMPORTANT: All AI agents working on this project MUST follow these rules strictly.**

### 1. Theme System Rules
- ✅ **ALWAYS** consume theme from environment using `@Environment(\.theme) var theme`
- ✅ **NEVER** hardcode colors, fonts, spacing, or radius values
- ✅ Use `theme.colors.*` for all colors (primary, secondary, text, background, etc.)
- ✅ Use `theme.fonts.*` for all typography (title, body, headline, etc.)
- ✅ Use `theme.spacing.*` for all spacing (xs, sm, md, lg, xl, xxl)
- ✅ Use `theme.radius.*` for all corner radius (sm, md, lg, xl, xxl, full)
- ❌ **NEVER** use `Color.blue`, `Font.system()`, hardcoded padding values, or magic numbers

**Example:**
```swift
struct MyView: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        Text("Hello")
            .font(theme.fonts.title)
            .foregroundColor(theme.colors.text)
            .padding(theme.spacing.md)
            .background(theme.colors.secondaryBackground)
            .cornerRadius(theme.radius.md)
    }
}
```

### 2. Symbols & Icons Rules
- ✅ **ALWAYS** use symbols from `AppSymbols` (from TranspotsUI module)
- ✅ Import `TranspotsUI` in any file using symbols
- ✅ Use `AppSymbols.tabHome`, `AppSymbols.actionAdd`, etc. (returns Image directly)
- ✅ For Label systemImage parameter, use `AppSymbols.tabHomeName` (String variants)
- ❌ **NEVER** use `Image(systemName: "house.fill")` or hardcoded SF Symbol strings
- ❌ **NEVER** create new symbols without adding them to `AppSymbols.swift` in TranspotsUI module

**Example:**
```swift
import TranspotsUI

// Direct Image usage
AppSymbols.tabHome
    .font(.system(size: 60))
    .foregroundColor(theme.colors.primary)

// Label usage
Label("Home", systemImage: AppSymbols.tabHomeName)
```

### 3. Reusable UI Components Rules
- ✅ **ALWAYS** create reusable views in `TranspotsUI` module
- ✅ Place reusable components in `TranspotsUI/Sources/TranspotsUI/`
- ✅ Mark all public components with `public` access modifier
- ✅ Create components for: buttons, cards, loading indicators, form fields, etc.
- ✅ Reusable components should accept theme via environment
- ❌ **NEVER** duplicate UI code across multiple views
- ❌ **NEVER** create view-specific components in main app when they can be reused

**Example:**
```swift
// In TranspotsUI/Sources/TranspotsUI/PrimaryButton.swift
import SwiftUI

public struct PrimaryButton: View {
    @Environment(\.theme) var theme
    let title: String
    let action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(theme.fonts.headline)
                .foregroundColor(.white)
                .padding(theme.spacing.md)
                .background(theme.colors.primary)
                .cornerRadius(theme.radius.md)
        }
    }
}
```

### 4. Navigation & Coordinator Rules
- ✅ **ALWAYS** use Coordinator pattern for navigation
- ✅ Each feature must have its own Coordinator conforming to `Coordinator` protocol
- ✅ Define routes as enum with associated values
- ✅ Use `coordinator.push()`, `coordinator.pop()`, `coordinator.popToRoot()`
- ✅ Use `NavigationStack(path: $coordinator.path)` in views
- ✅ Use `.navigationDestination(for: RouteType.self)` for route handling
- ❌ **NEVER** use `NavigationLink` directly for programmatic navigation
- ❌ **NEVER** handle navigation logic in Views or ViewModels

**Example:**
```swift
// Coordinator
enum MyRoute: Hashable {
    case detail(id: String)
    case settings
}

final class MyCoordinator: Coordinator {
    typealias Route = MyRoute
    @Published var path = NavigationPath()
    
    @ViewBuilder
    func view(for route: MyRoute) -> some View {
        switch route {
        case .detail(let id):
            DetailView(id: id)
        case .settings:
            SettingsView()
        }
    }
}

// View
NavigationStack(path: $coordinator.path) {
    // content
    .navigationDestination(for: MyRoute.self) { route in
        coordinator.view(for: route)
    }
}
```

### 5. Task Management Rules
- ✅ **ALWAYS** store Task instances in ViewModel properties
- ✅ Cancel previous task before starting new one
- ✅ Cancel tasks in `deinit`
- ✅ Use `@MainActor` for UI updates
- ❌ **NEVER** create orphaned tasks without storing reference
- ❌ **NEVER** forget to cancel tasks on cleanup

**Example:**
```swift
final class MyViewModel: ObservableObject {
    @Published var isLoading = false
    private var currentTask: Task<Void, Never>?
    
    func loadData() {
        currentTask?.cancel()
        isLoading = true
        
        currentTask = Task { @MainActor in
            // async work
            isLoading = false
        }
    }
    
    deinit {
        currentTask?.cancel()
    }
}
```

### 6. Architecture Rules
- ✅ **ALWAYS** follow MVVM + Coordinator pattern
- ✅ Views should be dumb - only UI logic
- ✅ ViewModels handle business logic and state
- ✅ Coordinators handle navigation flow
- ✅ Use ViewState enum for each ViewModel (idle, loading, loaded, failed)
- ✅ UI should consume data only through ViewState enum
- ✅ Use `@StateObject` for owned objects, `@ObservedObject` for injected
- ✅ Keep ViewModels testable (no SwiftUI dependencies)
- ❌ **NEVER** put business logic in Views
- ❌ **NEVER** put navigation logic in ViewModels
- ❌ **NEVER** put UI logic in ViewModels
- ❌ **NEVER** use separate `isLoading`, `error`, `data` properties (use ViewState enum instead)

**ViewState Pattern:**
```swift
// In ViewModel
enum ViewState {
    case idle
    case loading
    case loaded(DataType)
    case failed(String)
}

@Published var state: ViewState = .idle

func loadData() {
    state = .loading
    Task { @MainActor in
        do {
            let data = try await service.fetchData()
            state = .loaded(data)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

// In View
switch viewModel.state {
case .idle:
    EmptyView()
case .loading:
    ProgressView()
case .loaded(let data):
    ContentView(data: data)
case .failed(let error):
    ErrorView(message: error)
}
```

### 7. Service Layer Rules
- ✅ **ALWAYS** create services for API calls and business logic
- ✅ Services should conform to a protocol (e.g., `DashboardServiceProtocol`)
- ✅ Organize services by domain/feature in `Core/Services/{Feature}/`
- ✅ Place related models with their services (e.g., `Core/Services/Dashboard/DashboardModels.swift`)
- ✅ Inject services into ViewModels via initializer (dependency injection)
- ✅ Services use `NetworkManager.shared.request()` for API calls
- ✅ Keep ViewModels thin - business logic goes in services
- ✅ Services should be testable (protocol-based)
- ✅ Trigger data loading in view's `.onAppear`, not in ViewModel init
- ❌ **NEVER** put API calls directly in ViewModels
- ❌ **NEVER** put business logic in Views
- ❌ **NEVER** create services without protocols
- ❌ **NEVER** scatter models across multiple locations
- ❌ **NEVER** use default parameters in ViewModel init (e.g., `= DashboardService()`)
- ❌ **NEVER** call loading methods in ViewModel init

**Example:**
```swift
// In Core/Services/Dashboard/DashboardModels.swift
struct DashboardSummary: Codable {
    let activeOrders: Int
    let activeTrips: Int
}

// In Core/Services/Dashboard/DashboardService.swift
protocol DashboardServiceProtocol: Service {
    func fetchDashboardSummary() async throws -> DashboardSummary
}

final class DashboardService: DashboardServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func fetchDashboardSummary() async throws -> DashboardSummary {
        return try await networkManager.request(.dashboardSummary, method: .get)
    }
}

// In Features/Home/ViewModels/HomeViewModel.swift
final class HomeViewModel: ObservableObject {
    private let dashboardService: DashboardServiceProtocol
    
    init(dashboardService: DashboardServiceProtocol) {
        self.dashboardService = dashboardService
        // Don't call loadDashboard() here - let the view trigger it
    }
    
    func loadDashboard() {
        currentTask = Task { @MainActor in
            self.data = try await dashboardService.fetchDashboardSummary()
        }
    }
}

// In View - explicit service injection
HomeView(
    viewModel: HomeViewModel(dashboardService: DashboardService()),
    coordinator: homeCoordinator
)
.onAppear {
    if viewModel.data == nil {
        viewModel.loadDashboard()
    }
}
```

### 8. Network Layer Rules
- ✅ **ALWAYS** use `NetworkManager.shared.request()` for API calls (via Services)
- ✅ Define all endpoints in `APIEndpoint.swift`
- ✅ Network calls should ONLY be in Services, never in ViewModels
- ✅ Handle errors with proper error types
- ✅ JWT tokens are automatically injected
- ✅ 401 errors trigger automatic token refresh
- ❌ **NEVER** make direct Alamofire calls
- ❌ **NEVER** manually handle JWT token injection
- ❌ **NEVER** hardcode API URLs

### 9. Code Organization Rules
- ✅ **ALWAYS** follow the feature-based folder structure
- ✅ Each feature has: Coordinator/, ViewModels/, Views/ folders
- ✅ Place shared code in Core/
- ✅ Place reusable UI in TranspotsUI module
- ✅ Use meaningful file and type names
- ❌ **NEVER** create files outside the established structure
- ❌ **NEVER** mix concerns (e.g., network code in views)

### 10. SwiftUI Best Practices
- ✅ Use `@Environment` for dependency injection
- ✅ Use `@StateObject` for object ownership
- ✅ Use `@ObservedObject` for passed objects
- ✅ Use `@State` for local view state
- ✅ Extract complex views into private computed properties to keep `body` clean
- ✅ Use `@ViewBuilder` for private properties that return conditional views
- ✅ Extract complex views into separate components
- ✅ Use `.background()` modifier instead of ZStack for simple backgrounds
- ✅ Use `Group` for conditional content without layout effects
- ❌ **NEVER** create massive view bodies (>50 lines)
- ❌ **NEVER** use force unwrapping (!)
- ❌ **NEVER** use ZStack when a simple modifier will do (e.g., `.background()`)

**Clean Body Pattern:**
```swift
struct MyView: View {
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Title")
                .toolbar { toolbarContent }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .loading: loadingView
        case .loaded(let data): dataView(data)
        }
    }
    
    private var loadingView: some View {
        ProgressView()
    }
    
    private func dataView(_ data: Data) -> some View {
        ScrollView {
            // content
        }
    }
}
```

### 11. Naming Conventions
- ✅ Views: `*View.swift` (e.g., `HomeView.swift`)
- ✅ ViewModels: `*ViewModel.swift` (e.g., `HomeViewModel.swift`)
- ✅ Coordinators: `*Coordinator.swift` (e.g., `HomeCoordinator.swift`)
- ✅ Use descriptive names for functions and variables
- ✅ Use camelCase for variables and functions
- ✅ Use PascalCase for types
- ❌ **NEVER** use abbreviations unless widely known

---

## Architecture

### MVVM + Coordinator Pattern
- **Model**: Data models and business logic
- **View**: SwiftUI views
- **ViewModel**: Business logic and state management
- **Coordinator**: Navigation and flow control

## Project Structure

```
transpots-dispatch-ios/
├── Transpots Dispatch/                    # Main app target
│   ├── Core/
│   │   ├── Coordinator/
│   │   │   ├── Coordinator.swift          # Base coordinator protocol
│   │   │   ├── AppCoordinator.swift       # Main app coordinator
│   │   │   └── TabBarCoordinator.swift    # Tab bar navigation coordinator
│   │   ├── Network/
│   │   │   ├── NetworkManager.swift       # Main networking layer
│   │   │   ├── AuthInterceptor.swift      # JWT token & refresh handling
│   │   │   ├── APIEndpoint.swift          # API endpoint definitions
│   │   │   ├── NetworkError.swift         # Network error types
│   │   │   └── Models/
│   │   │       └── RefreshTokenResponse.swift
│   │   ├── Managers/
│   │   │   └── TokenManager.swift         # Secure token storage (Keychain)
│   │   ├── Services/
│   │   │   ├── Service.swift              # Base service protocol
│   │   │   └── Dashboard/
│   │   │       ├── DashboardService.swift # Dashboard API service
│   │   │       └── DashboardModels.swift  # Dashboard data models
│   │   │   # Add more service folders as needed (Orders/, Profile/, etc.)
│   │   ├── Extensions/
│   │   │   └── Notification+Extensions.swift
│   │   └── Launch/
│   │       └── LaunchScreenView.swift     # Launch screen
│   ├── Features/
│   │   └── Home/
│   │       ├── Coordinator/
│   │       │   └── HomeCoordinator.swift
│   │       ├── ViewModels/
│   │       │   └── HomeViewModel.swift
│   │       └── Views/
│   │           └── HomeView.swift
│   │           └── HomeDetailView.swift (example)
│   │   # Add more features as needed (Orders/, Profile/, Trips/, etc.)
│   └── Transpots_DispatchApp.swift        # App entry point
│
└── TranspotsUI/                           # Reusable UI module (Swift Package)
    ├── Package.swift                      # Package manifest
    └── Sources/
        └── TranspotsUI/
            ├── AppSymbols.swift           # Centralized SF Symbols
            ├── AppTheme.swift             # Theme system (colors, fonts, spacing, radius)
            ├── ThemeEnvironmentKey.swift  # Theme environment key
            ├── StatCard.swift             # Stat card component
            └── SectionCard.swift          # Section card component
            # Add more reusable components here:
            # - Buttons (PrimaryButton, SecondaryButton, etc.)
            # - Cards (OrderCard, ProfileCard, etc.)
            # - Loading indicators
            # - Form components
            # - etc.
```

## Features

### Network Layer
- **Alamofire Integration**: Clean abstraction over Alamofire
- **JWT Token Management**: Automatic token injection in requests
- **Refresh Token Flow**: Auto-retry on 401 with refresh token
- **Secure Storage**: Tokens stored in iOS Keychain
- **Error Handling**: Comprehensive error types and handling
- **Auto Logout**: Automatic logout on refresh token failure

### Navigation
- **Coordinator Pattern**: Decoupled navigation logic
- **Tab Bar**: Three main tabs (Home, Orders, Profile)
- **Deep Linking Ready**: Easy to extend for deep linking

### Launch Screen
- Custom launch screen with app branding
- 2-second display before main app loads

## Network Layer Usage

### Making API Requests

```swift
// GET request with response
let response: YourModel = try await NetworkManager.shared.request(
    .yourEndpoint,
    method: .get
)

// POST request with parameters
let response: YourModel = try await NetworkManager.shared.request(
    .yourEndpoint,
    method: .post,
    parameters: ["key": "value"]
)
```

### Adding New Endpoints

Edit `APIEndpoint.swift`:

```swift
enum APIEndpoint {
    case refreshToken
    case yourNewEndpoint
    
    private var path: String {
        switch self {
        case .refreshToken:
            return "/auth/refresh"
        case .yourNewEndpoint:
            return "/your/path"
        }
    }
}
```

### Token Management

The network layer automatically:
1. Injects JWT token in Authorization header
2. Detects 401 responses
3. Attempts token refresh
4. Retries original request with new token
5. Logs out user if refresh fails

## Dependencies

- **Alamofire 5.9.1+**: Networking
- **iOS 17.6+**: Minimum deployment target

## Getting Started

1. Open `Transpots Dispatch.xcodeproj` in Xcode
2. Wait for Swift Package Manager to resolve dependencies
3. Update the base URL in `APIEndpoint.swift`
4. Build and run (⌘R)

## Adding New Features

### Create a New Tab

1. Create feature folder structure:
   ```
   Features/YourFeature/
   ├── Coordinator/YourFeatureCoordinator.swift
   ├── ViewModels/YourFeatureViewModel.swift
   └── Views/YourFeatureView.swift
   ```

2. Add coordinator to `TabBarCoordinator.swift`

### Create a New Service

1. Create service file in appropriate feature folder
2. Use `NetworkManager.shared.request()` for API calls
3. Handle errors appropriately

## Notes

- All tokens are stored securely in iOS Keychain
- Network requests automatically include JWT token
- 401 errors trigger automatic token refresh
- Failed refresh triggers user logout
- Launch screen displays for 2 seconds on app start

## Future Enhancements

- [ ] Add authentication flow (Login/Register)
- [ ] Implement specific services for each feature
- [ ] Add loading states and error UI
- [ ] Implement push notifications
- [ ] Add offline support
- [ ] Add unit tests
- [ ] Add UI tests
