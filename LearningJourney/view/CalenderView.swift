//
//  CalendarView.swift
//  LearningJourney
//
//  Created by Deemah Alhazmi on 22/10/2025.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var vm: CalendarViewModel
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    private let calendar = Calendar.current

    // gates to avoid infinite prefetch on first render
    @State private var didScrollToToday = false
    @State private var userHasScrolled  = false

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Be explicit about the ID
                    ForEach(vm.monthSections, id: \.monthStart) { section in
                        monthSection(section)
                            .padding(.horizontal, 16)
                            .id(section.monthStart)
                            // ✅ Prefetch ONLY after the user has started scrolling
                            .onAppear {
                                if userHasScrolled {
                                    vm.prefetchIfNeeded(appeared: section)
                                }
                            }
                    }
                }
                .padding(.vertical, 16)
                // mark that the user began scrolling (prevents boot-time prefetch loops)
                .gesture(
                    DragGesture().onChanged { _ in
                        userHasScrolled = true
                    }
                )
            }
            // Keep the initial auto-scroll; run only once
            .onReceive(vm.$monthSections) { _ in
                if !didScrollToToday {
                    scrollToCurrentMonth(proxy)
                    didScrollToToday = true
                }
            }
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("All activities")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }

    // MARK: - Scroll helper

    private func scrollToCurrentMonth(_ proxy: ScrollViewProxy) {
        guard let target = vm.monthSections.first(where: {
            calendar.isDate($0.monthStart, equalTo: Date(), toGranularity: .month)
        }) else { return }

        withAnimation {
            proxy.scrollTo(target.monthStart, anchor: .center)
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private func monthSection(_ section: MonthSection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(section.title)
                    .font(.headline)
                    .foregroundStyle(Theme.label)
                Spacer()
            }

            // Weekday headers
            HStack {
                ForEach(["SUN","MON","TUE","WED","THU","FRI","SAT"], id: \.self) { w in
                    Text(w)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Theme.sub)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(section.days) { day in
                    dayCell(day)
                }
            }
            .padding(12)
        }
    }

    // MARK: - Day Cell

    @ViewBuilder
    private func dayCell(_ day: CalendarDay) -> some View {
        if day.isInCurrentMonth {
            let number = Calendar.current.component(.day, from: day.date)
            let isToday = Calendar.current.isDateInToday(day.date)
            let status = vm.status(for: day.date)

            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(fillFor(status))
                        .overlay(
                            Circle()
                                .stroke(strokeFor(status, isToday: isToday), lineWidth: isToday ? 2 : 1)
                        )
                        .frame(width: 32, height: 32)

                    Text("\(number)")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(textFor(status))
                }

                Circle()
                    .fill(textFor(status))
                    .frame(width: 4, height: 4)
                    .opacity(status == .none ? 0 : 0.9)
            }
            .frame(maxWidth: .infinity, minHeight: 42)
            .contentShape(Rectangle())
        } else {
            Color.clear.frame(width: 32, height: 42)
        }
    }

    // MARK: - Styling helpers

    private func fillFor(_ s: DayStatus) -> some ShapeStyle {
        switch s {
        case .none:    return Theme.chip
        case .learned: return Theme.orange.opacity(0.20)
        case .frozen:  return Theme.teal.opacity(0.15)
        }
    }
    private func strokeFor(_ s: DayStatus, isToday: Bool) -> Color {
        if isToday { return .white.opacity(0.40) }
        switch s {
        case .none:    return Theme.stroke
        case .learned: return Theme.orange.opacity(0.01)
        case .frozen:  return Theme.teal.opacity(0.01)
        }
    }
    private func textFor(_ s: DayStatus) -> Color {
        switch s {
        case .none:    return Theme.label
        case .learned: return Theme.orange
        case .frozen:  return Theme.teal
        }
    }
}
