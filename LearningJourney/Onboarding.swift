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

    // MARK: - Navigation
    private enum Route: Hashable {
        case activity
    }
    @State private var path: [Route] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                // MARK: Background
                Color.black.ignoresSafeArea()
                
                // MARK: Content
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Top icon badge (glow + ring)
                    ZStack (){
                        
                        Circle()
                            .fill(Color(red: 97/225, green: 56/225, blue: 20/225) .opacity(0.3))
                            //.fill(Color.orange.opacity(0.11))
                            .frame(width: 109, height: 109)
                            .glassEffect(.clear)
                        
                            .overlay(
                                Circle()
                                    .stroke(Color(red: 97/225, green: 56/225, blue: 20/225) .opacity(0.4), lineWidth: 4)
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
                    
                    // Start button
                    PrimaryButton(title: "") {
                        // Save onboarding data if needed, then navigate
                        // e.g., UserDefaults.standard.set(subject, forKey: "HabitName")
                        path.append(.activity)
                    }
                    .frame(width: 182) // fixed width
                    .frame(maxWidth: .infinity, alignment: .center) // center within parent
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

// MARK: - Reusable Components

/// Pill-style selectable chip
struct ChoiceChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.headline.weight(.semibold))
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(red: 255/225, green: 146/225, blue: 20/225) : Color.clear)
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(isSelected ? 0.0 : 0.18), lineWidth: 1)
                        )
                        .modifier(GlassWhenUnselected(isSelected: isSelected))
                        .shadow(radius: isSelected ? 8 : 0)
                )
                .foregroundStyle(isSelected ? .white : .white.opacity(0.9))
        }
        .buttonStyle(.plain)
    }
}

private struct GlassWhenUnselected: ViewModifier {
    let isSelected: Bool
    func body(content: Content) -> some View {
        if isSelected {
            content
                //.glassEffect( .regular )
                .glassEffect(.regular.tint(.red.opacity(0.4)).interactive())
        } else {
            content
              //  .glassEffect(cornerRadius: 28, strokeOpacity: 0.18, backgroundOpacity: 0.22)
                .glassEffect( .clear .interactive())
            
        }
    }
}

/// Primary rounded button with subtle gradient
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Start Learning")

                .font(.headline.weight(.semibold))
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .glassEffect(.regular.tint(.red.opacity(0.3)).interactive())
                .background(
                    Capsule()
                        .fill(Color(red: 255/225, green: 146/225, blue: 20/225))
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white .opacity(0.4), lineWidth: 2)
                        .blur(radius: 1)
                        .mask(Capsule().fill(LinearGradient(colors: [.white, .clear],
                                                           startPoint: .topLeading,
                                                           endPoint: .bottomTrailing)))
                )
                .glassEffect( .regular .interactive())
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 24)
    }
}

// MARK: - Preview
#Preview {
    OnboardingView()
}
