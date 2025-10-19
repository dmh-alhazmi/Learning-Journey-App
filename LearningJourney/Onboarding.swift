//
//  Onboarding.swift
//  LearningJourney
//
//  Created by Deemah Alhazmi on 16/10/2025.
//

import Foundation
import SwiftUI

struct Onboarding: View {
    @Environment(\.colorScheme) private var colorScheme

    // State
    @State private var topic: String = "Swift"
    @State private var selectedDuration: DurationChoice = .week
    @FocusState private var isTopicFocused: Bool

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // Top logo with subtle glow
                    VStack {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.15))
                                .frame(width: 140, height: 140)
                                .blur(radius: 20)
                            Circle()
                                .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                                .frame(width: 120, height: 120)
                                .shadow(color: .orange.opacity(0.4), radius: 8, x: 0, y: 0)
                            ZStack {
                                Circle()
                                    .fill(Color(white: 0.12))
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.orange)
                            }
                            .frame(width: 96, height: 96)
                            .shadow(color: .orange.opacity(0.35), radius: 10, x: 0, y: 0)
                        }
                        .padding(.top, 24)
                    }
                    .frame(maxWidth: .infinity)

                    // Headline
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hello Learner")
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)

                        Text("This app will help you learn everyday!")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                    }

                    // "I want to learn"
                    VStack(alignment: .leading, spacing: 12) {
                        Text("I want to learn")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)

                        TextField("Your topic", text: $topic)
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                            .foregroundColor(.white)
                            .keyboardType(.default)
                            .focused($isTopicFocused)
                            .padding(.vertical, 10)
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color.white.opacity(0.15)),
                                alignment: .bottom
                            )
                    }
                    .padding(.top, 12)

                    // Duration selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("I want to learn it in a")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)

                        HStack(spacing: 16) {
                            ForEach(DurationChoice.allCases, id: \.self) { choice in
                                Button {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                        selectedDuration = choice
                                    }
                                } label: {
                                    Text(choice.label)
                                        .frame(minWidth: 96)
                                }
                                .buttonStyle(PillToggle(isSelected: selectedDuration == choice))
                                .accessibilityLabel(choice.accessibilityLabel)
                                .accessibilityAddTraits(selectedDuration == choice ? .isSelected : [])
                            }
                        }
                    }

                    Spacer(minLength: 40)

                    // Start button
                    Button {
                        isTopicFocused = false
                        // Handle start action here (e.g., save onboarding data, navigate)
                    } label: {
                        Text("Start learning")
                            .frame(maxWidth: 128, maxHeight: 48)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.top, 12)
                }
                .padding(24)
                .padding(.bottom, 24)
            }
        }
        // Dismiss keyboard on drag
        .gesture(
            DragGesture().onChanged { _ in
                isTopicFocused = false
            }
        )
        .navigationBarHidden(true)
    }
}

// MARK: - DurationChoice

enum DurationChoice: CaseIterable {
    case week, month, year

    var label: String {
        switch self {
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .week: return "One week"
        case .month: return "One month"
        case .year: return "One year"
        }
    }
}

// MARK: - Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(configuration.isPressed ? 0.85 : 1.0),
                                Color(red: 0.65, green: 0.27, blue: 0.0)
                                    .opacity(configuration.isPressed ? 0.9 : 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.35), radius: 12, x: 0, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct PillToggle: ButtonStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.horizontal, 22)
            .padding(.vertical, 14)
            .background(
                Capsule(style: .continuous)
                    .fill(
                        isSelected
                        ? LinearGradient(
                            colors: [Color.orange, Color(red: 0.65, green: 0.27, blue: 0.0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                        : LinearGradient(
                            colors: [Color.white.opacity(0.08), Color.white.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                    )
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(isSelected ? Color.orange.opacity(0.0) : Color.white.opacity(0.12), lineWidth: 1)
            )
            .foregroundColor(.white)
            .shadow(color: isSelected ? Color.orange.opacity(0.35) : .clear, radius: 8, x: 0, y: 4)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
        Onboarding()
    }
    .preferredColorScheme(.dark)
}
