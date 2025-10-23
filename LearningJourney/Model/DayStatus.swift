//
//  DayStatus.swift
//  LearningJourney
//
//  Created by Deemah Alhazmi on 23/10/2025.
//

import Foundation
import SwiftUI
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
