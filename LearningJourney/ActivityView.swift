//
//  ActivityView.swift
//  LearningJourney
//
//  Created by Deemah Alhazmi on 19/10/2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Helpers & Theme

extension Color {
    /// Accepts "FF9230" or "#FF9230"
    init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        self.init(
            red:   Double((v >> 16) & 0xFF) / 255.0,
            green: Double((v >>  8) & 0xFF) / 255.0,
            blue:  Double( v        & 0xFF) / 255.0
        )
    }
}

private enum Theme {
    static let bg = Color.black
    static let card = Color.white.opacity(0.06)
    static let stroke = Color.white.opacity(0.10)
    static let label = Color.white
    static let sub = Color.white.opacity(0.6)
    static let orange = Color(hex: "FF9230")
    static let teal = Color(hex: "0FA3A7")
    static let chip = Color.white.opacity(0.08)
}

// MARK: - Models

enum DayStatus: String, Codable {
    case none, learned, frozen
}

enum Plan: String, CaseIterable, Identifiable {
    case week = "Week", month = "Month", year = "Year"
    var id: String { rawValue }
    
    var freezeAllowance: Int {
        switch self {
        case .week:  return 2
        case .month: return 8
        case .year:  return 96
        }
    }
}

// MARK: - Activity View

struct ActivityView: View {
    // Plan controls the freeze allowance window
    @State private var plan: Plan = .week
    
    // The month being browsed (we show weeks within this month)
    @State private var selectedMonthAnchor = Date() // any date within the month
    @State private var showMonthPicker = false
    
    // Which week (0..n) inside the month we’re showing
    @State private var weekOffset: Int = 0
    
    // Persisted log for demo (date -> status). In a real app, move to VM / storage.
    @State private var log: [Date: DayStatus] = [:]
    
    // Tick at midnight to refresh today state
    @State private var midnightCancellable: AnyCancellable?
    
    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 20) {
                header
                
                card
                
                bigCircle
                
                freezeSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .sheet(isPresented: $showMonthPicker) {
            MonthYearPickerView(
                initial: selectedMonthAnchor,
                onChange: { newMonth in
                    selectedMonthAnchor = newMonth
                    weekOffset = 0 // reset to first week in that month
                }
            )
            .preferredColorScheme(.dark)
        }
        .onAppear(perform: scheduleMidnightRefresh)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Header

private extension ActivityView {
    var header: some View {
        HStack(spacing: 12) {
            Text("Activity")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.label)
            Spacer()
            // Quick plan switcher to match your mock (Week/Month/Year)
            Menu(plan.rawValue) {
                ForEach(Plan.allCases) { p in
                    Button(p.rawValue) { plan = p }
                }
            }
            .foregroundStyle(Theme.sub)
            .padding(8)
            .background(
                Capsule().fill(Theme.card)
                    .overlay(Capsule().stroke(Theme.stroke, lineWidth: 1))
            )
        }
    }
}

// MARK: - Card (Month + Week strip + Stats)

