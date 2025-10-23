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

// Primary rounded button with subtle gradient
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

struct GlassWhenUnselected: ViewModifier {
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
