import SwiftUI

/// Pill used for filter rows like the canned occasions on the Generate screen.
struct SelectableChip: View {
    let text: String
    let isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .appFont(.labelMd)
                .foregroundStyle(isSelected ? AppColor.onTertiaryFixed : AppColor.onSurfaceVariant)
                .padding(.horizontal, Spacing.stackMd)
                .padding(.vertical, Spacing.stackSm)
                .background(
                    isSelected ? AppColor.tertiaryFixed : AppColor.surfaceContainerHighest,
                    in: Capsule()
                )
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
