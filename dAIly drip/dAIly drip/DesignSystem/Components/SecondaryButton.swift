import SwiftUI

struct SecondaryButton: View {
    let title: String
    var systemImage: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.stackSm) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .regular))
                }
                Text(title)
                    .appFont(.labelLg)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundStyle(AppColor.onSurface)
            .overlay {
                RoundedRectangle(cornerRadius: Radius.standard)
                    .stroke(AppColor.onSurface, lineWidth: 1)
            }
        }
        .buttonStyle(.pressable)
    }
}

#Preview {
    VStack(spacing: Spacing.stackMd) {
        SecondaryButton(title: "Re-do my profile", systemImage: "arrow.counterclockwise") {}
        SecondaryButton(title: "View All") {}
    }
    .padding(Spacing.containerMargin)
    .background(AppColor.surface)
}
