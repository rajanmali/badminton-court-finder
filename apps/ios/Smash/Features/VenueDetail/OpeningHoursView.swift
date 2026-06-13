import SwiftUI

/// Renders opening hours in Mon→Sun order.
///
/// Day order follows the RN implementation: `[1, 2, 3, 4, 5, 6, 0]`
/// (Monday = 1 through Saturday = 6, Sunday = 0).
/// A day is shown as "Closed" when there is no matching entry in `hours`
/// or the matching entry has `isClosed == true`.
struct OpeningHoursView: View {

    let hours: [OpeningHours]

    /// Mon→Sun order: Mon=1, Tue=2, Wed=3, Thu=4, Fri=5, Sat=6, Sun=0.
    private let dayOrder = [1, 2, 3, 4, 5, 6, 0]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(dayOrder, id: \.self) { dow in
                let entry = hours.first { $0.dayOfWeek == dow }
                let isClosed = entry == nil || entry?.isClosed == true
                let timeText: String = {
                    if isClosed { return "Closed" }
                    return "\(formatTime(entry?.openTime)) – \(formatTime(entry?.closeTime))"
                }()

                HStack {
                    Text(dayLabel(dow))
                        .font(.system(size: 15))
                        .foregroundStyle(Color.smashText)

                    Spacer()

                    Text(timeText)
                        .font(.system(size: 15))
                        .foregroundStyle(isClosed ? Color.smashTextSecondary : Color.smashText)
                }
                .padding(.vertical, Spacing.sm)

                if dow != dayOrder.last {
                    Divider()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OpeningHoursView(hours: [
        OpeningHours(dayOfWeek: 1, openTime: "06:00", closeTime: "22:00", isClosed: false),
        OpeningHours(dayOfWeek: 2, openTime: "06:00", closeTime: "22:00", isClosed: false),
        OpeningHours(dayOfWeek: 3, openTime: "06:00", closeTime: "22:00", isClosed: false),
        OpeningHours(dayOfWeek: 4, openTime: "06:00", closeTime: "22:00", isClosed: false),
        OpeningHours(dayOfWeek: 5, openTime: "06:00", closeTime: "22:00", isClosed: false),
        OpeningHours(dayOfWeek: 6, openTime: "08:00", closeTime: "20:00", isClosed: false),
        // Sunday omitted → rendered as Closed
    ])
    .padding(.horizontal, Spacing.md)
}
