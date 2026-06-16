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
struct FiltersSheet: View {
    @Binding var filters: FilterState
    @Binding var sort: SortOption
    let locationDenied: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            SmashBackdrop()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 18) {
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

    private func sortRow(_ option: SortOption) -> some View {
        let isSelected = sort == option
        return Button {
            guard sort != option else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            sort = option
        } label: {
            HStack(spacing: 12) {
                Image(systemName: option.systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.green : Color.textSecondary)
                    .frame(width: 20)

                Text(option.label)
                    .font(Typography.subhead)
                    .tracking(-0.2)
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.green)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
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
