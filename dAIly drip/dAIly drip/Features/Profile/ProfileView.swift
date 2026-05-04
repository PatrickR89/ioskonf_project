import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var closetRepository: ClosetRepository
    @State private var description: String = ""
    @State private var isExtractingProfile = false
    @State private var extractionError: String?

    private let profileExtractionService = ProfileExtractionService()

    private struct ExtractedTrait: Identifiable {
        let id = UUID()
        let label: String
        let value: String
    }

    private struct MoodboardDisplayTile: Identifiable {
        let id: String
        let item: ClosetItem
        let title: String
        let note: String
    }

    var body: some View {
        VStack(spacing: 0) {
            DAIlyDripTopBar(trailingTinted: true)
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
                        title: isExtractingProfile ? "Building Profile" : "Build My Profile",
                        trailingSystemImage: isExtractingProfile ? nil : "arrow.right",
                        leadingSystemImage: isExtractingProfile ? "sparkles" : nil
                    ) {
                        buildProfile()
                    }
                    .disabled(isExtractingProfile || description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(isExtractingProfile ? 0.75 : 1)
                    moodboard
                }
                .padding(.horizontal, Spacing.containerMargin)
                .padding(.top, Spacing.stackLg)
                .padding(.bottom, Spacing.stackXl)
            }
        }
        .background(AppColor.background)
        .onAppear {
            description = closetRepository.userProfile.rawDescription
        }
        .onChange(of: closetRepository.userProfile.rawDescription) { _, newValue in
            description = newValue
        }
        .alert("Profile Extraction Failed", isPresented: extractionErrorBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(extractionError ?? "Try again with a little more detail.")
        }
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
            FlowLayout(spacing: Spacing.gutter) {
                if traits.isEmpty {
                    Text("Profile details will appear here after extraction.")
                        .appFont(.bodyMd)
                        .foregroundStyle(AppColor.secondary)
                } else {
                    ForEach(traits) { trait in
                        Chip(text: trait.value, leading: trait.label)
                    }
                }
            }

            if isExtractingProfile {
                HStack(spacing: Spacing.stackSm) {
                    ProgressView()
                    Text("Reading profile and curating moodboard")
                        .appFont(.labelMd)
                        .foregroundStyle(AppColor.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var extractionErrorBinding: Binding<Bool> {
        Binding {
            extractionError != nil
        } set: { isPresented in
            if !isPresented {
                extractionError = nil
            }
        }
    }

    private var traits: [ExtractedTrait] {
        let profile = closetRepository.userProfile
        var extractedTraits: [ExtractedTrait] = []

        if let age = profile.age {
            extractedTraits.append(.init(label: "Age:", value: String(age)))
        }

        if let gender = profile.gender {
            extractedTraits.append(.init(label: "Gender:", value: gender.displayName))
        }

        if !profile.preferredStyles.isEmpty {
            extractedTraits.append(.init(label: "Styles:", value: profile.preferredStyles.joined(separator: ", ")))
        }

        if !profile.preferredColors.isEmpty {
            extractedTraits.append(.init(label: "Colors:", value: profile.preferredColors.joined(separator: ", ")))
        }

        if let vibe = profile.vibe {
            extractedTraits.append(.init(label: "Vibe:", value: vibe))
        }

        return extractedTraits
    }

    private func buildProfile() {
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedDescription.isEmpty, !isExtractingProfile else {
            return
        }

        isExtractingProfile = true
        extractionError = nil

        Task {
            do {
                let profile = try await profileExtractionService.extractProfile(
                    from: trimmedDescription,
                    currentProfile: closetRepository.userProfile,
                    closetItems: closetRepository.closetItems
                )
                closetRepository.updateUserProfile(profile)
                description = profile.rawDescription
            } catch {
                BackendLogger.error(
                    "Profile extraction failed in UI flow; preserving raw description",
                    error: error,
                    metadata: [
                        "descriptionCharacters": trimmedDescription.count,
                        "descriptionPreview": BackendLogger.preview(trimmedDescription),
                    ]
                )
                var profile = closetRepository.userProfile
                profile.rawDescription = trimmedDescription
                closetRepository.updateUserProfile(profile)
                extractionError = error.localizedDescription
            }
            isExtractingProfile = false
        }
    }

    private var moodboard: some View {
        VStack(alignment: .leading, spacing: Spacing.stackLg) {
            VStack(alignment: .leading, spacing: Spacing.stackSm) {
                Text(closetRepository.userProfile.moodboard.title ?? "Moodboard Inspiration")
                    .appFont(.headlineLg)
                    .foregroundStyle(AppColor.onSurface)

                if let subtitle = closetRepository.userProfile.moodboard.subtitle {
                    Text(subtitle)
                        .appFont(.bodyMd)
                        .foregroundStyle(AppColor.secondary)
                }
            }

            if moodboardTiles.isEmpty {
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(AppColor.surfaceContainerLowest)
                    .overlay {
                        VStack(spacing: Spacing.stackSm) {
                            Image(systemName: "sparkles.tv")
                                .font(.system(size: 28, weight: .light))
                                .foregroundStyle(AppColor.outline)
                            Text("Build your profile to generate closet-based inspiration.")
                                .appFont(.bodyMd)
                                .foregroundStyle(AppColor.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(Spacing.stackLg)
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(3.0 / 2.15, contentMode: .fit)
            } else {
                HStack(spacing: Spacing.gutter) {
                    if let leadTile = moodboardTiles.first {
                        moodboardTile(leadTile, compact: false)
                            .aspectRatio(3.0 / 4.0, contentMode: .fit)
                    }

                    VStack(spacing: Spacing.gutter) {
                        ForEach(Array(moodboardTiles.dropFirst().prefix(2))) { tile in
                            moodboardTile(tile, compact: true)
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
        }
    }

    private var moodboardTiles: [MoodboardDisplayTile] {
        let itemsById = Dictionary(uniqueKeysWithValues: closetRepository.closetItems.map { ($0.id, $0) })
        return closetRepository.userProfile.moodboard.tiles.compactMap { tile in
            guard let item = itemsById[tile.itemId] else {
                return nil
            }

            return MoodboardDisplayTile(
                id: tile.id,
                item: item,
                title: tile.title,
                note: tile.note
            )
        }
    }

    private func moodboardTile(_ tile: MoodboardDisplayTile, compact: Bool) -> some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                if let imageName = tile.item.imagePath {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(AppColor.surfaceContainer)
                        .overlay {
                            Image(systemName: tile.item.placeholderSymbol)
                                .font(.system(size: compact ? 28 : 40, weight: .ultraLight))
                                .foregroundStyle(AppColor.outline)
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            LinearGradient(
                colors: [
                    .black.opacity(0.04),
                    .black.opacity(0.18),
                    .black.opacity(0.66),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(tile.title)
                    .appFont(compact ? .labelLg : .headlineMd)
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(tile.note)
                    .appFont(.bodySm)
                    .foregroundStyle(.white.opacity(0.92))
                    .lineLimit(compact ? 3 : 4)
            }
            .padding(compact ? Spacing.stackMd : Spacing.stackLg)
        }
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .ambientShadow(blur: 30, y: 10, opacity: 0.05)
    }
}

#Preview {
    ProfileView()
        .environmentObject(ClosetRepository())
}
