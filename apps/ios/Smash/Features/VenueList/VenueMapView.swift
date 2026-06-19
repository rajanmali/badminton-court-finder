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
    /// The currently selected venue id, if any. Drives the enlarged + ringed
    /// "selected" pin state (passes through to the dot/ring style layers).
    var selectedID: String?
    let onVenueTap: (String, String) -> Void

    var body: some View {
        if AppConfig.maptilerAPIKey.isEmpty {
            Text("Maptiler API key is not set")
                .font(.system(size: Typography.Size.md))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(Spacing.lg)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VenueMapRepresentable(
                venues: venues,
                userCoords: userCoords,
                selectedID: selectedID,
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
/// values that the style layers depend on — `dedicated` as `0|1`, `selected` as
/// `0|1`, and the uppercased first letter — are unit-testable without
/// instantiating `MLNPointFeature`. Mirrors `VenueMap.tsx`'s feature
/// `properties`, plus a precomputed `letter` (avoids a fragile MGL string-slice
/// expression in the symbol layer).
///
/// - Parameter selectedID: when this venue's id matches, `selected` is `1` so
///   the data-driven dot/ring layers render the enlarged + ringed state.
func pinAttributes(for venue: VenueListItem, selectedID: String? = nil) -> [String: Sendable] {
    [
        "id": venue.id,
        "name": venue.name,
        "dedicated": venue.dedicatedBadminton ? 1 : 0,
        "selected": venue.id == selectedID ? 1 : 0,
        "letter": String(venue.name.prefix(1)).uppercased(),
        "price_label": venue.priceFrom.map { cents in
            "$\(Int((Double(cents) / 100).rounded()))"
        } ?? "",
    ]
}

/// Builds one `MLNPointFeature` per venue, the shape backing the "venues"
/// source. Coordinate uses CLLocationCoordinate2D (lat, lng); attributes come
/// from ``pinAttributes(for:selectedID:)``.
func makePointFeatures(_ venues: [VenueListItem], selectedID: String? = nil) -> [MLNPointFeature] {
    venues.map { venue in
        let feature = MLNPointFeature()
        feature.coordinate = CLLocationCoordinate2D(latitude: venue.lat, longitude: venue.lng)
        feature.attributes = pinAttributes(for: venue, selectedID: selectedID)
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
    /// The selected venue id. When it changes, `updateUIView` rebuilds the shape
    /// source so the matching feature's `selected` flag flips and the selected
    /// pin grows/gains its ring.
    var selectedID: String?
    let onVenueTap: (String, String) -> Void

    /// [lng, lat] order in MapLibre/GeoJSON; here we keep CLLocationCoordinate2D
    /// (lat, lng). Default fallback is Sydney CBD, matching `VenueMap.tsx`.
    private static let sydney = CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
    private static let defaultZoom: Double = 10

    /// The shared source id all three pin layers reference.
    private static let sourceID = "venues"

    func makeCoordinator() -> Coordinator {
        Coordinator(venues: venues, selectedID: selectedID, onVenueTap: onVenueTap)
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
        context.coordinator.selectedID = selectedID
        context.coordinator.onVenueTap = onVenueTap

        // When the style is already loaded the source exists; rebuild its shape
        // so filtered-out venues disappear (matching RN) and the selected pin's
        // `selected` flag flips. If the style hasn't finished loading yet,
        // didFinishLoading will build from these venues/selection.
        if let source = context.coordinator.shapeSource {
            source.shape = MLNShapeCollectionFeature(
                shapes: makePointFeatures(venues, selectedID: selectedID)
            )
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
        var selectedID: String?
        var onVenueTap: (String, String) -> Void
        /// Strong reference to the "venues" source. It MUST be strong: when the
        /// async venue load resolves *after* the style finishes loading, the
        /// source is built empty at `didFinishLoading` and only populated by the
        /// later `updateUIView` refresh. A `weak` reference here can deallocate
        /// before that refresh (MapLibre's `MLNStyle` does not guarantee a strong
        /// hold once the local `let source` goes out of scope), making the
        /// refresh silently no-op and leaving the map with zero pins.
        var shapeSource: MLNShapeSource?

        init(
            venues: [VenueListItem],
            selectedID: String?,
            onVenueTap: @escaping (String, String) -> Void
        ) {
            self.venues = venues
            self.selectedID = selectedID
            self.onVenueTap = onVenueTap
        }

        // MARK: Layer setup

        nonisolated func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
            MainActor.assumeIsolated {
                let source = MLNShapeSource(
                    identifier: sourceID,
                    shape: MLNShapeCollectionFeature(
                        shapes: makePointFeatures(venues, selectedID: selectedID)
                    ),
                    options: nil
                )
                style.addSource(source)
                shapeSource = source

                // Layers added in stacking order: the selected-pin ring (bottom,
                // a coloured halo only on the selected feature), white rings,
                // coloured dots, then letter labels (top).
                style.addLayer(Self.makeSelectedRingLayer(source: source))
                style.addLayer(Self.makeRingsLayer(source: source))
                style.addLayer(Self.makeDotsLayer(source: source))
                style.addLayer(Self.makeLabelsLayer(source: source))
                style.addLayer(Self.makePriceLayer(source: source))
            }
        }

        // ── Pin palette (BWF court) ────────────────────────────────────────
        // dedicated → greenBright #2BB183, multi-sport → court grey #6B7178.
        private static let dedicatedColor =
            UIColor(red: 0x2B / 255.0, green: 0xB1 / 255.0, blue: 0x83 / 255.0, alpha: 1)
        private static let multiSportColor =
            UIColor(red: 0x6B / 255.0, green: 0x71 / 255.0, blue: 0x78 / 255.0, alpha: 1)

        /// A coloured halo drawn only behind the *selected* pin, so the selection
        /// reads as larger + ringed.
        ///
        /// Selection is expressed by a `predicate` (`selected == 1`) that filters
        /// the layer to only the selected feature — NOT by a data-driven
        /// `circleRadius` keyed on `selected`. A `forMLNMatchingKey:` match on the
        /// numeric `selected` attribute evaluates to its `default` (radius 0) on
        /// MapLibre 6.x, which is what made the redesigned pins vanish. Constant
        /// radius + a predicate filter is the robust form: the halo is a fixed 17
        /// and simply isn't drawn for unselected pins. The ring colour stays
        /// data-driven on `dedicated` (that match form is known-good).
        private static func makeSelectedRingLayer(source: MLNShapeSource) -> MLNCircleStyleLayer {
            let layer = MLNCircleStyleLayer(identifier: "venue-selected-ring", source: source)
            // Only render for the selected feature.
            layer.predicate = NSPredicate(format: "selected == 1")
            // Constant radius — the wide halo behind the selected pin.
            layer.circleRadius = NSExpression(forConstantValue: 17)
            // Colour by dedicated/multi-sport so the ring matches the dot.
            layer.circleColor = NSExpression(
                forMLNMatchingKey: NSExpression(forKeyPath: "dedicated"),
                in: [NSExpression(forConstantValue: 1):
                        NSExpression(forConstantValue: dedicatedColor)],
                default: NSExpression(forConstantValue: multiSportColor)
            )
            // Soft coloured halo.
            layer.circleOpacity = NSExpression(forConstantValue: 0.35)
            return layer
        }

        /// White halo behind each dot. Constant radius/colour/opacity — the
        /// selected pin reads as raised via the coloured selected-ring layer
        /// beneath it, not via a per-feature ring size.
        private static func makeRingsLayer(source: MLNShapeSource) -> MLNCircleStyleLayer {
            let layer = MLNCircleStyleLayer(identifier: "venue-rings", source: source)
            layer.circleRadius = NSExpression(forConstantValue: 13)
            layer.circleColor = NSExpression(forConstantValue: UIColor.white)
            layer.circleOpacity = NSExpression(forConstantValue: 0.9)
            return layer
        }

        /// The coloured dot. Data-driven: greenBright (#2BB183) when
        /// `dedicated == 1`, else court grey (#6B7178). Radius is constant — a
        /// data-driven radius keyed on the numeric `selected` attribute resolved
        /// to 0 on MapLibre 6.x and hid every dot, so selection is now conveyed
        /// by the coloured selected-ring layer instead.
        private static func makeDotsLayer(source: MLNShapeSource) -> MLNCircleStyleLayer {
            let layer = MLNCircleStyleLayer(identifier: "venue-dots", source: source)
            layer.circleRadius = NSExpression(forConstantValue: 9)
            // Data-driven match on the `dedicated` attribute (1 → green, else grey).
            // Built with MapLibre's typed match initializer rather than an
            // NSExpression(format:) string: MapLibre 6.x renamed the MGL_* custom
            // expression functions to MLN_*, so the old "MGL_MATCH(...)" format
            // string is unknown to the parser and throws at style-load time. The
            // typed initializer avoids the string parser entirely.
            layer.circleColor = NSExpression(
                forMLNMatchingKey: NSExpression(forKeyPath: "dedicated"),
                in: [NSExpression(forConstantValue: 1):
                        NSExpression(forConstantValue: dedicatedColor)],
                default: NSExpression(forConstantValue: multiSportColor)
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

        /// Price label below each pin. Shows "$X" when the venue has a price; nothing
        /// when `price_label` is "". A text halo gives legibility over map tiles.
        private static func makePriceLayer(source: MLNShapeSource) -> MLNSymbolStyleLayer {
            let layer = MLNSymbolStyleLayer(identifier: "venue-prices", source: source)
            layer.text = NSExpression(forKeyPath: "price_label")
            // Position below the pin: MapLibre text offset is in em units (1em ≈ font size).
            // With a 10pt font, 2.2em ≈ 22pt below the anchor point — just beneath the dot.
            layer.textOffset = NSExpression(forConstantValue: CGVector(dx: 0, dy: 2.2))
            layer.textFontSize = NSExpression(forConstantValue: 10)
            layer.textColor = NSExpression(forConstantValue: UIColor.white)
            // Halo for legibility over the map basemap.
            layer.textHaloColor = NSExpression(forConstantValue: UIColor.black.withAlphaComponent(0.55))
            layer.textHaloWidth = NSExpression(forConstantValue: 1.5)
            layer.textAllowsOverlap = NSExpression(forConstantValue: true)
            // textIgnoresPlacement prevents the symbol from hiding other symbols.
            layer.textIgnoresPlacement = NSExpression(forConstantValue: true)
            return layer
        }

        // MARK: Tap handling

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            MainActor.assumeIsolated {
                guard let mapView = gesture.view as? MLNMapView else { return }
                let point = gesture.location(in: mapView)
                let features = mapView.visibleFeatures(
                    at: point,
                    styleLayerIdentifiers: ["venue-dots", "venue-rings", "venue-selected-ring"]
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
