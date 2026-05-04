import SwiftUI

struct SeasonsEditorView: View {
    @Bindable var viewModel: ScanReviewViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.stackSm) {
                    Text("Choose one or more seasons.")
                        .appFont(.bodySm)
                        .foregroundStyle(AppColor.secondary)
                        .padding(.bottom, Spacing.stackSm)

                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 110), spacing: Spacing.stackSm)],
                        alignment: .leading,
                        spacing: Spacing.stackSm
                    ) {
                        ForEach(Season.allCases, id: \.self) { season in
                            SelectableChip(
                                text: season.displayName,
                                isSelected: viewModel.draftSeasons.contains(season)
                            ) {
                                viewModel.toggleSeason(season)
                            }
                        }
                    }
                }
                .padding(Spacing.containerMargin)
            }
            .background(AppColor.background)
            .navigationTitle("Season")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { viewModel.endEdit() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    SeasonsEditorView(viewModel: ScanReviewViewModel())
}
