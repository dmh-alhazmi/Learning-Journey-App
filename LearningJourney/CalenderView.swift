//
//  CalendarView.swift
//  LearningJourney
//
//  Created by Deemah Alhazmi on 22/10/2025.
//

import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()
    private let calendar = Calendar.current
    
    // Generate all months in the current year
    private var months: [Date] {
        let year = calendar.component(.year, from: Date())
        return (1...12).compactMap {
            calendar.date(from: DateComponents(year: year, month: $0))
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    ForEach(months, id: \.self) { month in
                        monthSection(for: month)
                            .id(monthID(for: month)) // 👈 each month has an ID
                    }
                }
                .padding(.vertical, 20)
            }
            .background(Color.black.ignoresSafeArea())
            .preferredColorScheme(.dark)
            // 👇 scroll to current month when view appears
            .onAppear {
                if let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        proxy.scrollTo(monthID(for: currentMonth), anchor: .top)
                    }
                }
            }
        }
    }
    
    // MARK: - Month Section
    private func monthSection(for month: Date) -> some View {
        let monthName = monthNameFormatter.string(from: month)
        let days = daysInMonth(month)
        
        return VStack(alignment: .leading, spacing: 8) {
            Text(monthName)
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
                .padding(.leading, 16)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(days, id: \.self) { date in
                    dayCell(for: date)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Day Cell
    private func dayCell(for date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let day = calendar.component(.day, from: date)
        
        return Button {
            selectedDate = date
        } label: {
            Text("\(day)")
                .font(.subheadline.weight(.semibold))
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(isSelected ? Theme.orange : (isToday ? Theme.orange.opacity(0.25) : Color.clear))
                )
                .foregroundColor(isSelected ? .white : .white.opacity(0.85))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Helpers
    private func daysInMonth(_ date: Date) -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date))
        else { return [] }
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        }
    }
    
    private func monthID(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        return f.string(from: date)
    }
    
    private var monthNameFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f
    }
}

#Preview {
    CalendarView()
}
