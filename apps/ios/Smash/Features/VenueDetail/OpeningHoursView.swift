import SwiftUI

/// Renders opening hours in Mon→Sun order inside the hours glass card.
///
/// Day order follows the design: `[1, 2, 3, 4, 5, 6, 0]` (Mon=1 … Sat=6, Sun=0).
/// Today's row is emphasised — bolded, prefixed with a glowing green dot, and
/// tagged with a small "Today" pill. Hours read "Closed" in red when there is
/// no matching entry or the entry has `isClosed == true`.
///
/// Mirrors the hours block in `design_handoff_smash/app/screens.jsx`.
///
/// Font sizes scale with Dynamic Type via `@ScaledMetric` so the rows grow at
/// larger accessibility text sizes (UX fix #11).
struct OpeningHoursView: View {

    let hours: [OpeningHours]

    /// Mon→Sun order: Mon=1, Tue=2, Wed=3, Thu=4, Fri=5, Sat=6, Sun=0.
    private let dayOrder = [1, 2, 3, 4, 5, 6, 0]

    /// The current day as a 0-based `dayOfWeek` (0 = Sun … 6 = Sat).
    private var todayDow: Int {
        dayOfWeek(fromWeekday: Calendar.current.component(.weekday, from: Date()))
    }

    // MARK: - Dynamic Type scaled metrics
    // Base design sizes scaled relative to their semantic text style.
    @ScaledMetric(relativeTo: .body)    private var dayLabelSize: CGFloat = 15
    @ScaledMetric(relativeTo: .caption) private var todayPillSize: CGFloat = 11
    @ScaledMetric(relativeTo: .body)    private var hoursTextSize: CGFloat = 14.5

    var body: some View {
        VStack(spacing: 0) {
            ForEach(dayOrder, id: \.self) { dow in
                let entry = hours.first { $0.dayOfWeek == dow }
                let isClosed = entry == nil || entry?.isClosed == true
                let isToday = dow == todayDow

                HStack(alignment: .center, spacing: Spacing.sm) {
                    // Left: day name (+ today emphasis).
                    HStack(spacing: Spacing.sm) {
                        if isToday {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 7, height: 7)
                                .greenGlow()
                        }

                        Text(dayLabel(dow))
                            .font(.system(size: dayLabelSize, weight: isToday ? .bold : .semibold))
                            .foregroundStyle(isToday ? Color.textPrimary : Color.textSecondary)

                        if isToday {
                            Text("Today")
                                .font(.system(size: todayPillSize, weight: .heavy))
                                .foregroundStyle(Color.green)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1)
                                .background(Color.green.opacity(0.15), in: Capsule())
                        }
                    }

                    Spacer(minLength: Spacing.sm)

                    // Right: hours or "Closed" (red).
                    Text(hoursText(entry: entry, isClosed: isClosed))
                        .font(.system(size: hoursTextSize, weight: isToday ? .semibold : .regular))
                        .foregroundStyle(hoursColor(isClosed: isClosed, isToday: isToday))
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                }
                .padding(.vertical, 11)

                if dow != dayOrder.last {
                    Divider().overlay(Color.hairline)
                }
            }
        }
    }

    private func hoursText(entry: OpeningHours?, isClosed: Bool) -> String {
        if isClosed { return "Closed" }
        return "\(formatTime(entry?.openTime)) – \(formatTime(entry?.closeTime))"
    }

    private func hoursColor(isClosed: Bool, isToday: Bool) -> Color {
        if isClosed { return .red }
        return isToday ? .textPrimary : .textSecondary
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        SmashBackdrop()
        OpeningHoursView(hours: [
            OpeningHours(dayOfWeek: 1, openTime: "06:00", closeTime: "22:00", isClosed: false),
            OpeningHours(dayOfWeek: 2, openTime: "06:00", closeTime: "22:00", isClosed: false),
            OpeningHours(dayOfWeek: 3, openTime: "06:00", closeTime: "22:00", isClosed: false),
            OpeningHours(dayOfWeek: 4, openTime: "06:00", closeTime: "22:00", isClosed: false),
            OpeningHours(dayOfWeek: 5, openTime: "06:00", closeTime: "22:00", isClosed: false),
            OpeningHours(dayOfWeek: 6, openTime: "08:00", closeTime: "20:00", isClosed: false),
            OpeningHours(dayOfWeek: 0, openTime: nil, closeTime: nil, isClosed: true),
        ])
        .padding(.horizontal, Spacing.md)
        .glass(.regular, in: RoundedRectangle(cornerRadius: Radius.section, style: .continuous))
        .padding(Spacing.md)
    }
}
