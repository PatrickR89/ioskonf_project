import SwiftUI

struct ScanReviewView: View {
    @EnvironmentObject private var closetRepository: ClosetRepository
    private let item = SampleData.scanCandidate
    private let suggestions = ["White Turtleneck", "Dark Wash Denim"]

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                StyleAITopBar(leading: .close)
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.stackLg) {
                        canvas
                        results
                    }
                    .padding(.horizontal, Spacing.containerMargin)
                    .padding(.top, Spacing.stackMd)
                    .padding(.bottom, 160)
                }
            }

            saveBar
        }
        .background(AppColor.background)
    }

    private var canvas: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                Rectangle()
                    .fill(AppColor.surfaceContainer)
                Image(systemName: "tshirt.fill")
                    .font(.system(size: 96, weight: .ultraLight))
                    .foregroundStyle(AppColor.outline)
            }
            .aspectRatio(3.0/4.0, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            .ambientShadow(blur: 30, y: 10, opacity: 0.04)

            AIPulseIndicator(label: "AI Analysis Active")
                .padding(Spacing.stackMd)
        }
    }

    private var results: some View {
        VStack(alignment: .leading, spacing: Spacing.stackMd) {
            HStack(alignment: .firstTextBaseline) {
                Text("AI Detected")
                    .appFont(.headlineMd)
                    .foregroundStyle(AppColor.onSurface)
                Spacer()
                Text("4 Attributes")
                    .appFont(.labelMd)
                    .foregroundStyle(AppColor.secondary)
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: Spacing.gutter),
                    GridItem(.flexible(), spacing: Spacing.gutter),
                ],
                spacing: Spacing.gutter
            ) {
                AttributeCard(label: "Type", values: [item.type.displayName])
                AttributeCard(label: "Season", values: item.seasons.map(\.displayName).sorted())
                AttributeCard(label: "Occasion", values: item.occasions.map(\.displayName).sorted())
                AttributeCard(
                    label: "Color",
                    values: [item.primaryColor.name],
                    swatch: Color(hex: hex(item.primaryColor.hex))
                )
            }

            Divider()
                .background(AppColor.outlineVariant)
                .padding(.top, Spacing.stackMd)

            HStack(alignment: .top, spacing: Spacing.stackSm) {
                Image(systemName: "wand.and.stars")
                    .foregroundStyle(AppColor.secondary)
                Text("Suggested matching items: \(suggestions.joined(separator: ", "))")
                    .appFont(.bodySm)
                    .italic()
                    .foregroundStyle(AppColor.secondary)
            }
        }
    }

    private var saveBar: some View {
        VStack {
            PrimaryButton(
                title: "Save to Closet",
                leadingSystemImage: "tray.and.arrow.down.fill"
            ) {
                closetRepository.addClosetItem(item)
            }
        }
        .padding(.horizontal, Spacing.containerMargin)
        .padding(.top, Spacing.stackLg)
        .padding(.bottom, Spacing.stackMd)
        .background(
            LinearGradient(
                colors: [AppColor.background.opacity(0), AppColor.background.opacity(0.95), AppColor.background],
                startPoint: .top, endPoint: .bottom
            )
        )
    }

    private func hex(_ string: String) -> UInt32 {
        var trimmed = string
        if trimmed.hasPrefix("#") { trimmed.removeFirst() }
        return UInt32(trimmed, radix: 16) ?? 0xE3D5C1
    }
}

#Preview {
    ScanReviewView()
        .environmentObject(ClosetRepository())
}
