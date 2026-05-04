import SwiftUI

/// One cell in the AI scan bento grid (Type / Season / Occasion / Color).
struct AttributeCard: View {
    let label: String
    let values: [String]
    /// Optional color swatch shown to the left of the value (used by the Color cell).
    var swatch: Color?
    var onEdit: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text(label)
                    .appFont(.labelMd)
                    .foregroundStyle(AppColor.secondary)
                Spacer()
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(AppColor.outline)
                }
                .buttonStyle(.plain)
            }

            ScrollView(.vertical) {
                HStack(alignment: .top, spacing: Spacing.stackSm + 4) {
                    if let swatch {
                        Circle()
                            .fill(swatch)
                            .frame(width: 24, height: 24)
                            .overlay { Circle().stroke(AppColor.outlineVariant, lineWidth: 1) }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(values, id: \.self) { value in
                            Text(value)
                                .appFont(.headlineMd)
                                .foregroundStyle(AppColor.onSurface)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)
            .defaultScrollAnchor(.bottom)
            .frame(maxHeight: .infinity)
        }
        .padding(Spacing.stackMd)
        .frame(height: 128, alignment: .topLeading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.md)
                .stroke(AppColor.outlineVariant.opacity(0.4), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible(), spacing: Spacing.gutter), GridItem(.flexible())]) {
        AttributeCard(label: "Type", values: ["Outerwear"])
        AttributeCard(label: "Season", values: ["Spring", "Autumn"])
        AttributeCard(label: "Occasion", values: ["Formal", "Casual"])
        AttributeCard(label: "Color", values: ["Beige"], swatch: Color(hex: 0xE3D5C1))
    }
    .padding()
    .background(AppColor.surface)
}
