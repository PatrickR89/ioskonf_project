import SwiftUI

struct ClosetView: View {
    @EnvironmentObject private var closetRepository: ClosetRepository
    @State private var selectedFilter: ItemType? = nil

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.gutter),
        GridItem(.flexible(), spacing: Spacing.gutter),
    ]

    var body: some View {
        VStack(spacing: 0) {
            DAIlyDripTopBar(leadingTinted: true, trailingTinted: true)

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.stackLg) {
                    header
                    filterRow
                    grid
                }
                .padding(.horizontal, Spacing.containerMargin)
                .padding(.top, Spacing.stackLg)
                .padding(.bottom, Spacing.stackXl + Spacing.stackLg)
            }
        }
        .background(AppColor.background)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.stackSm) {
            Text("My Closet")
                .appFont(.displayMd)
                .foregroundStyle(AppColor.onSurface)
            Text("A curated collection of your essentials.")
                .appFont(.bodyMd)
                .foregroundStyle(AppColor.secondary)
        }
    }

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.stackLg / 2 * 1.5) {
                allFilterTab
                ForEach(ItemType.allCases) { type in
                    filterTab(type)
                }
            }
        }
    }

    private var allFilterTab: some View {
        let isSelected = selectedFilter == nil
        return Button {
            selectedFilter = nil
        } label: {
            VStack(spacing: 6) {
                Text("All")
                    .appFont(.labelLg)
                    .foregroundStyle(isSelected ? AppColor.primary : AppColor.secondary)
                Rectangle()
                    .fill(isSelected ? AppColor.primary : .clear)
                    .frame(height: 2)
            }
            .fixedSize()
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func filterTab(_ type: ItemType) -> some View {
        let isSelected = selectedFilter == type
        return Button {
            selectedFilter = type
        } label: {
            VStack(spacing: 6) {
                Text(type.displayName)
                    .appFont(.labelLg)
                    .foregroundStyle(isSelected ? AppColor.primary : AppColor.secondary)
                Rectangle()
                    .fill(isSelected ? AppColor.primary : .clear)
                    .frame(height: 2)
            }
            .fixedSize()
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var filtered: [ClosetItem] {
        guard let filter = selectedFilter else { return closetRepository.closetItems }
        return closetRepository.closetItems.filter { $0.type == filter }
    }

    @ViewBuilder
    private var grid: some View {
        if filtered.isEmpty {
            emptyState
        } else {
            LazyVGrid(columns: columns, spacing: Spacing.gutter) {
                ForEach(filtered) { item in
                    ItemCard(
                        name: item.name,
                        tags: tags(for: item),
                        imageName: item.imagePath,
                        placeholderSymbol: item.placeholderSymbol,
                        placeholderTint: AppColor.outline
                    )
                }
            }
        }
    }

    private func tags(for item: ClosetItem) -> [String] {
        var t: [String] = []
        if let material = item.materials.first { t.append(material) }
        t.append(item.primaryColor.name)
        return t
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.stackMd) {
            Image(systemName: "tshirt")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(AppColor.outlineVariant)
            Text("Nothing here yet")
                .appFont(.headlineMd)
                .foregroundStyle(AppColor.onSurface)
            Text("No \(selectedFilter?.displayName.lowercased() ?? "closet") items yet.")
                .appFont(.bodyMd)
                .foregroundStyle(AppColor.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.stackXl)
    }


}

#Preview {
    ClosetView()
        .environmentObject(ClosetRepository())
}
