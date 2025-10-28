//
//  LearningGoal.swift
//  LearningJourney
//
//  Created by Deemah Alhazmi on 22/10/2025.
//

import SwiftUI
import UserNotifications
import Swift

struct LearningGoal: View {
    // MARK: - Stored
    @AppStorage("habit_name") private var habitName: String = "Swift"
    @AppStorage("habit_plan") private var habitPlanRaw: String = Plan.week.rawValue
    @AppStorage("has_set_goal") private var hasSetGoal: Bool = false

    // MARK: - Local
    @State private var Habbit: String = "Swift"
    @FocusState private var isSubjectFocused: Bool
    @State private var duration: Plan = .week
    @State private var hasChanges = false

    // In-app confirmation overlay
    @State private var showConfirm = false

    // Dismiss + completion
    @Environment(\.dismiss) private var dismiss
    let onDone: () -> Void
    init(onDone: @escaping () -> Void = {}) { self.onDone = onDone }

    var body: some View {
        ZStack {
            // Content
            VStack(alignment: .leading, spacing: 24) {

                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                            //.glassEffect(.clear)
                            .padding(18)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .glassEffect(.clear .interactive(true))
                                )
                    }

                    Spacer()
                    Text("Learning Goal")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()

                    // Show only if changed
                    if hasChanges {
                        Button { onTapSave() } label: {
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
                        .transition(.opacity.combined(with: .scale))
                    }
                }

                // Habit
                VStack(alignment: .leading, spacing: 10) {
                    Text("I want to learn")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)

                    TextField("Type a goal…", text: $Habbit)
                        .focused($isSubjectFocused)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.vertical, 8)
                        .onChange(of: Habbit) { _, _ in detectChanges() }   // iOS 17+ syntax

                    Divider().background(.white.opacity(0.15))
                }

                // Duration
                VStack(alignment: .leading, spacing: 14) {
                    Text("I want to learn it in a")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)

                    HStack(spacing: 16) {
                        ForEach(Plan.allCases) { option in
                            ChoiceChip(
                                text: option.rawValue,
                                isSelected: duration == option
                            ) {
                                duration = option
                                detectChanges()
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.top, 28)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            // MARK: - Overlay confirmation (like your Sketch)
            if showConfirm {
                Color.black.opacity(0.99).ignoresSafeArea()
                    .transition(.opacity)

                VStack(spacing: 12) {
                    Text("Update Learning goal")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)

                    Text("If you update now, your streak will start over.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)

                    HStack(spacing: 12) {
                        Button {
                            withAnimation(.easeInOut) { showConfirm = false }
                        } label: {
                            Text("Dismiss")
                                .font(.headline)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.12))
                                        .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
                                )
                                .foregroundStyle(.white)
                        }

                        Button {
                            commitSave(isNewGoal: true)
                        } label: {
                            Text("Update")
                                .font(.headline)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    Capsule()
                                        .fill(Theme.orange)
                                        .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
                                )
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.vertical, 18)
                .padding(.horizontal, 18)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.18), lineWidth: 1))
                        .shadow(color: .black.opacity(0.35), radius: 20, y: 8)
                )
                .padding(.horizontal, 28)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            Habbit = habitName
            duration = Plan(rawValue: habitPlanRaw) ?? .week
            detectChanges()
        }
        .animation(.easeInOut(duration: 0.25), value: hasChanges)
    }

    // MARK: - Actions

    private func detectChanges() {
        let trimmed = Habbit.trimmingCharacters(in: .whitespacesAndNewlines)
        hasChanges = (trimmed != habitName) || (duration.rawValue != habitPlanRaw)
    }

    private func onTapSave() {
        let trimmed = Habbit.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // If the habit name changed, show the confirmation overlay first
        if trimmed != habitName {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                showConfirm = true
            }
        } else {
            // Only duration changed: commit immediately
            commitSave(isNewGoal: false)
        }
    }

    private func commitSave(isNewGoal: Bool) {
        let trimmed = Habbit.trimmingCharacters(in: .whitespacesAndNewlines)
        habitName = trimmed.isEmpty ? "Learning" : trimmed
        habitPlanRaw = duration.rawValue
        hasSetGoal = true
        isSubjectFocused = false
        hasChanges = false

        if isNewGoal {
            scheduleNewGoalNotification()
        }

        // Close overlay (if visible) and leave page
        withAnimation(.easeInOut) { showConfirm = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDone()
            dismiss()
        }
    }

    private func scheduleNewGoalNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }

            let content = UNMutableNotificationContent()
            content.title = "New Learning Goal Started!"
            content.body  = "You’ve begun learning \(Habbit). Keep it up!"
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            let request = UNNotificationRequest(identifier: "newGoalNotification", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
}

#Preview { LearningGoal() }
