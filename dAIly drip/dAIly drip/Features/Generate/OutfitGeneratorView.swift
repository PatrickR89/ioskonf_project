import SwiftUI

struct OutfitGeneratorView: View {
    @State private var prompt: String = ""
    @State private var selectedQuickPrompt: String? = "Chic Dinner Date"

    private let outfits = SampleData.outfits
    private let quickPrompts = SampleData.occasionPrompts

    var body: some View {
        VStack(spacing: 0) {
            StyleAITopBar()
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.stackXl) {
                    header
                    promptBar
                    suggestions
                }
                .padding(.horizontal, Spacing.containerMargin)
                .padding(.top, Spacing.stackLg)
                .padding(.bottom, Spacing.stackXl + Spacing.stackLg)
            }
        }
        .background(AppColor.background)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.stackSm) {
            Text("Outfit Generator")
                .appFont(.headlineLg)
                .foregroundStyle(AppColor.onSurface)
            Text("Curating your personal style with intelligence.")
                .appFont(.bodyMd)
                .foregroundStyle(AppColor.secondary)
        }
    }

    private var promptBar: some View {
        VStack(alignment: .leading, spacing: Spacing.stackSm) {
            HStack(spacing: Spacing.stackSm) {
                TextField("What's the occasion?", text: $prompt)
                    .appFont(.bodyMd)
                    .textFieldStyle(.plain)
                    .foregroundStyle(AppColor.onSurface)
                    .submitLabel(.go)
                    .onSubmit { generate() }
                Button {
                    // Voice input placeholder.
                } label: {
                    Label("Dictate", systemImage: "mic")
                        .labelStyle(.iconOnly)
                        .foregroundStyle(AppColor.primary)
                        .font(.system(size: 22, weight: .regular))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Dictate occasion")
            }
            .padding(.horizontal, Spacing.stackMd)
            .frame(height: 56)
            .background(AppColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: Radius.md))
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(AppColor.onSurface)
                    .frame(height: 1)
                    .padding(.horizontal, Spacing.stackMd)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.stackSm) {
                    ForEach(quickPrompts, id: \.self) { item in
                        SelectableChip(text: item, isSelected: selectedQuickPrompt == item) {
                            selectedQuickPrompt = item
                            prompt = item
                        }
                    }
                }
            }
        }
    }

    private var suggestions: some View {
        VStack(alignment: .leading, spacing: Spacing.stackMd) {
            HStack(alignment: .lastTextBaseline) {
                Text("AI Suggested Outfits")
                    .appFont(.headlineMd)
                    .foregroundStyle(AppColor.onSurface)
                Spacer()
                Button {
                    // future: open all generated outfits
                } label: {
                    Text("View All")
                        .appFont(.labelMd)
                        .foregroundStyle(AppColor.primary)
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: Spacing.stackLg) {
                ForEach(Array(outfits.enumerated()), id: \.element.id) { index, outfit in
                    BentoOutfitCard(
                        optionLabel: outfit.optionLabel,
                        title: outfit.title,
                        heroSymbol: heroSymbol(for: outfit),
                        detailSymbols: detailSymbols(for: outfit),
                        heroOnLeft: index.isMultiple(of: 2)
                    )
                }
            }
        }
    }

    private func generate() {
        // Placeholder — wired up later when the AI service exists.
    }

    private func heroSymbol(for outfit: Outfit) -> String {
        guard let item = SampleData.closet.first(where: { outfit.itemIds.contains($0.id) }) else {
            return "tshirt"
        }
        return item.placeholderSymbol
    }

    private func detailSymbols(for outfit: Outfit) -> [String] {
        let items = outfit.itemIds.compactMap { id in
            SampleData.closet.first(where: { $0.id == id })
        }
        return Array(items.dropFirst().prefix(2)).map { $0.placeholderSymbol }
    }
}

#Preview {
    OutfitGeneratorView()
}
