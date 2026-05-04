import SwiftUI

struct ColorEditorView: View {
    @Bindable var viewModel: ScanReviewViewModel
    @State private var customName: String = ""

    private var palette: [ColorTag] {
        var seen: Set<String> = []
        var unique: [ColorTag] = []
        for item in SampleData.closet {
            let key = item.primaryColor.hex.lowercased()
            if seen.insert(key).inserted {
                unique.append(item.primaryColor)
            }
        }
        if !unique.contains(where: { $0.hex.lowercased() == viewModel.draftColor.hex.lowercased() }) {
            unique.insert(viewModel.draftColor, at: 0)
        }
        return unique
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.stackMd) {
                    Text("Pick from existing colors or name a new one.")
                        .appFont(.bodySm)
                        .foregroundStyle(AppColor.secondary)

                    VStack(spacing: 0) {
                        ForEach(Array(palette.enumerated()), id: \.element.hex) { index, color in
                            colorRow(color)
                            if index < palette.count - 1 {
                                Divider().background(AppColor.outlineVariant.opacity(0.4))
                            }
                        }
                    }
                    .background(AppColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: Radius.md))

                    customSection
                        .padding(.top, Spacing.stackMd)
                }
                .padding(Spacing.containerMargin)
            }
            .background(AppColor.background)
            .navigationTitle("Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { viewModel.endEdit() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func colorRow(_ color: ColorTag) -> some View {
        Button {
            viewModel.setColor(color)
        } label: {
            HStack(spacing: Spacing.stackMd) {
                Circle()
                    .fill(Color(hex: hex(color.hex)))
                    .frame(width: 28, height: 28)
                    .overlay { Circle().stroke(AppColor.outlineVariant, lineWidth: 1) }
                Text(color.name)
                    .appFont(.bodyMd)
                    .foregroundStyle(AppColor.onSurface)
                Spacer()
                if color.hex.lowercased() == viewModel.draftColor.hex.lowercased()
                    && color.name == viewModel.draftColor.name {
                    Image(systemName: "checkmark")
                        .foregroundStyle(AppColor.primary)
                }
            }
            .padding(.horizontal, Spacing.stackMd)
            .padding(.vertical, Spacing.stackMd)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var customSection: some View {
        VStack(alignment: .leading, spacing: Spacing.stackSm) {
            Text("Custom name")
                .appFont(.labelMd)
                .foregroundStyle(AppColor.secondary)
            HStack(spacing: Spacing.stackSm) {
                TextField("e.g. Burnt Orange", text: $customName)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                    .onSubmit(saveCustom)
                Button("Use", action: saveCustom)
                    .buttonStyle(.borderedProminent)
                    .tint(AppColor.primary)
                    .disabled(customName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func saveCustom() {
        let trimmed = customName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        viewModel.setColor(ColorTag(name: trimmed, hex: viewModel.draftColor.hex))
        customName = ""
    }

    private func hex(_ string: String) -> UInt32 {
        var trimmed = string
        if trimmed.hasPrefix("#") { trimmed.removeFirst() }
        return UInt32(trimmed, radix: 16) ?? 0xE3D5C1
    }
}

#Preview {
    ColorEditorView(viewModel: ScanReviewViewModel())
}
