//
//  ActivityViewModel.swift
//  LearningJourney
//
//  Created by Deemah Alhazmi on 23/10/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ActivityViewModel: ObservableObject {
    @Published var plan: Plan = .week
    @Published var log: [Date: DayStatus] = [:]
    @Published var selectedMonthAnchor = Date()
    @Published var weekOffset: Int = 0
    
    // Holds the scheduled midnight tick subscription
    private var midnightCancellable: AnyCancellable?
    private let calendar = Calendar.current

    func setStatus(_ s: DayStatus, for date: Date) {
        log[calendar.startOfDay(for: date)] = s
    }

    func statusForDate(_ date: Date) -> DayStatus {
        log[calendar.startOfDay(for: date)] ?? .none
    }

    var todayStatus: DayStatus {
        statusForDate(Date())
    }

    // Midnight auto-refresh logic
    func scheduleMidnightRefresh() {
        // Cancel previous
        midnightCancellable?.cancel()

        // Time until next midnight
        let now = Date()
        let cal = Calendar.current
        let nextMidnight = cal.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 1),
            matchingPolicy: .nextTimePreservingSmallerComponents
        ) ?? now.addingTimeInterval(86401)

        let delay = nextMidnight.timeIntervalSince(now)

        midnightCancellable = Just(())
            .delay(for: .seconds(delay), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                // Trigger a re-computation then reschedule
                self?.objectWillChange.send() // notify views if needed
                self?.scheduleMidnightRefresh()
            }
    }
}

