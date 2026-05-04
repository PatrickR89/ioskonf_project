import SwiftUI

/// Multi-line text input with the floating-label style from the onboarding mockup:
/// uppercase tracked label on top, large headline-md text inside, mic + char counter footer.
struct FloatingLabelTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var onMic: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.stackSm) {
            Text(label)
                .appFont(.labelMd)
                .foregroundStyle(AppColor.secondary)

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .appFont(.headlineMd)
                        .foregroundStyle(AppColor.surfaceContainerHighest)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $text)
                    .appFont(.headlineMd)
                    .foregroundStyle(AppColor.onSurface)
                    .frame(minHeight: 120)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }

            Divider().background(AppColor.surfaceContainer)

            HStack {
                if let onMic {
                    Button(action: onMic) {
                        HStack(spacing: Spacing.stackSm) {
                            Image(systemName: "mic")
                            Text("Speak Description")
                                .appFont(.labelLg)
                        }
                        .foregroundStyle(AppColor.primary)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                Text("\(text.count) characters")
                    .appFont(.labelMd)
                    .foregroundStyle(AppColor.surfaceVariant)
            }
        }
        .padding(Spacing.stackMd)
        .background(AppColor.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.md)
                .stroke(AppColor.outlineVariant, lineWidth: 1)
        }
        .ambientShadow(blur: 30, y: 10, opacity: 0.03)
    }
}

#Preview {
    @Previewable @State var text = ""
    return FloatingLabelTextField(
        label: "Describe your style…",
        placeholder: "I love high-waisted tailored trousers in neutral linen…",
        text: $text,
        onMic: {}
    )
    .padding()
    .background(AppColor.surface)
}
