import SwiftUI

/// One generated outfit. Image layout is the editorial bento grid from the mockup:
/// a 3:4 hero on one side, two 1:1 squares stacked on the other.
struct BentoOutfitCard: View {
    let optionLabel: String
    let title: String
    let heroSymbol: String
    let detailSymbols: [String]
    var heroOnLeft: Bool = true
    var onWearThis: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: Spacing.stackMd) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(optionLabel)
                            .appFont(.labelMd)
                            .foregroundStyle(AppColor.primary)
                        Text(title)
                            .font(.system(size: 20, weight: .medium, design: .serif).italic())
                            .foregroundStyle(AppColor.onSurface)
                    }
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(AppColor.primary)
                }

                bentoGrid
            }
            .padding(Spacing.stackLg / 2 * 1.5) // 24

            Button(action: onWearThis) {
                Text("Wear This")
                    .appFont(.labelLg)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundStyle(AppColor.onPrimary)
                    .background(AppColor.primary)
            }
            .buttonStyle(.pressable)
        }
        .background(AppColor.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .ambientShadow(blur: 36, y: -10, opacity: 0.04)
    }

    private var bentoGrid: some View {
        HStack(spacing: 12) {
            if heroOnLeft {
                hero
                detailColumn
            } else {
                detailColumn
                hero
            }
        }
    }

    private var hero: some View {
        placeholder(heroSymbol)
            .aspectRatio(3.0/4.0, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: Radius.standard))
    }

    private var detailColumn: some View {
        VStack(spacing: 12) {
            ForEach(Array(detailSymbols.prefix(2).enumerated()), id: \.offset) { _, symbol in
                placeholder(symbol)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.standard))
            }
        }
    }

    private func placeholder(_ symbol: String) -> some View {
        ZStack {
            AppColor.surfaceContainer
            Image(systemName: symbol)
                .font(.system(size: 36, weight: .ultraLight))
                .foregroundStyle(AppColor.outline)
        }
    }
}

#Preview {
    BentoOutfitCard(
        optionLabel: "Option 01",
        title: "Evening Elegance",
        heroSymbol: "tshirt",
        detailSymbols: ["shoe", "handbag"]
    )
    .padding()
    .background(AppColor.surface)
}
