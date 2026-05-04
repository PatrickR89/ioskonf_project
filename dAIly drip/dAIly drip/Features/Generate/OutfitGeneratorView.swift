import SwiftUI

struct OutfitGeneratorView: View {
    @EnvironmentObject private var closetRepository: ClosetRepository
    @State private var prompt: String = ""
    @State private var selectedQuickPrompt: String? = "Chic Dinner Date"
    @State private var isGenerating = false
    @State private var generationError: String?

    private let outfitGenerationService = OutfitGenerationService()
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
        .alert("Outfit Generation Failed", isPresented: generationErrorBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(generationError ?? "Try again with a different occasion.")
        }
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
                            generate()
                        }
                    }
                }
            }

            PrimaryButton(
                title: isGenerating ? "Generating Outfits" : "Generate Outfits",
                trailingSystemImage: isGenerating ? nil : "sparkles",
                leadingSystemImage: isGenerating ? "sparkles" : nil
            ) {
                generate()
            }
            .disabled(isGenerating || resolvedPrompt.isEmpty)
            .opacity(isGenerating ? 0.75 : 1)
        }
    }

    private var suggestions: some View {
        VStack(alignment: .leading, spacing: Spacing.stackMd) {
            HStack(alignment: .lastTextBaseline) {
                Text("AI Suggested Outfits")
                    .appFont(.headlineMd)
                    .foregroundStyle(AppColor.onSurface)
                Spacer()
                if isGenerating {
                    ProgressView()
                }
            }

            VStack(spacing: Spacing.stackLg) {
                ForEach(Array(closetRepository.generatedOutfits.enumerated()), id: \.element.id) { index, outfit in
                    BentoOutfitCard(
                        optionLabel: outfit.optionLabel,
                        title: outfit.title,
                        heroSymbol: heroSymbol(for: outfit),
                        detailSymbols: detailSymbols(for: outfit),
                        heroImageName: heroItem(for: outfit)?.imagePath,
                        detailImageNames: detailItems(for: outfit).compactMap(\.imagePath),
                        heroOnLeft: index.isMultiple(of: 2)
                    )
                }
            }
        }
    }

    private var generationErrorBinding: Binding<Bool> {
        Binding {
            generationError != nil
        } set: { isPresented in
            if !isPresented {
                generationError = nil
            }
        }
    }

    private var resolvedPrompt: String {
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedPrompt.isEmpty {
            return trimmedPrompt
        }
        return selectedQuickPrompt ?? ""
    }

    private func generate() {
        let request = resolvedPrompt
        guard !request.isEmpty, !isGenerating else {
            return
        }

        isGenerating = true
        generationError = nil
        closetRepository.clearGeneratedOutfits()

        Task {
            do {
                let outfits = try await outfitGenerationService.generateOutfits(
                    prompt: request,
                    userProfile: closetRepository.userProfile,
                    closetItems: closetRepository.closetItems
                )
                closetRepository.updateGeneratedOutfits(outfits)
            } catch {
                BackendLogger.error(
                    "Outfit generation failed in UI flow",
                    error: error,
                    metadata: [
                        "promptPreview": BackendLogger.preview(request),
                        "closetItemCount": closetRepository.closetItems.count,
                        "profileHasAge": closetRepository.userProfile.age != nil,
                        "profileStyleCount": closetRepository.userProfile.preferredStyles.count,
                    ]
                )
                generationError = error.localizedDescription
            }
            isGenerating = false
        }
    }

    private func heroSymbol(for outfit: Outfit) -> String {
        guard let item = heroItem(for: outfit) else {
            return "tshirt"
        }
        return item.placeholderSymbol
    }

    private func detailSymbols(for outfit: Outfit) -> [String] {
        detailItems(for: outfit).map { $0.placeholderSymbol }
    }

    private func heroItem(for outfit: Outfit) -> ClosetItem? {
        closetRepository.closetItems.first { outfit.itemIds.contains($0.id) }
    }

    private func detailItems(for outfit: Outfit) -> [ClosetItem] {
        let items = outfit.itemIds.compactMap { id in
            closetRepository.closetItems.first(where: { $0.id == id })
        }
        return Array(items.dropFirst().prefix(2))
    }
}

#Preview {
    OutfitGeneratorView()
        .environmentObject(ClosetRepository())
}
