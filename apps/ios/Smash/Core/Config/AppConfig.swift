import Foundation

/// Static configuration read from the app's Info.plist at launch.
///
/// Values are injected into Info.plist from xcconfig build settings, which
/// in turn read from Secrets.xcconfig (gitignored, copied from
/// Secrets.example.xcconfig before each build).
///
/// xcconfig URL gotcha: `//` begins a comment in xcconfig files, so
/// `http://...` would be silently truncated to `http:`. The Shared.xcconfig
/// uses `$()` between the two slashes as a workaround. AppConfig's DEBUG
/// assertion catches this early if the workaround is ever omitted.
enum AppConfig {

    /// The base URL for all API requests, including the `/api/v1` path prefix.
    ///
    /// Falls back to `http://localhost:3000/api/v1` if the key is absent or
    /// produces an invalid URL (this should never happen given the xcconfig
    /// default, but release builds must not crash).
    static var apiBaseURL: URL {
        let fallback = URL(string: "http://localhost:3000/api/v1")!

        guard
            let raw = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
            !raw.isEmpty
        else {
            return fallback
        }

        guard let url = URL(string: raw) else {
            return fallback
        }

#if DEBUG
        assert(!raw.isEmpty, "API_BASE_URL is empty — check xcconfig injection.")
        assert(
            url.host != nil,
            "API_BASE_URL '\(raw)' has no host — did the xcconfig '//' comment truncation bug strike? Use '$()' between the slashes."
        )
#endif

        return url.host != nil ? url : fallback
    }

    /// The Maptiler API key used by the map screen.
    ///
    /// May be empty in local development if the key has not been added to
    /// Secrets.xcconfig yet; the map will simply fail to load tiles.
    static var maptilerAPIKey: String {
        Bundle.main.object(forInfoDictionaryKey: "MAPTILER_API_KEY") as? String ?? ""
    }

    /// The Sentry DSN used for error tracking.
    ///
    /// Empty in Debug builds and when no DSN has been configured in
    /// Secrets.xcconfig. `SentrySDK.start` is only called in Release builds
    /// when this is non-empty — see `SmashApp.init()`.
    static var sentryDSN: String {
        Bundle.main.object(forInfoDictionaryKey: "SENTRY_DSN") as? String ?? ""
    }
}
