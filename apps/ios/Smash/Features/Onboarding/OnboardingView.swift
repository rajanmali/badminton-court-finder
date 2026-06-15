import SwiftUI

// MARK: - OnboardingView

/// The first-run onboarding flow (UX fix #0).
///
/// A three-step sequential flow on the ``SmashBackdrop`` with glass cards:
///
/// 1. **Location priming** — explains *why* we want location, then triggers the
///    iOS system prompt only when the user taps "Enable location". Whether the
///    request resolves to ``LocationOutcome/located(_:)`` drives both the
///    distance-chip gating on step 2 and the default-sort preselection on step 3.
/// 2. **Default filters** — the same controls as the app's `FilterBar`
///    (distance / max price / dedicated-only), seeded from
///    ``AppPreferences/defaultFilters``. Distance chips other than "Any" are
///    disabled when location was not granted, mirroring the app's rule.
/// 3. **Default sort** — a selector of every ``SortOption``, location-aware
///    preselected via ``defaultSort(forLocationAvailable:)``.
///
/// On finish the choices are persisted to ``AppPreferences`` and
/// `hasSeenOnboarding` is set, which dismisses the hosting `fullScreenCover`.
///
/// The flow owns its own draft `@State` (`filters`, `sort`, `locationAvailable`)
/// and only writes them back to preferences on "Get started", so backing out of
/// the app mid-flow never half-persists.
struct OnboardingView: View {

    @Environment(\.preferences) private var preferences
    @Environment(\.appEnvironment) private var env
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss

    /// Current step (0-based). Three steps total.
    @State private var step = 0

    /// Draft filters, seeded from the persisted defaults. Persisted on finish.
    @State private var filters: FilterState

    /// Draft sort. Defaults to `.priceLowToHigh` until the location step resolves;
    /// `onLocationResolved` re-derives it via ``defaultSort(forLocationAvailable:)``.
    @State private var sort: SortOption = .priceLowToHigh

    /// Whether the location request ended up with usable coordinates. `nil` until
    /// the user either grants/denies on step 1 or skips. Drives distance gating
    /// (step 2) and the default-sort preselect (step 3).
    @State private var locationAvailable = false

    /// Guards against double-requesting location while the system prompt is up.
    @State private var requestingLocation = false

    private let stepCount = 3

    init() {
        // Seed the draft from whatever the user (or defaults) last had. Reading
        // `.shared` here is acceptable: the cover is only shown for `.shared`,
        // and previews override `preferences` *and* construct fresh state.
        _filters = State(initialValue: AppPreferences.shared.defaultFilters)
    }

    var body: some View {
        ZStack {
            SmashBackdrop()

            VStack(spacing: 0) {
                StepIndicator(step: step, total: stepCount)
                    .padding(.top, 24)
                    .padding(.bottom, 8)

                // The step content fills the available space and is vertically
                // centered within it.
                stepContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, Spacing.screen)
                    .transition(.opacity)

                footer
                    .padding(.horizontal, Spacing.screen)
                    .padding(.bottom, 24)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.28), value: step)
    }

    // MARK: - Step content

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 0:
            LocationPrimingStep(
                requesting: requestingLocation,
                onEnable: requestLocation,
                onSkip: skipLocation
            )
        case 1:
            DefaultFiltersStep(
                filters: $filters,
                locationDenied: !locationAvailable
            )
        default:
            DefaultSortStep(sort: $sort)
        }
    }

    // MARK: - Footer (Back / Continue / Get started)

    private var footer: some View {
        VStack(spacing: 12) {
            // The primary CTA is only shown for steps that are advanced by an
            // explicit button. Step 0 is advanced from inside the step itself
            // (Enable location / Skip), so it has no Continue button.
            if step > 0 {
                Button(step == stepCount - 1 ? "Get started" : "Continue") {
                    advanceFromButton()
                }
                .buttonStyle(.primary)

                Button("Back") {
                    haptic()
                    step -= 1
                }
                .font(Typography.subhead)
                .foregroundStyle(Color.textSecondary)
                .frame(minHeight: 44)
            }
        }
    }

    // MARK: - Actions

    /// Step 1 "Enable location" → trigger the iOS system prompt, record the
    /// outcome, re-derive the default sort, then advance.
    private func requestLocation() {
        guard !requestingLocation else { return }
        requestingLocation = true
        Task {
            let outcome = await env.locationService.requestLocation()
            requestingLocation = false
            onLocationResolved(available: isLocated(outcome))
        }
    }

    /// Step 1 "Skip" → proceed without requesting; treat as no-location.
    private func skipLocation() {
        onLocationResolved(available: false)
    }

    /// Fold the location result into draft state and advance off step 1.
    private func onLocationResolved(available: Bool) {
        locationAvailable = available
        // Location-aware default-sort preselect.
        sort = defaultSort(forLocationAvailable: available)
        // If location was denied/skipped, a previously-set distance filter would
        // be inert (the app ignores radius without coords) — clear it so the
        // disabled chips on step 2 stay consistent with the captured value.
        if !available {
            filters.radiusKm = nil
        }
        haptic()
        advance()
    }

    /// Advance via the footer's Continue/Get started button.
    private func advanceFromButton() {
        haptic()
        advance()
    }

    /// Advance to the next step, or finish on the last step.
    private func advance() {
        if step < stepCount - 1 {
            step += 1
        } else {
            finish()
        }
    }

    /// Persist the captured defaults and mark onboarding complete, which
    /// dismisses the hosting cover.
    private func finish() {
        preferences.defaultFilters = filters
        preferences.defaultSort = sort
        preferences.hasSeenOnboarding = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }

    // MARK: - Helpers

    private func isLocated(_ outcome: LocationOutcome) -> Bool {
        if case .located = outcome { return true }
        return false
    }

    private func haptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

