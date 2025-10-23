//
//  MonthYearPickerView.swift
//  LearningJourney
//
//  Created by Deemah Alhazmi on 23/10/2025.
//

import Foundation
import SwiftUI
// Month + Year picker (only one declaration in project)
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
