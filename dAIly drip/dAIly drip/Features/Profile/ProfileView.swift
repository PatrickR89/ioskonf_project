import SwiftUI

struct ProfileView: View {
    @State private var description: String = ""

    private struct ExtractedTrait: Identifiable {
        let id = UUID()
        let label: String
        let value: String
    }

    private let traits: [ExtractedTrait] = [
        .init(label: "Gender:", value: "Female"),
        .init(label: "Style:", value: "Minimalist"),
        .init(label: "Colors:", value: "Earth Tones"),
        .init(label: "Vibe:", value: "Sophisticated"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            StyleAITopBar(trailingTinted: true)
            ScrollView {
                VStack(spacing: Spacing.stackXl) {
                    hero
                    FloatingLabelTextField(
                        label: "Describe your style…",
                        placeholder: "I love high-waisted tailored trousers in neutral linen, paired with silk camisoles and oversized cashmere sweaters for a sophisticated but relaxed Parisian feel…",
                        text: $description,
                        onMic: {}
                    )
                    extraction
                    PrimaryButton(
                        title: "Build My Profile",
                        trailingSystemImage: "arrow.right"
                    ) {}
                    moodboard
                }
                .padding(.horizontal, Spacing.containerMargin)
                .padding(.top, Spacing.stackLg)
                .padding(.bottom, Spacing.stackXl)
            }
        }
        .background(AppColor.background)
    }

    private var hero: some View {
        VStack(spacing: Spacing.stackSm) {
            Text("The Journey Begins")
                .appFont(.labelMd)
                .foregroundStyle(AppColor.primary)
                .padding(.horizontal, Spacing.stackMd)
                .padding(.vertical, 4)
                .background(AppColor.surfaceContainerLow, in: Capsule())
                .overlay { Capsule().stroke(AppColor.outlineVariant, lineWidth: 1) }

            Text("Curation starts with your voice.")
                .appFont(.displayMd)
                .foregroundStyle(AppColor.onSurface)
                .multilineTextAlignment(.center)
            Text("Tell us about your aesthetic preferences, favorite textures, and the way you want to feel in your clothes.")
                .appFont(.bodyMd)
                .foregroundStyle(AppColor.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
        }
        .frame(maxWidth: .infinity)
    }

    private var extraction: some View {
        VStack(alignment: .leading, spacing: Spacing.stackMd) {
            HStack(spacing: Spacing.stackSm) {
                Image(systemName: "sparkles")
                    .foregroundStyle(AppColor.primary)
                Text("AI Profile Extraction")
                    .appFont(.labelLg)
                    .foregroundStyle(AppColor.secondary)
            }
            FlowLayout(spacing: Spacing.gutter, lineSpacing: Spacing.gutter) {
                ForEach(traits) { trait in
                    Chip(text: trait.value, leading: trait.label)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var moodboard: some View {
        VStack(alignment: .center, spacing: Spacing.stackLg) {
            Text("Moodboard Inspiration")
                .appFont(.headlineLg)
                .foregroundStyle(AppColor.onSurface)

            HStack(spacing: Spacing.gutter) {
                moodboardTile(symbol: "person.fill")
                    .aspectRatio(3.0/4.0, contentMode: .fit)
                VStack(spacing: Spacing.gutter) {
                    moodboardTile(symbol: "circle.grid.2x2")
                        .aspectRatio(1, contentMode: .fit)
                    moodboardTile(symbol: "sparkles.tv")
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
    }

    private func moodboardTile(symbol: String) -> some View {
        ZStack {
            AppColor.surfaceContainer
            Image(systemName: symbol)
                .font(.system(size: 36, weight: .ultraLight))
                .foregroundStyle(AppColor.outline)
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }
}

#Preview {
    ProfileView()
}
