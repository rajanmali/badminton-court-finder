import SwiftUI
@preconcurrency import MapLibre

// MARK: - VenueMapView

/// The map presentation of the venue list. Ports the base of `VenueMap.tsx`.
///
/// This PR wires up only the dependency, the styled basemap, and the camera —
/// pins, layers, and the tap handler are deferred to the next PR (matching the
/// orchestration plan). The public surface therefore takes only `userCoords`
/// for now; `venues` / `onVenueTap` arrive with the pin layer.
///
/// ## No-key behaviour
/// When ``AppConfig/maptilerAPIKey`` is empty (CI placeholder secrets, or a
/// local checkout that hasn't set the key), the map cannot load a MapTiler
/// style. Rather than render a blank `MLNMapView` that silently fails, we show
/// an inline centered grey message — the parity of RN's
/// "EXPO_PUBLIC_MAPTILER_API_KEY is not set" state.
struct VenueMapView: View {
    let userCoords: UserCoords?

    var body: some View {
        if AppConfig.maptilerAPIKey.isEmpty {
            Text("Maptiler API key is not set")
                .font(.system(size: Typography.Size.md))
                .foregroundStyle(Color.smashTextSecondary)
                .multilineTextAlignment(.center)
                .padding(Spacing.lg)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VenueMapRepresentable(userCoords: userCoords)
                .ignoresSafeArea()
        }
    }
}

// MARK: - VenueMapRepresentable

/// Bridges MapLibre's UIKit-based `MLNMapView` into SwiftUI.
///
/// ## Concurrency (Swift 6.2)
/// `MLNMapView` is a `UIView`, so all access is `@MainActor`-isolated by the
/// project's default actor isolation (ADR-0010). The `MLNMapViewDelegate`
/// protocol comes from the ObjC framework and isn't annotated for Swift
/// concurrency, so the `@preconcurrency import MapLibre` above suppresses the
/// Sendable friction, and the Coordinator's delegate callbacks use the same
/// `nonisolated` + `MainActor.assumeIsolated` pattern proven in
/// ``LiveLocationService`` (CLLocationManagerDelegate). The delegate is empty
/// for now; the next PR adds `mapView(_:didFinishLoading:)` (pin layers) and
/// the tap handler.
struct VenueMapRepresentable: UIViewRepresentable {
    let userCoords: UserCoords?

    /// [lng, lat] order in MapLibre/GeoJSON; here we keep CLLocationCoordinate2D
    /// (lat, lng). Default fallback is Sydney CBD, matching `VenueMap.tsx`.
    private static let sydney = CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
    private static let defaultZoom: Double = 10

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> MLNMapView {
        let styleURL = URL(string: "https://api.maptiler.com/maps/streets-v2/style.json?key=\(AppConfig.maptilerAPIKey)")
        let mapView = MLNMapView(frame: .zero, styleURL: styleURL)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = context.coordinator

        let center = userCoords.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        } ?? Self.sydney
        mapView.setCenter(center, zoomLevel: Self.defaultZoom, animated: false)

        return mapView
    }

    func updateUIView(_ mapView: MLNMapView, context: Context) {
        // Camera is set once in makeUIView for this PR. Recentre on later
        // userCoords changes happens with the pin work; keep this minimal so the
        // dependency integration stays isolated.
    }

    // MARK: Coordinator

    /// MapLibre map delegate. Empty for this PR — the next PR adds the pin
    /// layers in `mapView(_:didFinishLoading:)` and the feature tap handler.
    final class Coordinator: NSObject, MLNMapViewDelegate {}
}
