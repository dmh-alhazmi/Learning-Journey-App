//
//  ActivityView.swift
//  LearningJourney
//
//  Created by Deemah Alhazmi on 19/10/2025.
//

import SwiftUI
import Combine

struct ActivityView: View {
    // Use the view model that already contains scheduling and state.
    @StateObject private var vm = ActivityViewModel()

    // Month/year pickers and date wheel state
    @State private var showMonthPicker = false
    @State private var selectedDate = Date()
    @State private var showSystemPicker = false
    @State private var showCalendar = false
    @State private var showLearningGoal = false


    // Routing for value-based navigation
    private enum Route: Hashable { case learningGoal }

    var body: some View {
        ZStack {
          //  Theme.bg.ignoresSafeArea()
            VStack(spacing: 20) {
                header
                card
                bigCircle
                freezeSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .navigationDestination(isPresented: $showLearningGoal) {
                        LearningGoal()
                    }
                    .navigationDestination(isPresented: $showCalendar) {
                        CalendarView()
                    }
        }
        // 👇 Destination mapping for value-based links in this view
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .learningGoal:
                LearningGoal()
                    .navigationBarBackButtonHidden(false)
            }
        }
        // Month/Year custom sheet
        .sheet(isPresented: $showMonthPicker) {
            MonthYearPickerView(initial: vm.selectedMonthAnchor) { newMonth in
                vm.selectedMonthAnchor = newMonth
                selectedDate = newMonth
                vm.weekOffset = 0 // reset to first week in that month
            }
            .preferredColorScheme(.dark)
        }
        // System date picker (wheel) sheet
        .sheet(isPresented: $showSystemPicker) {
            VStack(spacing: 16) {
                Text("Select Date")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.top, 16)

                DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .tint(.white)

                Button("Done") {
                    vm.selectedMonthAnchor = selectedDate
                    vm.weekOffset = 0
                    showSystemPicker = false
                }
                .font(.headline.weight(.semibold))
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule().fill(Theme.orange)
                        .overlay(Capsule().stroke(.white.opacity(0.1), lineWidth: 1))
                        .glassEffect(.clear)
                )
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(Theme.bg)
            .preferredColorScheme(.dark)
        }
        .onAppear { vm.scheduleMidnightRefresh() }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Header

private extension ActivityView {
    var header: some View {
        HStack(spacing: 12) {
            Text("Activity")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Theme.label)

            Spacer()

            // calendar button (sheet trigger later if you want)
            Button {
                // showMonthPicker = true
            } label: {
                Image(systemName: "calendar")
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                            .glassEffect(.clear .interactive(true))
                    )
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            // Edit Button -> LearningGoal (value-based link)
            // Learning goal button (Task 3 + 4)
                        Button { showLearningGoal = true } label: {
                            Image(systemName: "pencil.and.outline")
                                .padding(10)
                                .background(Circle().fill(.white.opacity(0.1)))
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)
        }
    }
}


// MARK: - Card (Month + Week strip + Stats)

private extension ActivityView {
    var card: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Month row with picker & week arrows
            HStack(spacing: 12) {
                Button { showMonthPicker = true } label: {
                    HStack(spacing: 6) {
                        Text(monthYear(vm.selectedMonthAnchor)).font(.headline)
                        Image(systemName: "chevron.right" ).font(.subheadline.weight(.semibold) )
                    }
                    .foregroundStyle(Theme.label)
                }

                Spacer()

                HStack(spacing: 18) {
                    Button { moveWeek(-1) } label: { Image(systemName: "chevron.left") }
                    Button { moveWeek(+1) } label: { Image(systemName: "chevron.right") }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.orange)
            }

            weekStrip

            Divider().background(Theme.stroke)