private extension ActivityView {
    var card: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Month row with picker & arrows
            HStack(spacing: 12) {
                Button {
                    showMonthPicker = true
                } label: {
                    HStack(spacing: 6) {
                        Text(monthYear(selectedMonthAnchor))
                            .font(.headline)
                        Image(systemName: "chevron.down")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(Theme.label)
                }
                Spacer()
                HStack(spacing: 18) {
                    Button {
                        moveWeek(-1)
                    } label: {
                        Image(systemName: "chevron.left")
                    }

                    Button {
                        moveWeek(+1)
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }

                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.sub)
            }
            
            weekStrip
            
            Divider().background(Theme.stroke)
            
            HStack(spacing: 12) {
                StatPill(
                    icon: "flame.fill",
                    title: "\(learnedCountInWindow)",
                    subtitle: learnedCountInWindow == 1 ? "Day Learned" : "Days Learned",
                    tint: Theme.orange
                )
                StatPill(
                    icon: "cube.fill",
                    title: "\(frozenCountInWindow)",
                    subtitle: frozenCountInWindow == 1 ? "Day Freezed" : "Days Freezed",
                    tint: Theme.teal
                )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.card)
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Theme.stroke, lineWidth: 1))
        )
    }
    
    var weekStrip: some View {
        let days = visibleWeekDays
        return HStack(spacing: 10) {
            ForEach(days, id: \.self) { d in
                let isToday = Calendar.current.isDateInToday(d)
                let number = Calendar.current.component(.day, from: d)
                let status = statusForDate(d)
                
                VStack(spacing: 6) {
                    Text(shortWeekday(d).uppercased())
                        .font(.caption2)
                        .foregroundStyle(Theme.sub)
                    
                    ZStack {
                        Circle()
                            .fill(fillFor(status))
                            .overlay(
                                Circle().stroke(strokeFor(status, isToday: isToday), lineWidth: isToday ? 2 : 1)
                            )
                            .frame(width: 36, height: 36)
                        Text("\(number)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(textFor(status))
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Big Action Circle

private extension ActivityView {
    var bigCircle: some View {
        Button {
            if case .none = todayStatus {
                setStatus(.learned, for: Date())
            }
        } label: {
            ZStack {
                switch todayStatus {
                case .none:
                    Circle()
                        .fill(Theme.orange)
                        .overlay(Circle().stroke(Theme.orange.opacity(0.9), lineWidth: 2))
                        .shadow(color: Theme.orange.opacity(0.45), radius: 28, y: 8)
                        .glassEffect(.clear)
                    Text("Log as\nLearned")
                        .foregroundStyle(.white)
                case .learned:
                    Circle()
                        .fill(Theme.card)
                        .overlay(Circle().stroke(Theme.orange.opacity(0.7), lineWidth: 2))
                        .shadow(color: Theme.orange.opacity(0.25), radius: 18, y: 4)
                    Text("Learned\nToday")
                        .foregroundStyle(.orange)
                case .frozen:
                    Circle()
                        .fill(Theme.bg)
                        .overlay(Circle().stroke(Theme.teal.opacity(0.8), lineWidth: 2))
                        .shadow(color: Theme.teal.opacity(0.25), radius: 18, y: 4)
                        .glassEffect(.clear)
                    Text("Day\nFreezed")
                        .foregroundStyle(.teal)
                }
            }
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .multilineTextAlignment(.center)
            .frame(width: 280, height: 280)
        }
        .buttonStyle(.plain)
        .disabled(todayStatus != .none) // disable if already learned/frozen today
    }
}

// MARK: - Freeze Section

private extension ActivityView {
    var freezeSection: some View {
        VStack(spacing: 8) {
            Button {
                if todayStatus == .none && freezesLeft > 0 {
                    setStatus(.frozen, for: Date())
                }
            } label: {
                Text("Log as Freezed")
                    .font(.headline.weight(.semibold))
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(
                        Capsule()
                            .fill(Theme.teal.opacity((todayStatus == .none && freezesLeft > 0) ? 1.0 : 0.22))
                            .overlay(Capsule().stroke(Theme.stroke, lineWidth: 1))
                    )
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .disabled(!(todayStatus == .none && freezesLeft > 0))
            
            Text("\(usedFreezes)/\(plan.freezeAllowance) Freezes used")
                .font(.footnote)
                .foregroundStyle(Theme.sub)
        }
        .padding(.bottom, 16)
    }
}

// MARK: - Computed (calendar + stats)

private extension ActivityView {
    var calendar: Calendar { Calendar.current }
    
    /// First day of the selected month
    var firstOfMonth: Date {
        let comps = calendar.dateComponents([.year, .month], from: selectedMonthAnchor)
        return calendar.date(from: comps) ?? selectedMonthAnchor
    }
    
    /// All weeks that intersect the month (each is an array of 7 dates, Sunday-Saturday)
    var weeksInMonth: [[Date]] {
        var weeks: [[Date]] = []
        var cursor = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: firstOfMonth)) ?? firstOfMonth
        let month = calendar.component(.month, from: firstOfMonth)
        // Keep capturing weeks while they intersect the month
        while true {
            let oneWeek = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: cursor) }
            weeks.append(oneWeek)
            // Stop when next week's Sunday is in a different month and current week already passed the month
            guard let next = calendar.date(byAdding: .weekOfYear, value: 1, to: cursor) else { break }
            let lastDayThisWeek = oneWeek[6]
            let lastMonth = calendar.component(.month, from: lastDayThisWeek)
            let nextMonth = calendar.component(.month, from: next)
            if lastMonth != month && nextMonth != month { break }
            cursor = next
        }
        return weeks
    }
    
    var visibleWeekDays: [Date] {
        let w = weeksInMonth
        guard !w.isEmpty else { return [] }
        let index = min(max(0, weekOffset), w.count - 1)
        return w[index]
    }
    
    func moveWeek(_ delta: Int) {
        let new = weekOffset + delta
        if new < 0 {
            // move to previous month’s last week
            if let prevMonth = calendar.date(byAdding: .month, value: -1, to: firstOfMonth) {
                selectedMonthAnchor = prevMonth
                weekOffset = max(weeksInMonth.count - 1, 0)
            }
        } else if new >= weeksInMonth.count {
            // move to next month’s first week
            if let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstOfMonth) {
                selectedMonthAnchor = nextMonth
                weekOffset = 0
            }
        } else {
            weekOffset = new
        }
    }
    
    func monthYear(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: d)
    }
    func shortWeekday(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: d)
    }
    
    // Normalize to startOfDay as dictionary key
    func key(_ date: Date) -> Date { calendar.startOfDay(for: date) }
    
    func statusForDate(_ date: Date) -> DayStatus {
        log[key(date)] ?? .none
    }
    func setStatus(_ s: DayStatus, for date: Date) {
        log[key(date)] = s
    }
    
    var todayStatus: DayStatus { statusForDate(Date()) }
    
    // STAT window depends on plan
    var statWindowRange: (start: Date, end: Date) {
        let today = calendar.startOfDay(for: Date())
        switch plan {
        case .week:
            // current week Sunday...Saturday
            let comp = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
            let start = calendar.date(from: comp) ?? today
            let end = calendar.date(byAdding: .day, value: 7, to: start)! // non-inclusive end
            return (start, end)
        case .month:
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
            let end = calendar.date(byAdding: .month, value: 1, to: start)!
            return (start, end)
        case .year:
            let start = calendar.date(from: calendar.dateComponents([.year], from: today)) ?? today
            let end = calendar.date(byAdding: .year, value: 1, to: start)!
            return (start, end)
        }
    }
    
    var learnedCountInWindow: Int {
        log.filter { (date, status) in
            status == .learned && date >= statWindowRange.start && date < statWindowRange.end
        }.count
    }
    var frozenCountInWindow: Int {
        log.filter { (date, status) in
            status == .frozen && date >= statWindowRange.start && date < statWindowRange.end
        }.count
    }
    
    var usedFreezes: Int { frozenCountInWindow }
    var freezesLeft: Int { max(0, plan.freezeAllowance - usedFreezes) }
}

