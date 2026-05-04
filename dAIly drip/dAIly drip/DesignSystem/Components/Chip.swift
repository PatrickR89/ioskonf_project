import SwiftUI

struct Chip: View {
    let text: String
    var leading: String?
    var trailing: String?

    var body: some View {
        HStack(spacing: Spacing.stackSm / 2) {
            if let leading {
                Text(leading)
                    .appFont(.labelMd)
                    .foregroundStyle(AppColor.secondary)
            }
            Text(text)
                .appFont(.labelMd)
                .foregroundStyle(AppColor.onSurface)
            if let trailing {
                Text(trailing)
                    .appFont(.labelMd)
                    .foregroundStyle(AppColor.onSurface)
            }
        }
        .padding(.horizontal, Spacing.stackMd)
        .padding(.vertical, Spacing.stackSm)
        .background(AppColor.surfaceContainerLow, in: Capsule())
        .overlay {
            Capsule().stroke(AppColor.outlineVariant, lineWidth: 1)
        }
    }
}

/// Compact tag used inside item cards (smaller than `Chip`).
struct TagChip: View {
    let text: String

    var body: some View {
        Text(text)
            .appFont(.labelMd)
            .foregroundStyle(AppColor.onSurfaceVariant)
            .padding(.horizontal, Spacing.stackSm)
            .padding(.vertical, 2)
            .background(AppColor.surfaceContainer, in: Capsule())
            .overlay { Capsule().stroke(AppColor.outlineVariant, lineWidth: 1) }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.stackMd) {
        HStack {
            Chip(text: "Female", leading: "Gender:")
            Chip(text: "Minimalist", leading: "Style:")
        }
        HStack {
            TagChip(text: "Silk")
            TagChip(text: "White")
            TagChip(text: "Winter")
        }
    }
    .padding()
    .background(AppColor.surface)
}
