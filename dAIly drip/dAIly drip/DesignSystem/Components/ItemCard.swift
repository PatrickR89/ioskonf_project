import SwiftUI

/// 3:4 product card used in the closet grid.
struct ItemCard: View {
    let name: String
    let tags: [String]
    let imageName: String?
    /// SF Symbol used as the placeholder while there's no real image asset yet.
    let placeholderSymbol: String
    /// Tint behind the placeholder symbol. Pulled from the AppColor palette per call site.
    let placeholderTint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(AppColor.surfaceContainer)
                imageContent
            }
            .aspectRatio(3.0/4.0, contentMode: .fit)
            .clipped()

            VStack(alignment: .leading, spacing: Spacing.stackSm) {
                Text(name)
                    .appFont(.labelLg)
                    .foregroundStyle(AppColor.onSurface)
                HStack(spacing: 4) {
                    ForEach(tags, id: \.self) { tag in
                        TagChip(text: tag)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppColor.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .ambientShadow(blur: 30, y: 10, opacity: 0.04)
    }

    @ViewBuilder
    private var imageContent: some View {
        if let imageName, !imageName.isEmpty {
            if LocalImageStore.isManagedPath(imageName),
               let uiImage = LocalImageStore.loadImage(forRelativePath: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } else {
            Image(systemName: placeholderSymbol)
                .font(.system(size: 56, weight: .ultraLight))
                .foregroundStyle(placeholderTint)
        }
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible(), spacing: Spacing.gutter), GridItem(.flexible())]) {
        ItemCard(name: "Silk Overshirt", tags: ["Silk", "White"], imageName: nil,
                 placeholderSymbol: "tshirt", placeholderTint: AppColor.outlineVariant)
        ItemCard(name: "Cashmere Knit", tags: ["Winter", "Navy"], imageName: nil,
                 placeholderSymbol: "tshirt.fill", placeholderTint: AppColor.outline)
    }
    .padding()
    .background(AppColor.surface)
}