// MARK: - Midnight reset (enable buttons next day)

private extension ActivityView {
    func scheduleMidnightRefresh() {
        // Cancel previous
        midnightCancellable?.cancel()
        // Time until next midnight
        let now = Date()
        let cal = Calendar.current
        let nextMidnight = cal.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0, second: 1), matchingPolicy: .nextTimePreservingSmallerComponents) ?? now.addingTimeInterval(86401)
        let delay = nextMidnight.timeIntervalSince(now)
        midnightCancellable = Just(())
            .delay(for: .seconds(delay), scheduler: RunLoop.main)
            .sink { _ in
                // Just triggers a state change; UI re-evaluates todayStatus (no extra work needed)
                // Re-schedule for the following midnight
                scheduleMidnightRefresh()
            }
    }
}

// MARK: - Shape styles for week dots

private extension ActivityView {
    func fillFor(_ s: DayStatus) -> some ShapeStyle {
        switch s {
        case .none:    return Theme.chip
        case .learned: return Theme.orange.opacity(0.85)
        case .frozen:  return Theme.teal.opacity(0.85)
        }
    }
    func strokeFor(_ s: DayStatus, isToday: Bool) -> Color {
        if isToday { return .white.opacity(0.35) }
        switch s {
        case .none:    return Theme.stroke
        case .learned: return Theme.orange.opacity(0.9)
        case .frozen:  return Theme.teal.opacity(0.9)
        }
    }
    func textFor(_ s: DayStatus) -> Color {
        switch s {
        case .none:    return Theme.label
        case .learned: return .white
        case .frozen:  return .white
        }
    }
}

// MARK: - Month/Year Picker (only month + year)

struct MonthYearPickerView: View {
    let onChange: (Date) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var month: Int
    @State private var year: Int
    
    init(initial: Date, onChange: @escaping (Date) -> Void) {
        self.onChange = onChange
        let cal = Calendar.current
        _month = State(initialValue: cal.component(.month, from: initial))
        _year  = State(initialValue: cal.component(.year,  from: initial))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Select Month & Year")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.top, 16)
            
            HStack(spacing: 24) {
                Picker("Month", selection: $month) {
                    ForEach(1...12, id: \.self) { m in
                        Text(DateFormatter().monthSymbols[m-1]).tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                
                Picker("Year", selection: $year) {
                    ForEach(2020...2032, id: \.self) { y in
                        Text("\(y)").tag(y)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .foregroundStyle(.white)
            
            Button {
                var comps = DateComponents()
                comps.year = year
                comps.month = month
                comps.day = 1
                let date = Calendar.current.date(from: comps) ?? Date()
                onChange(date)
                dismiss()
            } label: {
                Text("Done")
                    .font(.headline.weight(.semibold))
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        Capsule().fill(Theme.orange)
                            .overlay(Capsule().stroke(.white.opacity(0.1), lineWidth: 1))
                    )
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Theme.bg.ignoresSafeArea())
    }
}

// MARK: - Reusable bits

struct StatPill: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(tint.opacity(0.9)))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline.weight(.semibold)).foregroundStyle(.white)
                Text(subtitle).font(.caption).foregroundStyle(Theme.sub)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            Capsule().fill(Theme.chip)
                .overlay(Capsule().stroke(Theme.stroke, lineWidth: 1))
        )
    }
}

// MARK: - Preview

#Preview {
    ActivityView()
}
