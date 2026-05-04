import SwiftUI

struct PrimaryButton: View {
    let title: String
    var trailingSystemImage: String?
    var leadingSystemImage: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.stackSm) {
                if let leadingSystemImage {
                    Image(systemName: leadingSystemImage)
                        .font(.system(size: 18, weight: .regular))
                }
                Text(title)
                    .appFont(.labelLg)
                if let trailingSystemImage {
                    Image(systemName: trailingSystemImage)
                        .font(.system(size: 18, weight: .regular))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundStyle(AppColor.onPrimary)
            .background(AppColor.primary, in: RoundedRectangle(cornerRadius: Radius.standard))
        }
        .buttonStyle(.pressable)
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressableButtonStyle {
    static var pressable: PressableButtonStyle { PressableButtonStyle() }
}

#Preview {
    VStack(spacing: Spacing.stackMd) {
        PrimaryButton(title: "Build My Profile", trailingSystemImage: "arrow.right") {}
        PrimaryButton(title: "Save to Closet", leadingSystemImage: "tray.and.arrow.down.fill") {}
        PrimaryButton(title: "Wear This") {}
    }
    .padding(Spacing.containerMargin)
    .background(AppColor.surface)
}
