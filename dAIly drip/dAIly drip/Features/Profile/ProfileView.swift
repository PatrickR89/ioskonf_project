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
                    Text("Reading style description")
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
                    currentProfile: closetRepository.userProfile
                )
                closetRepository.updateUserProfile(profile)
                description = profile.rawDescription
            } catch {
                var profile = closetRepository.userProfile
                profile.rawDescription = trimmedDescription
                closetRepository.updateUserProfile(profile)
                extractionError = error.localizedDescription
            }
            isExtractingProfile = false
        }
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

/// Simple wrapping HStack — used for the chip cluster. iOS 16+ Layout protocol.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(ClosetRepository())
}
