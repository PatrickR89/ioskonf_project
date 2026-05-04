import SwiftUI

struct ColorEditorView: View {
    @Bindable var viewModel: ScanReviewViewModel
    @State private var customName: String = ""

    private static let curatedPalette: [ColorTag] = [
        // Neutrals
        ColorTag(name: "White",       hex: "#ffffff"),
        ColorTag(name: "Off-White",   hex: "#f4efe6"),
        ColorTag(name: "Cream",       hex: "#f5e9d4"),
        ColorTag(name: "Beige",       hex: "#e3d5c1"),
        ColorTag(name: "Sand",        hex: "#d8c39a"),
        ColorTag(name: "Taupe",       hex: "#a89684"),
        ColorTag(name: "Stone",       hex: "#8c8276"),
        ColorTag(name: "Light Gray",  hex: "#c9c7c4"),
        ColorTag(name: "Gray",        hex: "#8a8a8a"),
        ColorTag(name: "Charcoal",    hex: "#3a3a3a"),
        ColorTag(name: "Black",       hex: "#000000"),
        // Browns
        ColorTag(name: "Camel",       hex: "#b08858"),
        ColorTag(name: "Cognac",      hex: "#7a4a2b"),
        ColorTag(name: "Chocolate",   hex: "#4b2e1d"),
        ColorTag(name: "Espresso",    hex: "#2c1c12"),
        // Blues
        ColorTag(name: "Powder Blue", hex: "#a8c4d8"),
        ColorTag(name: "Sky Blue",    hex: "#6ea8c9"),
        ColorTag(name: "Denim",       hex: "#5a7a99"),
        ColorTag(name: "Cobalt",      hex: "#1f3a8a"),
        ColorTag(name: "Indigo",      hex: "#3b4d6b"),
        ColorTag(name: "Navy",        hex: "#1f2a44"),
        ColorTag(name: "Teal",        hex: "#2d6a6a"),
        // Greens
        ColorTag(name: "Mint",        hex: "#a9d6c1"),
        ColorTag(name: "Sage",        hex: "#9caf88"),
        ColorTag(name: "Olive",       hex: "#6b6a3a"),
        ColorTag(name: "Forest",      hex: "#2f4f33"),
        ColorTag(name: "Emerald",     hex: "#1f7a5a"),
        // Reds / oranges
        ColorTag(name: "Coral",       hex: "#e88b76"),
        ColorTag(name: "Terracotta",  hex: "#c66b3d"),
        ColorTag(name: "Rust",        hex: "#8b4a2b"),
        ColorTag(name: "Brick",       hex: "#7a3030"),
        ColorTag(name: "Crimson",     hex: "#a01a1a"),
        ColorTag(name: "Burgundy",    hex: "#5a1a2b"),
        ColorTag(name: "Wine",        hex: "#3d1019"),
        // Pinks
        ColorTag(name: "Blush",       hex: "#f0c8c0"),
        ColorTag(name: "Rose",        hex: "#c97b8a"),
        ColorTag(name: "Pink",        hex: "#e88aa8"),
        ColorTag(name: "Fuchsia",     hex: "#a83a7a"),
        // Yellows
        ColorTag(name: "Champagne",   hex: "#c5a059"),
        ColorTag(name: "Gold",        hex: "#b8862d"),
        ColorTag(name: "Mustard",     hex: "#a37a1a"),
        // Purples
        ColorTag(name: "Lavender",    hex: "#b9a8d1"),
        ColorTag(name: "Mauve",       hex: "#8a6a82"),
        ColorTag(name: "Plum",        hex: "#5a2e4a"),
    ]

    private var palette: [ColorTag] {
        var seen: Set<String> = []
        var ordered: [ColorTag] = []

        if !viewModel.draftColor.name.trimmingCharacters(in: .whitespaces).isEmpty {
            ordered.append(viewModel.draftColor)
            seen.insert(viewModel.draftColor.hex.lowercased())
        }

        for color in Self.curatedPalette where seen.insert(color.hex.lowercased()).inserted {
            ordered.append(color)
        }

        for item in SampleData.closet where seen.insert(item.primaryColor.hex.lowercased()).inserted {
            ordered.append(item.primaryColor)
        }

        return ordered
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
