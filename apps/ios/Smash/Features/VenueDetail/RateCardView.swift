import SwiftUI

/// Renders a single court-hire rate row inside the rates glass card.
///
/// Left: the rate `label` (body weight) with an optional green **note pill**
/// beside it, then a `days · time` meta line (caption / secondary) — the time
/// range is appended only when `timeRangeStart` is present.
/// Right: the formatted price with the dollar amount in green.
///
/// The inline pill is shown **only** for a short semantic tag
/// (``RateCard/shortTag`` — e.g. "Most popular"); long policy text moves to the
/// detail screen's "Good to know" section so the pill never balloons (UX fix #5).
///
/// Hairline dividers between rows are drawn by the parent section.
/// Mirrors `RateCard` in `design_handoff_smash/app/screens.jsx`.
///
/// Font sizes scale with Dynamic Type via `@ScaledMetric` so the row grows at
/// larger accessibility text sizes (UX fix #11).
struct RateCardView: View {
    let rateCard: RateCard

    // MARK: - Dynamic Type scaled metrics
    // Base design sizes scaled relative to their semantic text style.
    // These grow/shrink with the user's preferred text size.
    @ScaledMetric(relativeTo: .body)    private var labelSize:    CGFloat = 17
    @ScaledMetric(relativeTo: .caption) private var captionSize:  CGFloat = 13
    @ScaledMetric(relativeTo: .body)    private var priceSize:    CGFloat = 19
    @ScaledMetric(relativeTo: .caption) private var suffixSize:   CGFloat = 11

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            // Left: label (+ note pill) + meta line. Allow wrapping at larger sizes.
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: Spacing.sm) {
                    Text(rateCard.label)
                        .font(.system(size: labelSize, weight: .semibold))
                        .tracking(-0.3)
                        .foregroundStyle(Color.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    // Only short, label-like tags go in the inline pill; long
                    // policy text lives in the "Good to know" section.
                    if let tag = rateCard.shortTag {
                        NotePill(text: tag)
                    }
                }

                Text(metaLine)
                    .font(.system(size: captionSize, weight: .regular))
                    .foregroundStyle(Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right: price — the dollar amount in green. Pinned trailing.
            priceLabel
                .layoutPriority(1)
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
                .font(.system(size: priceSize, weight: .black))
                .tracking(-0.6)
                .foregroundStyle(Color.green)
                + Text(suffix)
                .font(.system(size: suffixSize, weight: .semibold))
                .foregroundStyle(Color.textTertiary)
        }
        // No "/hr" suffix (e.g. "Rates not listed") — render whole in green.
        return Text(full)
            .font(.system(size: priceSize, weight: .black))
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
            // Guard: a tag pill must never wrap across lines.
            .lineLimit(1)
            .fixedSize()
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
            // Short tag → inline pill.
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
            // Long policy note → no inline pill (moves to "Good to know").
            RateCardView(rateCard: RateCard(
                id: "2",
                label: "Off-peak",
                priceCents: 2500,
                daysApply: [],
                timeRangeStart: nil,
                timeRangeEnd: nil,
                notes: "48-hour cancellation policy, payment required at booking"
            ))
        }
        .padding(.horizontal, Spacing.md)
        .glass(.regular, in: RoundedRectangle(cornerRadius: Radius.section, style: .continuous))
        .padding(Spacing.md)
    }
}
