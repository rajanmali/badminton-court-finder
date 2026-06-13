import Testing
@testable import Smash

// MARK: - dayLabel tests

struct DayLabelTests {
    @Test func mapsZeroToSun() { #expect(dayLabel(0) == "Sun") }
    @Test func mapsOneToMon() { #expect(dayLabel(1) == "Mon") }
    @Test func mapsSixToSat() { #expect(dayLabel(6) == "Sat") }
    @Test func fallsBackForOutOfRange() { #expect(dayLabel(7) == "Day 7") }
}

// MARK: - formatTime tests

struct FormatTimeTests {
    @Test func formatsMidnightAs12amZero() { #expect(formatTime("00:00") == "12:00 am") }
    @Test func formatsNoonAs12pmZero() { #expect(formatTime("12:00") == "12:00 pm") }
    @Test func formats9amWithLeadingZeroHour() { #expect(formatTime("09:00") == "9:00 am") }
    @Test func formats10pm() { #expect(formatTime("22:00") == "10:00 pm") }
    @Test func returnsDashForNil() { #expect(formatTime(nil) == "—") }
    @Test func handlesHHMMSSFromPostgres() { #expect(formatTime("17:30:00") == "5:30 pm") }
}

// MARK: - formatDays tests

struct FormatDaysTests {
    @Test func returnsEveryDayFor7Days() {
        #expect(formatDays(["mon", "tue", "wed", "thu", "fri", "sat", "sun"]) == "Every day")
    }

    @Test func returnsAllDaysForEmptyArray() {
        #expect(formatDays([]) == "All days")
    }

    @Test func formatsSubset() {
        #expect(formatDays(["mon", "wed", "fri"]) == "Mon, Wed, Fri")
    }

    @Test func formatsWeekend() {
        #expect(formatDays(["sat", "sun"]) == "Sat, Sun")
    }
}
