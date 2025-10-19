import SwiftUI

public extension View {
    /// Adds a glossy/glass-like border stroke around the view’s shape.
    /// This does NOT fill the background — just the border.
    func glassStroke(
        cornerRadius: CGFloat,
        lineWidth: CGFloat = 1,
        baseOpacity: CGFloat = 0.18,
        highlightOpacity: CGFloat = 0.45
    ) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(highlightOpacity), // top/leading highlight
                            Color.white.opacity(baseOpacity)       // bottom/trailing fade
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: lineWidth
                )
                .blendMode(.overlay)
        )
    }
}
