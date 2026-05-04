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

                    FlowLayout(spacing: Spacing.stackSm, lineSpacing: Spacing.stackSm) {
                        ForEach(Season.allCases, id: \.self) { season in
                            SelectableChip(
                                text: season.displayName,
                                isSelected: viewModel.draftSeasons.contains(season)
                            ) {
                                viewModel.toggleSeason(season)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
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