// MARK: - Step indicator

/// A row of pill segments showing progress through the flow. The active and
/// completed segments are green; upcoming segments are a faint hairline fill.
private struct StepIndicator: View {
    let step: Int
    let total: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index <= step ? Color.green : Color.hairlineStrong)
                    .frame(width: index == step ? 26 : 18, height: 5)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(step + 1) of \(total)")
    }
}

// MARK: - Shared step header

/// The headline + body copy block shared by every onboarding step.
private struct StepHeader: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(Color.green)
                .frame(width: 64, height: 64)
                .glass(.ultraThin, in: Circle())
                .greenGlow()
                .accessibilityHidden(true)

            Text(title)
                .font(Typography.title)
                .tracking(-1.0)
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(Typography.body)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Step 1: location priming

/// Primes the location ask *before* the system prompt, then offers Enable / Skip.
private struct LocationPrimingStep: View {
    let requesting: Bool
    let onEnable: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            StepHeader(
                icon: "location.fill",
                title: "Find courts near you",
                subtitle: "Smash uses your location to sort the nearest courts first. You can change this anytime."
            )

            VStack(spacing: 12) {
                Button(action: onEnable) {
                    HStack(spacing: 8) {
                        if requesting {
                            ProgressView()
                                .tint(Color.onAccent)
                        }
                        Text(requesting ? "Requesting…" : "Enable location")
                    }
                }
                .buttonStyle(.primary)
                .disabled(requesting)

                Button("Skip", action: onSkip)
                    .font(Typography.subhead)
                    .foregroundStyle(Color.textSecondary)
                    .frame(minHeight: 44)
                    .disabled(requesting)
            }
        }
    }
}

// MARK: - Step 2: default filters

/// Captures the user's default filters with the same controls as the app's
/// `FilterBar`, wrapped in a thick-glass card.
private struct DefaultFiltersStep: View {
    @Binding var filters: FilterState
    let locationDenied: Bool

    private let distanceOptions: [(String, Double?)] = [
        ("Any", nil), ("5 km", 5.0), ("10 km", 10.0), ("20 km", 20.0),
    ]
    private let priceOptions: [(String, Int?)] = [
        ("Any", nil), ("≤$30", 3000), ("≤$35", 3500), ("≤$40", 4000),
    ]

