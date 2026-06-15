import SwiftUI

/// Renders a single court-hire rate row inside the rates glass card.
///
/// Left: the rate `label` (body weight) with an optional green **note pill**
/// beside it, then a `days · time` meta line (caption / secondary) — the time
/// range is appended only when `timeRangeStart` is present.
/// Right: the formatted price with the dollar amount in green.
///
/// Hairline dividers between rows are drawn by the parent section.
/// Mirrors `RateCard` in `design_handoff_smash/app/screens.jsx`.
struct RateCardView: View {
    let rateCard: RateCard

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.sm) {
            // Left: label (+ note pill) + meta line.
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: Spacing.sm) {
                    Text(rateCard.label)
                        .font(Typography.body)
                        .tracking(-0.3)
                        .foregroundStyle(Color.textPrimary)

                    if let notes = rateCard.notes {
                        NotePill(text: notes)
                    }
                }

                Text(metaLine)
                    .font(Typography.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer(minLength: Spacing.sm)

            // Right: price — the dollar amount in green.
            priceLabel
        }
        .padding(.vertical, 13)
    }

    /// `$34/hr` with the `$34` rendered in green and the `/hr` in tertiary.
    private var priceLabel: some View {
        let full = formatPriceCents(rateCard.priceCents)
        // Split "$34/hr" into the amount and the "/hr" suffix.
        if let slash = full.firstIndex(of: "/") {
            let amount = String(full[full.startIndex..<slash])
            let suffix = String(full[slash...])
            return Text(amount)
                .font(.system(size: 19, weight: .black))
                .tracking(-0.6)
                .foregroundStyle(Color.green)
                + Text(suffix)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.textTertiary)
        }
        // No "/hr" suffix (e.g. "Rates not listed") — render whole in green.
        return Text(full)
            .font(.system(size: 19, weight: .black))
            .tracking(-0.6)
            .foregroundStyle(Color.green)
            + Text("")
    }

    /// Day abbreviations, plus the time range when a start time is set.
    private var metaLine: String {
        var parts = [formatDays(rateCard.daysApply)]
        if rateCard.timeRangeStart != nil {
            parts.append("\(formatTime(rateCard.timeRangeStart))–\(formatTime(rateCard.timeRangeEnd))")
        }
        return parts.joined(separator: " · ")
    }
}

// MARK: - Note pill

/// A small green-on-light-green pill highlighting a rate note (e.g. "Most popular").
/// Mirrors the `r.note` pill in the prototype.
private struct NotePill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 10.5, weight: .heavy))
            .tracking(0.3)
            .textCase(.uppercase)
            .foregroundStyle(Color.green)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(Color.green.opacity(0.15), in: Capsule())
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        SmashBackdrop()
        VStack(spacing: 0) {
            RateCardView(rateCard: RateCard(
                id: "1",
                label: "Peak hour",
                priceCents: 3500,
                daysApply: ["mon", "tue", "wed", "thu", "fri"],
                timeRangeStart: "17:00",
                timeRangeEnd: "21:00",
                notes: "Most popular"
            ))
            Divider().overlay(Color.hairline)
            RateCardView(rateCard: RateCard(
                id: "2",
                label: "Off-peak",
                priceCents: 2500,
                daysApply: [],
                timeRangeStart: nil,
                timeRangeEnd: nil,
                notes: nil
            ))
        }
        .padding(.horizontal, Spacing.md)
        .glass(.regular, in: RoundedRectangle(cornerRadius: Radius.section, style: .continuous))
        .padding(Spacing.md)
    }
}
