import SwiftUI

struct OnboardingView: View {
    // MARK: - State
    @State private var subject: String = "Swift"
    @FocusState private var isSubjectFocused: Bool
    
    enum Duration: String, CaseIterable, Identifiable {
        case week = "Week", month = "Month", year = "Year"
        var id: String { rawValue }
    }
    @State private var duration: Duration = .week
    
    var body: some View {
        ZStack {
            // MARK: Background
            Color.black.ignoresSafeArea()
            
            // MARK: Content
            VStack(alignment: .leading, spacing: 24) {
                
                // Top icon badge (glow + ring)
                ZStack (){
                    Circle()
                        .fill(Color(red: 0.25, green: 0.10, blue: 0.00).opacity(0.8))
                        .frame(width: 109, height: 109)
                        .blur(radius: 18)
                        .overlay(
                            Circle()
                                .stroke(
                                    Color.orange.opacity(0.45),
                                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                )
                                // Apply glass to the ring
                                .glassEffect(cornerRadius: 54, strokeOpacity: 0.25, backgroundOpacity: 0.12)
                                .shadow(color: Color.orange.opacity(0.001), radius: 0, x: 0, y: 0)
                        )
            
                    Image(systemName: "flame.fill")
                        .font(.system(size: 45))
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
                    
                    TextField("Type a topic…", text: $subject)
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
                PrimaryButton(title: "Start learning") {
                    // TODO: action (e.g., save onboarding + navigate)
                }
              //  .glassEffect(.clear , in: .rect(cornerRadius: 108))
                .frame(width: 182) // fixed width
                .frame(maxWidth: .infinity, alignment: .center) // center within parent
                //.buttonStyle(.borderedProminent)
                .disabled(subject.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(subject.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1)
            }
            .padding(.horizontal, 28)
            .padding(.top, 28)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        // Light content for the status bar on dark background
        .preferredColorScheme(.dark)
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
                        .fill(isSelected ? Color.orange : Color.clear)
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
        } else {
            content
                .glassEffect(cornerRadius: 28, strokeOpacity: 0.18, backgroundOpacity: 0.22)
        }
    }
}

/// Primary rounded button with subtle gradient
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
            
                .font(.headline.weight(.semibold))
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .glassEffect(in: .rect(cornerRadius: 100))
                .background(
                    Capsule()
                        .fill(Color(red: 0.255, green: 0.146, blue: 0.048))
                        .glassEffect(.clear) // (255, 146, 48, 1)
                      //  .fill(Color.orange)
                ) // solid color, no gradient
                      /*  .overlay(
                            Capsule()
                                //.stroke(Color.white.opacity(0.10), lineWidth: 1)
                                .fill(Color(red: 0.255, green: 0.146, blue: 0.048).opacity(0.20))
                                .glassEffect(.clear)
                            
                        )*/
                      //  .shadow(color: Color.orange.opacity(0.25), radius: 12, y: 6)
                
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
