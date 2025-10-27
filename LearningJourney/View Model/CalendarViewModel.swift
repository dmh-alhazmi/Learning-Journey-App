//
//  CalendarViewModel.swift
//  LearningJourney
//
//  Created by Deemah Alhazmi on 23/10/2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Models used by CalendarView

struct MonthSection: Identifiable, Hashable {
    let id = UUID()
    let monthStart: Date                 // first day of month (startOfDay)
    let days: [CalendarDay]              // exactly 42 cells (6x7 grid)
    let title: String                    // e.g. "October 2025"
}

struct CalendarDay: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let isInCurrentMonth: Bool
}

// MARK: - ViewModel

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var monthSections: [MonthSection] = []

    private let activityVM: ActivityViewModel
    private let calendar: Calendar

    /// Creates a calendar VM that builds months centered around *today*.
    /// `previous` and `next` control how many months before/after today to include.
    init(activityVM: ActivityViewModel,
         calendar: Calendar = .current,
         previous: Int = 6,
         next: Int = 6) {
        self.activityVM = activityVM
        self.calendar = calendar
        buildMonths(around: Date(), previous: previous, next: next)
    }

    // Exposed so views can rebuild if needed (e.g., after bulk edits)
    func refresh(around anchor: Date = Date(), previous: Int = 6, next: Int = 6) {
        buildMonths(around: anchor, previous: previous, next: next)
    }

    /// Returns the logged status for a given day (defaults to `.none`).
    func status(for date: Date) -> DayStatus {
        let day = calendar.startOfDay(for: date)
        return activityVM.log[day] ?? .none
    }

    /// Prefetch more months when the user scrolls near the edges of the current window.
    /// If the appeared section is within `edgeThreshold` from either edge, rebuild centered on that month.
    func prefetchIfNeeded(appeared section: MonthSection, edgeThreshold: Int = 2, previous: Int = 6, next: Int = 6) {
        guard let index = monthSections.firstIndex(where: { $0.monthStart == section.monthStart }) else { return }
        let count = monthSections.count
        guard count > 0 else { return }

        let nearStart = index <= edgeThreshold
        let nearEnd = index >= (count - 1 - edgeThreshold)

        if nearStart || nearEnd {
            buildMonths(around: section.monthStart, previous: previous, next: next)
        }
    }

    // MARK: - Month building

    private func buildMonths(around anchor: Date, previous: Int, next: Int) {
        var sections: [MonthSection] = []

        // First day (startOfDay) of the anchor month
        let anchorMonth = monthStart(anchor)

        for offset in (-previous)...next {
            guard let m = calendar.date(byAdding: .month, value: offset, to: anchorMonth) else { continue }
            let start = monthStart(m)
            let title = monthTitle(start)
            let days = makeGridDays(forMonthStartingAt: start)
            sections.append(MonthSection(monthStart: start, days: days, title: title))
        }

        self.monthSections = sections
    }

    /// Returns first day of the month at 00:00 for a given date.
    private func monthStart(_ date: Date) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: date)
        let d = calendar.date(from: comps) ?? date
        return calendar.startOfDay(for: d)
    }

    /// Builds 42 consecutive days (6 x 7) starting from the beginning of the week containing `monthStart`.
    private func makeGridDays(forMonthStartingAt monthStart: Date) -> [CalendarDay] {
        // Start of grid = start of the week that contains the 1st of the month
        let gridStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear],
                                                                    from: monthStart))!
        var result: [CalendarDay] = []
        result.reserveCapacity(42)
        for i in 0..<42 {
            let d = calendar.date(byAdding: .day, value: i, to: gridStart)!
            let inMonth = calendar.isDate(d, equalTo: monthStart, toGranularity: .month)
            result.append(CalendarDay(date: d, isInCurrentMonth: inMonth))
        }
        return result
    }

    private func monthTitle(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: date)
    }
}

