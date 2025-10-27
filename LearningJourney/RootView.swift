//
//  RootView.swift
//  LearningJourney
//
//  Created by Deemah Alhazmi on 27/10/2025.
//

import SwiftUI

struct RootView: View {
    @AppStorage("has_seen_onboarding") private var hasSeenOnboarding = false
    @AppStorage("has_set_goal")        private var hasSetGoal = false

    @State private var showOnboarding   = false
    @State private var showLearningGoal = false

    var body: some View {
        NavigationStack {
            ActivityView()
        }
        .onAppear {
            if !hasSeenOnboarding {
                showOnboarding = true
            } else if !hasSetGoal {
                showLearningGoal = true
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {
                // This closure is what your button should call
                hasSeenOnboarding = true
                showOnboarding = false          // dismiss
                showLearningGoal = true         // then show the goal sheet
            }
        }
        .sheet(isPresented: $showLearningGoal) {
            NavigationStack {
                LearningGoal {
                    hasSetGoal = true
                    showLearningGoal = false
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
