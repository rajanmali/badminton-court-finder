import SwiftUI
@preconcurrency import MapLibre

// MARK: - VenueMapView

/// The map presentation of the venue list. Ports `VenueMap.tsx`.
///
/// Renders the styled MapTiler basemap plus venue pins. Each venue is one point
/// feature in a single GeoJSON-style shape source ("venues") with three stacked
/// style layers — white rings, data-driven green/blue dots, first-letter labels.
/// Tapping a pin reads its `id`/`name` and forwards them via ``onVenueTap`` so
/// the caller can push the venue detail.
///
/// ## No-key behaviour
/// When ``AppConfig/maptilerAPIKey`` is empty (CI placeholder secrets, or a
/// local checkout that hasn't set the key), the map cannot load a MapTiler
/// style. Rather than render a blank `MLNMapView` that silently fails, we show
/// an inline centered grey message — the parity of RN's
/// "EXPO_PUBLIC_MAPTILER_API_KEY is not set" state.
struct VenueMapView: View {
    let venues: [VenueListItem]
    let userCoords: UserCoords?
    let onVenueTap: (String, String) -> Void

    var body: some View {
        if AppConfig.maptilerAPIKey.isEmpty {
            Text("Maptiler API key is not set")
                .font(.system(size: Typography.Size.md))
                .foregroundStyle(Color.smashTextSecondary)
                .multilineTextAlignment(.center)
                .padding(Spacing.lg)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VenueMapRepresentable(
                venues: venues,
                userCoords: userCoords,
                onVenueTap: onVenueTap
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Pin feature building (pure helpers)

/// The attribute dictionary attached to a venue's point feature.
///
/// Factored out as a pure function (no MapLibre types) so the data-driven
/// values that the style layers depend on — `dedicated` as `0|1` and the
/// uppercased first letter — are unit-testable without instantiating
/// `MLNPointFeature`. Mirrors `VenueMap.tsx`'s feature `properties`, plus a
/// precomputed `letter` (avoids a fragile MGL string-slice expression in the
/// symbol layer).
func pinAttributes(for venue: VenueListItem) -> [String: Sendable] {
    [
        "id": venue.id,
        "name": venue.name,
        "dedicated": venue.dedicatedBadminton ? 1 : 0,
        "letter": String(venue.name.prefix(1)).uppercased(),
    ]
}

/// Builds one `MLNPointFeature` per venue, the shape backing the "venues"
/// source. Coordinate uses CLLocationCoordinate2D (lat, lng); attributes come
/// from ``pinAttributes(for:)``.
func makePointFeatures(_ venues: [VenueListItem]) -> [MLNPointFeature] {
    venues.map { venue in
        let feature = MLNPointFeature()
        feature.coordinate = CLLocationCoordinate2D(latitude: venue.lat, longitude: venue.lng)
        feature.attributes = pinAttributes(for: venue)
        return feature
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
/// ``LiveLocationService`` (CLLocationManagerDelegate).
struct VenueMapRepresentable: UIViewRepresentable {
    let venues: [VenueListItem]
    let userCoords: UserCoords?
    let onVenueTap: (String, String) -> Void

    /// [lng, lat] order in MapLibre/GeoJSON; here we keep CLLocationCoordinate2D
    /// (lat, lng). Default fallback is Sydney CBD, matching `VenueMap.tsx`.
    private static let sydney = CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
    private static let defaultZoom: Double = 10

    /// The shared source id all three pin layers reference.
    private static let sourceID = "venues"

    func makeCoordinator() -> Coordinator {
        Coordinator(venues: venues, onVenueTap: onVenueTap)
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

        // Tap-to-navigate: a single tap is hit-tested against the pin layers.
        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        mapView.addGestureRecognizer(tap)

        return mapView
    }

    func updateUIView(_ mapView: MLNMapView, context: Context) {
        // Keep the coordinator's view of the world current so a later
        // didFinishLoading (and the tap handler) act on the freshest values.
        context.coordinator.venues = venues
        context.coordinator.onVenueTap = onVenueTap

        // When the style is already loaded the source exists; rebuild its shape
        // so filtered-out venues disappear (matching RN). If the style hasn't
        // finished loading yet, didFinishLoading will build from these venues.
        if let source = context.coordinator.shapeSource {
            source.shape = MLNShapeCollectionFeature(shapes: makePointFeatures(venues))
        }
    }

    // MARK: Coordinator

    /// MapLibre map delegate + tap target.
    ///
    /// Holds the live `venues` and `onVenueTap` (refreshed in `updateUIView`)
    /// and a weak reference to the created shape source so the source can be
    /// mutated when the filtered list changes. Delegate callbacks come from an
    /// un-annotated ObjC framework, so they are `nonisolated` and hop back with
    /// `MainActor.assumeIsolated` — the established `CLLocationManager` pattern.
    final class Coordinator: NSObject, MLNMapViewDelegate {
        var venues: [VenueListItem]
        var onVenueTap: (String, String) -> Void
        weak var shapeSource: MLNShapeSource?

        init(venues: [VenueListItem], onVenueTap: @escaping (String, String) -> Void) {
            self.venues = venues
            self.onVenueTap = onVenueTap
        }

        // MARK: Layer setup

        nonisolated func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
            MainActor.assumeIsolated {
                let source = MLNShapeSource(
                    identifier: sourceID,
                    shape: MLNShapeCollectionFeature(shapes: makePointFeatures(venues)),
                    options: nil
                )
                style.addSource(source)
                shapeSource = source

                // Layers added in stacking order: rings (bottom), dots, labels.
                style.addLayer(Self.makeRingsLayer(source: source))
                style.addLayer(Self.makeDotsLayer(source: source))
                style.addLayer(Self.makeLabelsLayer(source: source))
            }
        }

        /// White halo behind each dot. Constant radius/colour/opacity.
        private static func makeRingsLayer(source: MLNShapeSource) -> MLNCircleStyleLayer {
            let layer = MLNCircleStyleLayer(identifier: "venue-rings", source: source)
            layer.circleRadius = NSExpression(forConstantValue: 13)
            layer.circleColor = NSExpression(forConstantValue: UIColor.white)
            layer.circleOpacity = NSExpression(forConstantValue: 0.9)
            return layer
        }

        /// The coloured dot. Data-driven: green (#00C853) when `dedicated == 1`,
        /// else multi-sport blue (#1565C0).
        private static func makeDotsLayer(source: MLNShapeSource) -> MLNCircleStyleLayer {
            let layer = MLNCircleStyleLayer(identifier: "venue-dots", source: source)
            layer.circleRadius = NSExpression(forConstantValue: 9)
            let green = UIColor(red: 0x00 / 255.0, green: 0xC8 / 255.0, blue: 0x53 / 255.0, alpha: 1)
            let blue = UIColor(red: 0x15 / 255.0, green: 0x65 / 255.0, blue: 0xC0 / 255.0, alpha: 1)
            layer.circleColor = NSExpression(
                format: "MGL_MATCH(dedicated, 1, %@, %@)", green, blue
            )
            return layer
        }

        /// First-letter white label centred on each pin, always shown.
        private static func makeLabelsLayer(source: MLNShapeSource) -> MLNSymbolStyleLayer {
            let layer = MLNSymbolStyleLayer(identifier: "venue-labels", source: source)
            layer.text = NSExpression(forKeyPath: "letter")
            layer.textFontSize = NSExpression(forConstantValue: 11)
            layer.textColor = NSExpression(forConstantValue: UIColor.white)
            layer.textAllowsOverlap = NSExpression(forConstantValue: true)
            return layer
        }

        // MARK: Tap handling

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            MainActor.assumeIsolated {
                guard let mapView = gesture.view as? MLNMapView else { return }
                let point = gesture.location(in: mapView)
                let features = mapView.visibleFeatures(
                    at: point,
                    styleLayerIdentifiers: ["venue-dots", "venue-rings"]
                )
                guard let feature = features.first,
                      let id = feature.attribute(forKey: "id") as? String,
                      let name = feature.attribute(forKey: "name") as? String
                else { return }
                onVenueTap(id, name)
            }
        }
    }
}
