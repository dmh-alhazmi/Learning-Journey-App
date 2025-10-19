import SwiftUI

public extension View {
    /// Applies a subtle “glass” style: blurred material background + soft gradient,
    /// thin stroke, and an inner top highlight. Works well on dark and light themes.
    func glassEffect(
        material: Material = .ultraThinMaterial,
        cornerRadius: CGFloat = 16,
        strokeOpacity: CGFloat = 0.18,
        backgroundOpacity: CGFloat = 0.25,
        highlightOpacity: CGFloat = 0.35
    ) -> some View {
        modifier(GlassEffectModifier(material: material,
                                     cornerRadius: cornerRadius,
                                     strokeOpacity: strokeOpacity,
                                     backgroundOpacity: backgroundOpacity,
                                     highlightOpacity: highlightOpacity))
    }
}

private struct GlassEffectModifier: ViewModifier {
    let material: Material
    let cornerRadius: CGFloat
    let strokeOpacity: CGFloat
    let backgroundOpacity: CGFloat
    let highlightOpacity: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(material)
                    .opacity(backgroundOpacity)
            )
            .overlay(
                // Soft vertical sheen
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.30),
                                Color.white.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.softLight)
                    .allowsHitTesting(false)
            )
            .overlay(
                // Hairline stroke to define the edge
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(strokeOpacity), lineWidth: 1)
                    .allowsHitTesting(false)
            )
            .overlay(
                // Inner top highlight
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(highlightOpacity),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
                    .blendMode(.overlay)
                    .mask(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .padding(1)
                    )
                    .allowsHitTesting(false)
            )
    }
}
