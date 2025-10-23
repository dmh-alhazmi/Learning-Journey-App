import SwiftUI

struct OnboardingView: View {
    // MARK: - State
    @State public var Habbit: String = "Swift"
    @FocusState private var isSubjectFocused: Bool

    enum Duration: String, CaseIterable, Identifiable {
        case week = "Week", month = "Month", year = "Year"
        var id: String { rawValue }
    }
    @State private var duration: Duration = .week

    // Trigger to push ActivityView
    @State private var goToActivity = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {

                // Badge
                ZStack {
                    Circle()
                        .fill(Color(red: 97/225, green: 56/225, blue: 20/225).opacity(0.3))
                        .frame(width: 109, height: 109)
                        .glassEffect(.clear)
                        .overlay(
                            Circle()
                                .stroke(Color(red: 97/225, green: 56/225, blue: 20/225).opacity(0.4), lineWidth: 4)
                                .blur(radius: 2)
                                .offset(x: 1, y: 1)
                                .mask(Circle().fill(LinearGradient(colors: [.black, .clear],
                                                                   startPoint: .topLeading,
                                                                   endPoint: .bottomTrailing)))
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: "flame.fill")
                        .font(.system(size: 43, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)

                // Headline
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hello Learner")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)

                    Text("This app will help you learn everyday!")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }

                // Subject
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

                // Duration chips
                VStack(alignment: .leading, spacing: 14) {
                    Text("I want to learn it in a")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)

                    HStack(spacing: 16) {
                        ForEach(Duration.allCases) { option in
                            ChoiceChip(
                                text: option.rawValue,
                                isSelected: duration == option
                            ) { duration = option }
                        }
                    }
                }

                Spacer()

                // Start button -> trigger boolean
                PrimaryButton(title: "") {
                    // Persist if you want:
                    // UserDefaults.standard.set(Habbit, forKey: "habit_name")
                    // UserDefaults.standard.set(duration.rawValue, forKey: "habit_duration")
                    goToActivity = true
                }
                .frame(width: 182)
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(Habbit.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(Habbit.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1)
            }
            .padding(.horizontal, 28)
            .padding(.top, 28)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .preferredColorScheme(.dark)
        // ✅ Modern navigation push (requires a parent NavigationStack at the app root)
        .navigationDestination(isPresented: $goToActivity) {
            ActivityView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    // For previews only; at runtime your app root already wraps a NavigationStack (Option A).
    NavigationStack { OnboardingView() }
}
