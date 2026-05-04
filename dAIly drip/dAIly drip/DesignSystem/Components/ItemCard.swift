import SwiftUI

/// 3:4 product card used in the closet grid.
struct ItemCard: View {
    let name: String
    let tags: [String]
    /// SF Symbol used as the placeholder while there's no real image asset yet.
    let placeholderSymbol: String
    /// Tint behind the placeholder symbol. Pulled from the AppColor palette per call site.
    let placeholderTint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(AppColor.surfaceContainer)
                Image(systemName: placeholderSymbol)
                    .font(.system(size: 56, weight: .ultraLight))
                    .foregroundStyle(placeholderTint)
            }
            .aspectRatio(3.0/4.0, contentMode: .fill)
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
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible(), spacing: Spacing.gutter), GridItem(.flexible())]) {
        ItemCard(name: "Silk Overshirt", tags: ["Silk", "White"],
                 placeholderSymbol: "tshirt", placeholderTint: AppColor.outlineVariant)
        ItemCard(name: "Cashmere Knit", tags: ["Winter", "Navy"],
                 placeholderSymbol: "tshirt.fill", placeholderTint: AppColor.outline)
    }
    .padding()
    .background(AppColor.surface)
}