    var body: some View {
        VStack(spacing: 24) {
            StepHeader(
                icon: "slider.horizontal.3",
                title: "Set your defaults",
                subtitle: "These filters apply every time you open Smash."
            )

            VStack(alignment: .leading, spacing: 14) {
                chipGroup(title: "DISTANCE") {
                    ForEach(distanceOptions, id: \.0) { title, value in
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

                if locationDenied {
                    Text("Enable location to filter by distance")
                        .font(Typography.caption)
                        .foregroundStyle(Color.warning)
                }

                hairline

                chipGroup(title: "MAX PRICE") {
                    ForEach(priceOptions, id: \.0) { title, value in
                        FilterChip(
                            title: title,
                            isOn: filters.maxPriceCents == value,
                            action: { filters.maxPriceCents = value }
                        )
                    }
                }

                hairline

                HStack(spacing: 7) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.green)
                    Text("Dedicated courts only")
                        .font(Typography.subhead)
                        .tracking(-0.2)
                        .foregroundStyle(Color.textPrimary)
                    Spacer()
                    Toggle("Dedicated courts only", isOn: $filters.dedicatedOnly)
                        .labelsHidden()
                        .tint(.green)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glass(.thick, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }

    @ViewBuilder
    private func chipGroup<Content: View>(
        title: String,
        @ViewBuilder _ chips: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(Typography.micro)
                .tracking(0.5)
                .textCase(.uppercase)
                .foregroundStyle(Color.textTertiary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) { chips() }
            }
        }
    }

    private var hairline: some View {
        Color.hairline.frame(height: 0.5).frame(maxWidth: .infinity)
    }
}

// MARK: - Step 3: default sort

/// Captures the default ordering as a list of tappable glass rows, one per
/// ``SortOption``.
private struct DefaultSortStep: View {
    @Binding var sort: SortOption

    var body: some View {
        VStack(spacing: 24) {
            StepHeader(
                icon: "arrow.up.arrow.down",
                title: "Sort courts by",
                subtitle: "Pick how the list is ordered by default."
            )

            VStack(spacing: 8) {
                ForEach(SortOption.allCases) { option in
                    SortRow(
                        option: option,
                        isSelected: sort == option,
                        action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            sort = option
                        }
                    )
                }
            }
        }
    }
}

/// One selectable sort option: icon + label, with a checkmark and green glow
/// when selected.
private struct SortRow: View {
    let option: SortOption
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: option.systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.onAccent : Color.green)
                    .frame(width: 24)

                Text(option.label)
                    .font(Typography.subhead)
                    .tracking(-0.2)
                    .foregroundStyle(isSelected ? Color.onAccent : Color.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.onAccent)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 44)
            .background {
                let shape = RoundedRectangle(cornerRadius: Radius.section, style: .continuous)
                if isSelected {
                    shape.fill(
                        LinearGradient(colors: [.greenBright, .green],
                                       startPoint: .top, endPoint: .bottom)
                    )
                } else {
                    shape.fill(Color.chipBackground)
                        .overlay(shape.strokeBorder(Color.hairline, lineWidth: 0.5))
                }
            }
            .modifier(SortRowGlow(active: isSelected))
        }
        .buttonStyle(.plain)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.25), value: isSelected)
        .accessibilityLabel(option.label)
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }
}

/// Green glow applied only to the selected sort row.
private struct SortRowGlow: ViewModifier {
    let active: Bool
    func body(content: Content) -> some View {
        if active { content.greenGlow() } else { content }
    }
}

// MARK: - Previews

#Preview("Step 1 — location priming, light") {
    OnboardingView()
        .environment(\.preferences, AppPreferences(defaults: UserDefaults(suiteName: "preview-onb-1")!))
        .environment(\.appEnvironment, AppEnvironment(
            venueRepository: LiveVenueRepository(),
            locationService: MockLocationService(outcome: .located(UserCoords(latitude: -33.87, longitude: 151.21)))
        ))
        .preferredColorScheme(.light)
}

#Preview("Step 1 — location priming, dark") {
    OnboardingView()
        .environment(\.preferences, AppPreferences(defaults: UserDefaults(suiteName: "preview-onb-2")!))
        .environment(\.appEnvironment, AppEnvironment(
            venueRepository: LiveVenueRepository(),
            locationService: MockLocationService(outcome: .denied)
        ))
        .preferredColorScheme(.dark)
}

#Preview("Step 2 — default filters (location available), light") {
    @Previewable @State var filters = FilterState.default
    ZStack {
        SmashBackdrop()
        DefaultFiltersStep(filters: $filters, locationDenied: false)
            .padding(.horizontal, Spacing.screen)
    }
    .preferredColorScheme(.light)
}

#Preview("Step 2 — default filters (location denied), dark") {
    @Previewable @State var filters = FilterState.default
    ZStack {
        SmashBackdrop()
        DefaultFiltersStep(filters: $filters, locationDenied: true)
            .padding(.horizontal, Spacing.screen)
    }
    .preferredColorScheme(.dark)
}

#Preview("Step 3 — default sort (nearest), light") {
    @Previewable @State var sort = SortOption.nearest
    ZStack {
        SmashBackdrop()
        DefaultSortStep(sort: $sort)
            .padding(.horizontal, Spacing.screen)
    }
    .preferredColorScheme(.light)
}

#Preview("Step 3 — default sort (price, no location), dark") {
    @Previewable @State var sort = SortOption.priceLowToHigh
    ZStack {
        SmashBackdrop()
        DefaultSortStep(sort: $sort)
            .padding(.horizontal, Spacing.screen)
    }
    .preferredColorScheme(.dark)
}
