import SwiftUI

// MARK: - FilterBar

/// A thick-glass panel with three filter rows — DISTANCE, MAX PRICE, and
/// Dedicated courts only — matching the design_handoff_smash `FilterBar`
/// (`cards.jsx`, glass level "thick", radius 24).
///
/// Public API is unchanged from the previous iteration:
/// `FilterBar(filters: Binding<FilterState>, locationDenied: Bool)`.
///
/// - **Distance row**: micro "DISTANCE" label + `FilterChip` atoms for
///   Any / 5 km / 10 km / 20 km. Non-"Any" chips are disabled (dimmed,
///   non-tappable) when `locationDenied`. A location-denied amber hint
///   appears below this row.
/// - **Max price row**: micro "MAX PRICE" label + `FilterChip` atoms for
///   Any / ≤$30 / ≤$35 / ≤$40.
/// - **Dedicated courts only**: `bolt.fill` icon + subhead label + iOS Toggle.
///
/// Rows are separated by 0.5 pt `Color.hairline` dividers.
struct FilterBar: View {

    @Binding var filters: FilterState
    let locationDenied: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            distanceRow

            if locationDenied {
                locationDeniedHint
            }

            hairlineDivider

            priceRow

            hairlineDivider

            dedicatedRow
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glass(.thick, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 16)
    }

    // MARK: - Rows

    private var distanceRow: some View {
        VStack(alignment: .leading, spacing: 7) {
            rowLabel("DISTANCE")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    let options: [(String, Double?)] = [
                        ("Any",    nil),
                        ("5 km",   5.0),
                        ("10 km", 10.0),
                        ("20 km", 20.0),
                    ]
                    ForEach(options, id: \.0) { title, value in
                        let isAny = value == nil
                        let isDisabled = locationDenied && !isAny
                        FilterChip(
                            title: title,
                            isOn: filters.radiusKm == value,
                            action: { filters.radiusKm = value }
                        )
                        .disabled(isDisabled)
                        .opacity(isDisabled ? 0.4 : 1.0)
                    }
                }
            }
        }
    }

    private var locationDeniedHint: some View {
        Text("Enable location to filter by distance")
            .font(Typography.caption)
            .foregroundStyle(Color.warning)
    }

    private var priceRow: some View {
        VStack(alignment: .leading, spacing: 7) {
            rowLabel("MAX PRICE")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    let options: [(String, Int?)] = [
                        ("Any",  nil),
                        ("≤$30", 3000),
                        ("≤$35", 3500),
                        ("≤$40", 4000),
                    ]
                    ForEach(options, id: \.0) { title, value in
                        FilterChip(
                            title: title,
                            isOn: filters.maxPriceCents == value,
                            action: { filters.maxPriceCents = value }
                        )
                    }
                }
            }
        }
    }

    private var dedicatedRow: some View {
        HStack(spacing: 7) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.green)
            Text("Dedicated courts only")
                .font(Typography.subhead)
                .tracking(-0.2)
                .foregroundStyle(Color.textPrimary)
            Spacer()
            Toggle("", isOn: $filters.dedicatedOnly)
                .labelsHidden()
                .tint(.green)
        }
    }

    // MARK: - Helpers

    /// Micro uppercase row label: 11 pt / heavy / tracking 0.5.
    private func rowLabel(_ text: String) -> some View {
        Text(text)
            .font(Typography.micro)
            .tracking(0.5)
            .textCase(.uppercase)
            .foregroundStyle(Color.textTertiary)
    }

    private var hairlineDivider: some View {
        Color.hairline
            .frame(height: 0.5)
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Previews

#Preview("FilterBar — active chips, light") {
    @Previewable @State var filters = FilterState(
        radiusKm: 10.0,
        maxPriceCents: 3500,
        dedicatedOnly: true
    )
    ZStack {
        SmashBackdrop()
        VStack {
            FilterBar(filters: $filters, locationDenied: false)
            Spacer()
        }
        .padding(.top, 40)
    }
    .preferredColorScheme(.light)
}

#Preview("FilterBar — active chips, dark") {
    @Previewable @State var filters = FilterState(
        radiusKm: 10.0,
        maxPriceCents: 3500,
        dedicatedOnly: true
    )
    ZStack {
        SmashBackdrop()
        VStack {
            FilterBar(filters: $filters, locationDenied: false)
            Spacer()
        }
        .padding(.top, 40)
    }
    .preferredColorScheme(.dark)
}

#Preview("FilterBar — location denied, light") {
    @Previewable @State var filters = FilterState(
        radiusKm: nil,
        maxPriceCents: 3500,
        dedicatedOnly: true
    )
    ZStack {
        SmashBackdrop()
        VStack {
            FilterBar(filters: $filters, locationDenied: true)
            Spacer()
        }
        .padding(.top, 40)
    }
    .preferredColorScheme(.light)
}

#Preview("FilterBar — location denied, dark") {
    @Previewable @State var filters = FilterState(
        radiusKm: nil,
        maxPriceCents: 3500,
        dedicatedOnly: true
    )
    ZStack {
        SmashBackdrop()
        VStack {
            FilterBar(filters: $filters, locationDenied: true)
            Spacer()
        }
        .padding(.top, 40)
    }
    .preferredColorScheme(.dark)
}
