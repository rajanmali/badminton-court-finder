import SwiftUI

// MARK: - FilterBar

/// A three-row filter control that mirrors the RN `FilterBar.tsx` component.
///
/// - **Distance**: Any / 5 km / 10 km / 20 km chips. Non-"Any" chips are
///   disabled when location permission was denied.
/// - **Max price**: Any / ≤$30 / ≤$35 / ≤$40 chips.
/// - **Dedicated**: a toggle bound to `filters.dedicatedOnly`.
///
/// The parent holds the model in `@State` and passes bindings via `@Bindable`.
struct FilterBar: View {

    @Binding var filters: FilterState
    let locationDenied: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            distanceRow
            if locationDenied {
                locationDeniedHint
            }
            Divider().padding(.vertical, Spacing.xs)
            priceRow
            Divider().padding(.vertical, Spacing.xs)
            dedicatedRow
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.smashSurface)
        .overlay(alignment: .bottom) {
            Rectangle()
                .frame(height: 0.5)
                .foregroundStyle(Color.smashBorder)
        }
    }

    // MARK: Rows

    private var distanceRow: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Distance")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.smashText)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    let options: [(String, Double?)] = [
                        ("Any", nil),
                        ("5 km", 5),
                        ("10 km", 10),
                        ("20 km", 20),
                    ]
                    ForEach(options, id: \.0) { title, value in
                        FilterBarChip(
                            title: title,
                            isActive: filters.radiusKm == value,
                            isDisabled: locationDenied && value != nil
                        ) {
                            filters.radiusKm = value
                        }
                    }
                }
            }
        }
    }

    private var locationDeniedHint: some View {
        Text("Enable location to filter by distance")
            .font(.system(size: 11))
            .foregroundStyle(Color.smashWarning)
            .padding(.top, Spacing.xs)
    }

    private var priceRow: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Max price")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.smashText)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    let options: [(String, Int?)] = [
                        ("Any", nil),
                        ("≤$30", 3000),
                        ("≤$35", 3500),
                        ("≤$40", 4000),
                    ]
                    ForEach(options, id: \.0) { title, value in
                        FilterBarChip(
                            title: title,
                            isActive: filters.maxPriceCents == value,
                            isDisabled: false
                        ) {
                            filters.maxPriceCents = value
                        }
                    }
                }
            }
        }
    }

    private var dedicatedRow: some View {
        Toggle("Dedicated courts only", isOn: $filters.dedicatedOnly)
            .tint(.smashPrimary)
            .font(.system(size: 14))
            .foregroundStyle(Color.smashText)
    }
}

// MARK: - FilterBarChip

/// A rounded-capsule button chip used in `FilterBar`.
///
/// Visual states:
/// - **Active**: `.smashPrimary` background, white text.
/// - **Inactive**: white/surface background, `.smashBorder` stroke, dark text.
/// - **Disabled**: light grey background, faint text, non-interactive.
///
/// Note: this is the legacy filter chip local to `FilterBar`. The redesign's
/// reusable `FilterChip` lives in `DesignSystem/Components.swift`; screens are
/// rewired to it in a later redesign PR.
private struct FilterBarChip: View {
    let title: String
    let isActive: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(foregroundColor)
                .padding(.horizontal, Spacing.sm + Spacing.xs)
                .padding(.vertical, Spacing.xs + 2)
                .background(backgroundColor, in: Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(strokeColor, lineWidth: isActive ? 0 : 1)
                )
        }
        .disabled(isDisabled)
    }

    private var foregroundColor: Color {
        if isDisabled {
            return Color.smashTextSecondary.opacity(0.4)
        }
        return isActive ? .white : .smashText
    }

    private var backgroundColor: Color {
        if isDisabled {
            return Color.smashBorder.opacity(0.3)
        }
        return isActive ? .smashPrimary : .smashBackground
    }

    private var strokeColor: Color {
        if isDisabled {
            return Color.smashBorder.opacity(0.5)
        }
        return isActive ? .clear : .smashBorder
    }
}

// MARK: - Previews

#Preview("FilterBar — location available") {
    @Previewable @State var filters = FilterState.default
    FilterBar(filters: $filters, locationDenied: false)
        .padding()
}

#Preview("FilterBar — location denied") {
    @Previewable @State var filters = FilterState(
        radiusKm: nil,
        maxPriceCents: 3500,
        dedicatedOnly: true
    )
    FilterBar(filters: $filters, locationDenied: true)
        .padding()
}
