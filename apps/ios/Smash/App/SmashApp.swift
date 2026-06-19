import SwiftUI
#if !DEBUG
@preconcurrency import Sentry
#endif

@main
struct SmashApp: App {

    init() {
        #if !DEBUG
        let dsn = AppConfig.sentryDSN
        if !dsn.isEmpty {
            SentrySDK.start { options in
                options.dsn = dsn
                options.environment = "production"
            }
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

// MARK: - Navigation routes

/// Typed navigation destinations for the app's `NavigationStack`.
///
/// Adding a screen = adding a case here + a `.navigationDestination` arm in
/// ``RootView``. Pushing is then `NavigationLink(value: Route.…)`.
enum Route: Hashable {
    case venueDetail(id: String, name: String)
}

// MARK: - Root view

/// Hosts the app-wide `NavigationStack` and maps ``Route`` values to screens.
///
/// The stack's root is ``RootTabView``, which owns the shared venue model and
/// the floating List/Map tab bar. The stack carries an explicit `path` binding
/// so both `NavigationLink(value:)` (list rows) and programmatic callers (the
/// map's pin-tap handler, routed through `RootTabView`) push onto the same path.
/// Pushing the Venue Detail covers the whole tab view, so the floating tab bar
/// is naturally hidden while Detail is open.
///
/// ## First-run onboarding
/// On first launch (when `preferences.hasSeenOnboarding == false`) the
/// ``OnboardingView`` is presented over the whole app via a `fullScreenCover`.
/// The cover's `isPresented` binding is derived from the preference: it reads
/// `true` while onboarding has not been seen, and setting it `false` is a no-op
/// (onboarding dismisses itself by setting `hasSeenOnboarding = true`, which
/// flips the derived binding to `false`). Because `preferences` is an
/// `@Observable`, that write re-runs `body` and the cover dismisses.
struct RootView: View {
    @State private var path: [Route] = []
    @State private var windowSafeAreaInsets: EdgeInsets = EdgeInsets()
    @Environment(\.preferences) private var preferences

    var body: some View {
        NavigationStack(path: $path) {
            RootTabView(path: $path)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case let .venueDetail(id, name):
                        VenueDetailScreen(venueId: id, venueName: name)
                    }
                }
        }
        .fullScreenCover(isPresented: showOnboarding) {
            OnboardingView()
        }
        // Capture the window safe area BEFORE any ignoresSafeArea modifier
        // consumes it, then propagate it down the hierarchy via environment so
        // views inside ignoresSafeArea contexts (e.g. the Detail hero chrome)
        // can still position themselves correctly.
        .background {
            GeometryReader { proxy in
                Color.clear
                    .onAppear { windowSafeAreaInsets = proxy.safeAreaInsets }
                    .onChange(of: proxy.safeAreaInsets) { _, insets in
                        windowSafeAreaInsets = insets
                    }
            }
        }
        .environment(\.windowSafeAreaInsets, windowSafeAreaInsets)
    }

    /// `true` while the user has not completed onboarding. The setter is a no-op:
    /// the cover is dismissed by ``OnboardingView`` setting `hasSeenOnboarding`,
    /// not by SwiftUI writing through this binding.
    private var showOnboarding: Binding<Bool> {
        Binding(
            get: { !preferences.hasSeenOnboarding },
            set: { _ in }
        )
    }
}