            // Stats
            HStack(spacing: 12) {
                StatPill(icon: "flame.fill",
                         title: "\(learnedCountInWindow)",
                         subtitle: learnedCountInWindow == 1 ? "Day Learned" : "Days Learned",
                         tint: Theme.orange,
                         background: Theme.orange)
                StatPill(icon: "cube.fill",
                         title: "\(frozenCountInWindow)",
                         subtitle: frozenCountInWindow == 1 ? "Day Freezed" : "Days Freezed",
                         tint: Theme.teal,
                         background: Theme.teal)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous )
                .fill(Theme.card)
                //.glassEffect(.clear)
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Theme.stroke, lineWidth: 1))
        )
    }

    var weekStrip: some View {
        let days = visibleWeekDays
        return HStack(spacing: 10) {
            ForEach(days, id: \.self) { d in
                let isToday = Calendar.current.isDateInToday(d)
                let number  = Calendar.current.component(.day, from: d)
                let status  = vm.statusForDate(d)

                VStack(spacing: 6) {
                    Text(shortWeekday(d).uppercased())
                        .font(.caption2)
                        .foregroundStyle(Theme.sub)

                    ZStack {
                        Circle()
                            .fill(fillFor(status))
                            .overlay(
                                Circle().stroke(strokeFor(status, isToday: isToday),
                                                lineWidth: isToday ? 2 : 1)
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
            if case .none = vm.todayStatus { vm.setStatus(.learned, for: Date()) }
        } label: {
            ZStack {
                switch vm.todayStatus {
                case .none:
                    Circle().fill(Theme.orange).glassEffect(.regular)
                        .overlay(Circle().stroke(Theme.orange.opacity(0.2), lineWidth: 0.01).glassEffect(.regular .tint(Theme.orange) .interactive()))
                    Text("Log as\nLearned").foregroundStyle(.white)

                case .learned:
                    Circle().fill(Theme.card)
                        .overlay(Circle().stroke(Theme.orange.opacity(0.7), lineWidth: 0.1).glassEffect(.regular))
                        .shadow(color: Theme.orange.opacity(0.15), radius: 18, y: 4).glassEffect(.clear)
                    Text("Learned\nToday").foregroundStyle(Theme.orange)

                case .frozen:
                    Circle().fill(Theme.bg)
                        .overlay(Circle().stroke(Theme.teal.opacity(0.8), lineWidth: 2).glassEffect(.regular))
                        .shadow(color: Theme.teal.opacity(0.15), radius: 10, y: 2).glassEffect(.regular)
                    Text("Day\nFreezed").foregroundStyle(Theme.teal)
                }
            }
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .multilineTextAlignment(.center)
            .frame(width: 280, height: 280)
        }
        .buttonStyle(.plain)
        .disabled(vm.todayStatus != .none) // disable if already learned/frozen today
    }
}

// MARK: - Freeze Section

private extension ActivityView {
    var freezeSection: some View {
        VStack(spacing: 8) {
            Button {
                if vm.todayStatus == .none && freezesLeft > 0 { vm.setStatus(.frozen, for: Date()) }
            } label: {
                Text("Log as Freezed")
                    .font(.headline.weight(.semibold))
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(
                        Capsule()
                            .fill(Theme.teal.opacity((vm.todayStatus == .none && freezesLeft > 0) ? 1.0 : 0.22))
                            .overlay(Capsule().stroke(Theme.stroke, lineWidth: 1))
                    )
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .disabled(!(vm.todayStatus == .none && freezesLeft > 0))

            Text("\(usedFreezes) out of \(vm.plan.freezeAllowance) Freezes used")
                .font(.footnote)
                .foregroundStyle(Theme.sub)
        }
        .padding(.bottom, 16)
    }
}

// MARK: - Calendar + Stats

private extension ActivityView {
    // Keep using the system calendar
    var calendar: Calendar { Calendar.current }

    /// First day of the selected month
    var firstOfMonth: Date {
        let comps = calendar.dateComponents([.year, .month], from: vm.selectedMonthAnchor)
        return calendar.date(from: comps) ?? vm.selectedMonthAnchor
    }

    /// All weeks that intersect the month (each is an array of 7 dates, Sunday–Saturday)
    var weeksInMonth: [[Date]] {
        var out: [[Date]] = []
        guard let monthInterval = calendar.dateInterval(of: .month, for: firstOfMonth) else { return out }
        var startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: monthInterval.start))!

        repeat {
            out.append((0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) })
            startOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)!
        } while startOfWeek < monthInterval.end

        return out
    }

    /// Helper: index of the week that contains a given date (if any)
    func weekIndexContaining(_ date: Date, in weeks: [[Date]]) -> Int? {
        let day = calendar.startOfDay(for: date)
        return weeks.firstIndex { week in
            week.contains { calendar.isDate($0, inSameDayAs: day) }
        }
    }

    var visibleWeekDays: [Date] {
        let weeks = weeksInMonth
        guard !weeks.isEmpty else { return [] }

        // Clamp any manual offset
        let clamped = min(max(0, vm.weekOffset), weeks.count - 1)

        // Prefer today's week when viewing the current month and the user hasn't moved weeks yet
        let today = calendar.startOfDay(for: Date())
        let (mAnchor, yAnchor) = (calendar.component(.month, from: firstOfMonth), calendar.component(.year, from: firstOfMonth))
        let (mToday,  yToday)  = (calendar.component(.month, from: today),         calendar.component(.year, from: today))

        if vm.weekOffset == 0, mAnchor == mToday, yAnchor == yToday,
           let idx = weekIndexContaining(today, in: weeks) {
            return weeks[idx]
        }

        return weeks[clamped]
    }

    func moveWeek(_ delta: Int) {
        let new = vm.weekOffset + delta
        if new < 0 {
            if let prev = calendar.date(byAdding: .month, value: -1, to: firstOfMonth) {
                vm.selectedMonthAnchor = prev
                vm.weekOffset = max(weeksInMonth.count - 1, 0)
            }
        } else if new >= weeksInMonth.count {
            if let next = calendar.date(byAdding: .month, value: 1, to: firstOfMonth) {
                vm.selectedMonthAnchor = next
                vm.weekOffset = 0
            }
        } else {
            vm.weekOffset = new
        }
    }

    func monthYear(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "LLLL yyyy"; return f.string(from: d)
    }
    func shortWeekday(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "EEE"; return f.string(from: d)
    }

    var todayStatus: DayStatus { vm.todayStatus } // kept if needed elsewhere

    // STAT window depends on plan
    var statWindowRange: (start: Date, end: Date) {
        let today = calendar.startOfDay(for: Date())
        switch vm.plan {
        case .week:
            let comp  = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
            let start = calendar.date(from: comp) ?? today
            let end   = calendar.date(byAdding: .day, value: 7, to: start)!
            return (start, end)
        case .month:
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
            let end   = calendar.date(byAdding: .month, value: 1, to: start)!
            return (start, end)
        case .year:
            let start = calendar.date(from: calendar.dateComponents([.year], from: today)) ?? today
            let end   = calendar.date(byAdding: .year, value: 1, to: start)!
            return (start, end)
        }
    }

    var learnedCountInWindow: Int {
        vm.log.filter { $0.value == .learned && $0.key >= statWindowRange.start && $0.key < statWindowRange.end }.count
    }
    var frozenCountInWindow: Int {
        vm.log.filter { $0.value == .frozen  && $0.key >= statWindowRange.start && $0.key < statWindowRange.end }.count
    }

    var usedFreezes: Int { frozenCountInWindow }
    var freezesLeft: Int { max(0, vm.plan.freezeAllowance - usedFreezes) }
}

// MARK: - Shape styles for week dots

private extension ActivityView {
    func fillFor(_ s: DayStatus) -> some ShapeStyle {
        switch s {
        case .none:    return Theme.chip
        case .learned: return Theme.orange.opacity(0.20)
        case .frozen:  return Theme.teal.opacity(0.15)
        }
    }
    func strokeFor(_ s: DayStatus, isToday: Bool) -> Color {
        if isToday { return .white.opacity(0.40) }
        switch s {
        case .none:    return Theme.stroke
        case .learned: return Theme.orange.opacity(0.01)
        case .frozen:  return Theme.teal.opacity(0.01)
        }
    }
    func textFor(_ s: DayStatus) -> Color {
        switch s {
        case .none:    return Theme.label
        case .learned: return Theme.orange
        case .frozen:  return Theme.teal
        }
    }
}

// MARK: - Preview

private var isPreview: Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}

#Preview {
    // Wrap in a NavigationStack so the pencil link works in the preview
    NavigationStack { ActivityView().preferredColorScheme(.dark) }
}
