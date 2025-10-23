//
//  LearningGoal.swift
//  LearningJourney
//
//  Created by Deemah Alhazmi on 22/10/2025.
//

import Foundation
import SwiftUI

struct LearningGoal: View {
    //Stat Variables
    @State public var Habbit: String = "Swift"
    @FocusState private var isSubjectFocused: Bool
    
    enum Duration: String, CaseIterable, Identifiable {
        case week = "Week", month = "Month", year = "Year"
        var id: String { rawValue }
    }
    @State private var duration: Duration = .week
    
    private enum Route: Hashable {
        case activity
    }
    @State private var path: [Route] = []
    
    var body: some View {
        // Wrap in a NavigationStack so .navigationDestination works
        NavigationStack(path: $path) {
            ZStack {
                
                // MARK: Content
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Button {
                            // go to ActivityView
                            isSubjectFocused = false
                            path.append(.activity)
                        } label: {
                            Image(systemName: "chevron.left")
                                .padding(18)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                        .glassEffect(.clear .interactive(true))
                                )
                                .foregroundStyle(.white)
                        }
                        Spacer()
                        
                        Text("Learning Goal")
                        
                        Spacer()
                        
                        Button {
                            // go to ActivityView
                            isSubjectFocused = false
                            path.append(.activity)
                        } label: {
                            Image(systemName: "checkmark")
                                .padding(18)
                                .background(
                                    Circle()
                                        .fill(Theme.orange)
                                        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                        .glassEffect(.clear .interactive(true))
                                )
                                .foregroundStyle(.white)
                        }
                    }
                    // Section: I want to learn
                    VStack(alignment: .leading, spacing: 10) {
                        Text("I want to learn")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                        
                        TextField("Type a topic…", text: $Habbit)
                            .focused($isSubjectFocused)
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.vertical, 8)
                        
                        Divider().background(.white.opacity(0.15))
                    }
                    
                    // Section: Duration chips
                    VStack(alignment: .leading, spacing: 14) {
                        Text("I want to learn it in a")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                        
                        HStack(spacing: 16) {
                            ForEach(Duration.allCases) { option in
                                ChoiceChip(
                                    text: option.rawValue,
                                    isSelected: duration == option
                                ) {
                                    duration = option
                                }
                            }
                        }
                    }
                    
                    Spacer() // pushes button to bottom
                    
                    // (Your modifiers here currently apply to the Spacer; kept as-is per request)
                    .frame(width: 182)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(Habbit.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(Habbit.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1)
                }
                .padding(.horizontal, 28)
                .padding(.top, 28)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            // Light content for the status bar on dark background
            .preferredColorScheme(.dark)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .activity:
                    ActivityView()
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

#Preview {
    LearningGoal()
}
