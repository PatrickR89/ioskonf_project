import SwiftUI

struct OccasionsEditorView: View {
    @Bindable var viewModel: ScanReviewViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.stackSm) {
                    Text("Choose one or more occasions.")
                        .appFont(.bodySm)
                        .foregroundStyle(AppColor.secondary)
                        .padding(.bottom, Spacing.stackSm)

                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 110), spacing: Spacing.stackSm)],
                        alignment: .leading,
                        spacing: Spacing.stackSm
                    ) {
                        ForEach(Occasion.allCases, id: \.self) { occasion in
                            SelectableChip(
                                text: occasion.displayName,
                                isSelected: viewModel.draftOccasions.contains(occasion)
                            ) {
                                viewModel.toggleOccasion(occasion)
                            }
                        }
                    }
                }
                .padding(Spacing.containerMargin)
            }
            .background(AppColor.background)
            .navigationTitle("Occasion")
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
    OccasionsEditorView(viewModel: ScanReviewViewModel())
}
