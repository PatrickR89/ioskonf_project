import SwiftUI

/// Pulsing "AI Analysis Active" pill shown over the scan canvas while inference runs.
struct AIPulseIndicator: View {
    let label: String
    @State private var pulse: Bool = false

    var body: some View {
        HStack(spacing: Spacing.stackSm) {
            ZStack {
                Circle()
                    .fill(AppColor.primaryFixedDim)
                    .frame(width: 12, height: 12)
                    .scaleEffect(pulse ? 1.6 : 1)
                    .opacity(pulse ? 0 : 0.75)
                Circle()
                    .fill(AppColor.primary)
                    .frame(width: 8, height: 8)
            }
            .accessibilityHidden(true)

            Text(label)
                .appFont(.labelMd)
                .foregroundStyle(AppColor.primary)
        }
        .padding(.horizontal, Spacing.stackMd)
        .padding(.vertical, Spacing.stackSm)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay { Capsule().stroke(AppColor.outlineVariant.opacity(0.5), lineWidth: 1) }
        .onAppear {
            // The pulse is purely decorative — respect Reduce Motion.
            if !UIAccessibility.isReduceMotionEnabled {
                withAnimation(.easeOut(duration: 1.4).repeatForever(autoreverses: false)) {
                    pulse = true
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
    }
}

#Preview {
    AIPulseIndicator(label: "AI Analysis Active")
        .padding()
        .background(AppColor.surface)
}
