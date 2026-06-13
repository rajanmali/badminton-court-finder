import SwiftUI

/// Renders a single court hire rate row.
///
/// Left side: rate label (semibold) + day/time meta line + optional notes.
/// Right side: formatted price in green bold.
/// A bottom hairline divider is rendered via a `Divider()` overlay — the
/// parent section provides the overall container.
struct RateCardView: View {
    let rateCard: RateCard

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            // Left: label + meta + notes
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(rateCard.label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.smashText)

                Text(metaLine)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.smashTextSecondary)

                if let notes = rateCard.notes {
                    Text(notes)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.smashTextSecondary.opacity(0.7))
                }
            }

            Spacer()

            // Right: price
            Text(formatPriceCents(rateCard.priceCents))
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.smashPrimary)
        }
        .padding(.vertical, Spacing.sm)
    }

    /// Day abbreviations + optional time range in one string.
    private var metaLine: String {
        var parts = [formatDays(rateCard.daysApply)]
        if let start = rateCard.timeRangeStart {
            parts.append("\(formatTime(start))–\(formatTime(rateCard.timeRangeEnd))")
        }
        return parts.joined(separator: "  ·  ")
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        RateCardView(rateCard: RateCard(
            id: "1",
            label: "Peak hour",
            priceCents: 3500,
            daysApply: ["mon", "tue", "wed", "thu", "fri"],
            timeRangeStart: "17:00",
            timeRangeEnd: "21:00",
            notes: "Booking required"
        ))
        Divider()
        RateCardView(rateCard: RateCard(
            id: "2",
            label: "Off-peak",
            priceCents: 2500,
            daysApply: [],
            timeRangeStart: nil,
            timeRangeEnd: nil,
            notes: nil
        ))
        Divider()
        RateCardView(rateCard: RateCard(
            id: "3",
            label: "Weekend",
            priceCents: 4000,
            daysApply: ["sat", "sun"],
            timeRangeStart: "09:00",
            timeRangeEnd: "18:00",
            notes: nil
        ))
    }
    .padding(.horizontal, Spacing.md)
}
