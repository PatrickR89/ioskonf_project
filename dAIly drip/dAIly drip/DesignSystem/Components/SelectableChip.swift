import SwiftUI

/// Pill used for filter rows like the canned occasions on the Generate screen.
struct SelectableChip: View {
    let text: String
    let isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.stackSm / 2) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColor.onPrimary)
                        .transition(.opacity.combined(with: .scale))
                }
                Text(text)
                    .appFont(.labelMd)
                    .foregroundStyle(isSelected ? AppColor.onPrimary : AppColor.onSurfaceVariant)
            }
            .padding(.horizontal, Spacing.stackMd)
            .padding(.vertical, Spacing.stackSm)
            .background(
                isSelected ? AppColor.primary : AppColor.surfaceContainerHighest,
                in: Capsule()
            )
            .overlay {
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : AppColor.outlineVariant,
                        lineWidth: 1
                    )
            }
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.pressable)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    HStack {
        SelectableChip(text: "Chic Dinner Date", isSelected: true) {}
        SelectableChip(text: "Business Casual", isSelected: false) {}
    }
    .padding()
    .background(AppColor.surface)
}
