import SwiftUI

// MARK: - FiltersSheet

/// The shared Filters + Sort sheet presented from both the List and Map tabs.
///
/// Bindings are wired straight to ``VenueListModel`` (`filters`, `sortOption`),
/// so every edit is **live** — the list/map behind the sheet re-renders as the
/// user changes a chip, toggle, or sort row. There is no "apply" step.
///
/// Presented via `.sheet` with `[.medium, .large]` detents and a visible drag
/// indicator. Distance/price/dedicated reuse the existing ``FilterBar``; the
/// Sort section iterates ``SortOption/allCases``.
///
/// **Location-denied behaviour (UX fix #4):**
/// - When `locationDenied`, the `.nearest` sort row is shown greyed + disabled
///   with a "Needs location" note — it cannot be selected.
/// - A quiet, dismissible re-enable banner appears near the top (once) until
///   the user taps "×" to permanently suppress it via `AppPreferences`.
struct FiltersSheet: View {
    @Binding var filters: FilterState
    @Binding var sort: SortOption
    let locationDenied: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.preferences) private var preferences

    var body: some View {
        ZStack {
            SmashBackdrop()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 18) {
                        // Quiet re-enable prompt: shown when denied and not yet dismissed.
                        if locationDenied && !preferences.locationPromptDismissed {
                            locationPromptBanner
                        }

                        FilterBar(filters: $filters, locationDenied: locationDenied)

                        sortSection
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 32)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.clear)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Filters")
                .font(Typography.title)
                .tracking(-0.8)
                .foregroundStyle(Color.textPrimary)

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(Color.textSecondary)
                    .frame(width: 32, height: 32)
                    .glass(.regular, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Done")
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, 18)
        .padding(.bottom, 10)
    }

    // MARK: - Location re-enable banner (spec d)

    /// A quiet, dismissible card inviting the user to re-enable location.
    ///
    /// Uses `.regularMaterial` glass, not alarming colours. "Open Settings" deep-links
    /// into the app's Settings page (the only path after a denial — iOS won't
    /// re-prompt). "×" persists the dismissal via `AppPreferences.locationPromptDismissed`
    /// so the banner doesn't return.
    private var locationPromptBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.textSecondary)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text("Location is off")
                    .font(Typography.subhead)
                    .tracking(-0.2)
                    .foregroundStyle(Color.textPrimary)
                Text("Turn it on to sort by distance and filter by radius.")
                    .font(Typography.caption)
                    .foregroundStyle(Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Button {
                openAppSettings()
            } label: {
                Text("Settings")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.chipBackground, in: Capsule())
            }
            .buttonStyle(.plain)

            Button {
                preferences.locationPromptDismissed = true
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Color.textSecondary)
                    .frame(width: 26, height: 26)
                    .background(Color.chipBackground, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss location prompt")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glass(.regular, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 16)
    }

    /// Opens the app's page in Settings. MainActor-safe: `UIApplication.shared`
    /// must be called on the main actor, which is satisfied because `FiltersSheet`
    /// runs on `@MainActor` as a SwiftUI view body.
    @MainActor
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Sort section

    private var sortSection: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text("SORT")
                .font(Typography.micro)
                .tracking(0.5)
                .textCase(.uppercase)
                .foregroundStyle(Color.textTertiary)
                .padding(.horizontal, 14)

            VStack(spacing: 0) {
                ForEach(Array(SortOption.allCases.enumerated()), id: \.element.id) { index, option in
                    sortRow(option)

                    if index < SortOption.allCases.count - 1 {
                        Color.hairline
                            .frame(height: 0.5)
                            .padding(.leading, 44)
                    }
                }
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glass(.thick, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .padding(.horizontal, 16)
    }

    /// Returns `true` when this sort option is unavailable due to missing location.
    /// Currently only `.nearest` requires location.
    private func isDisabled(_ option: SortOption) -> Bool {
        locationDenied && option == .nearest
    }

    private func sortRow(_ option: SortOption) -> some View {
        let isSelected = sort == option
        let disabled = isDisabled(option)
        return Button {
            guard !disabled && sort != option else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            sort = option
        } label: {
            HStack(spacing: 12) {
                Image(systemName: option.systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isSelected && !disabled ? Color.green : Color.textSecondary)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(option.label)
                        .font(Typography.subhead)
                        .tracking(-0.2)
                        .foregroundStyle(disabled ? Color.textTertiary : Color.textPrimary)

                    // "Needs location" note shown only for disabled Nearest (spec b/c).
                    if disabled {
                        Text("Needs location")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.textTertiary)
                    }
                }

                Spacer()

                if isSelected && !disabled {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.green)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, disabled ? 10 : 13)
            .contentShape(Rectangle())
            .opacity(disabled ? 0.55 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .accessibilityLabel(option.label + (disabled ? ", Needs location" : ""))
        .accessibilityAddTraits(isSelected && !disabled ? .isSelected : [])
    }
}

// MARK: - Previews

#Preview("FiltersSheet — active + non-default sort, light") {
    @Previewable @State var filters = FilterState(
        radiusKm: 10.0,
        maxPriceCents: 3500,
        dedicatedOnly: true
    )
    @Previewable @State var sort: SortOption = .priceLowToHigh
    FiltersSheet(filters: $filters, sort: $sort, locationDenied: false)
        .preferredColorScheme(.light)
}

#Preview("FiltersSheet — active + non-default sort, dark") {
    @Previewable @State var filters = FilterState(
        radiusKm: 10.0,
        maxPriceCents: 3500,
        dedicatedOnly: true
    )
    @Previewable @State var sort: SortOption = .mostCourts
    FiltersSheet(filters: $filters, sort: $sort, locationDenied: false)
        .preferredColorScheme(.dark)
}

#Preview("FiltersSheet — as sheet, dark") {
    @Previewable @State var filters = FilterState.default
    @Previewable @State var sort: SortOption = .nearest
    Color.pageBackground
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            FiltersSheet(filters: $filters, sort: $sort, locationDenied: true)
        }
        .preferredColorScheme(.dark)
}

// MARK: - Location-denied previews (UX fix #4)

/// Shows the re-enable banner + disabled Nearest row. Preferences injected with
/// `locationPromptDismissed = false` so the banner is visible.
#Preview("FiltersSheet — location denied, banner visible, light") {
    @Previewable @State var filters = FilterState.default
    @Previewable @State var sort: SortOption = .priceLowToHigh
    let prefs: AppPreferences = {
        let p = AppPreferences(defaults: UserDefaults(suiteName: "preview-denied-light")!)
        p.locationPromptDismissed = false
        return p
    }()
    FiltersSheet(filters: $filters, sort: $sort, locationDenied: true)
        .environment(\.preferences, prefs)
        .preferredColorScheme(.light)
}

#Preview("FiltersSheet — location denied, banner visible, dark") {
    @Previewable @State var filters = FilterState.default
    @Previewable @State var sort: SortOption = .priceLowToHigh
    let prefs: AppPreferences = {
        let p = AppPreferences(defaults: UserDefaults(suiteName: "preview-denied-dark")!)
        p.locationPromptDismissed = false
        return p
    }()
    FiltersSheet(filters: $filters, sort: $sort, locationDenied: true)
        .environment(\.preferences, prefs)
        .preferredColorScheme(.dark)
}
