//
//  SharedUI.swift
//  LearningJourney
//
//  Created by Deemah Alhazmi on 21/10/2025.
//

// SharedUI.swift
import SwiftUI

// MARK: Color hex helper (one place only)
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

// MARK: Theme (shared)
enum Theme {
    static let bg     = Color.black
    static let card   = Color.white.opacity(0.06)
    static let stroke = Color.white.opacity(0.10)
    static let label  = Color.white
    static let sub    = Color.white.opacity(0.6)
    static let orange = Color(hex: "FF9230")
    static let teal   = Color(hex: "0FA3A7")
    static let chip   = Color.white.opacity(0.08)
}

// MARK: Models (shared)
enum DayStatus: String, Codable { case none, learned, frozen }

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

// MARK: Reusable bits (shared)
struct StatPill: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color         // Color for icon
    let background: Color   // Color for whole StatPill background
    
    var body: some View {
        HStack(spacing: 10) {
            // Icon with color fill
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint) // directly color the icon, not its background
                .frame(width: 22, height: 22)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Theme.sub)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        // background color for the whole pill
        .background(
            Capsule()
                .fill(background)
                .overlay(Capsule().stroke(Theme.stroke, lineWidth: 1 ).glassEffect())
        )
    }
}


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
