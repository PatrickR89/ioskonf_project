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

                    FlowLayout(spacing: Spacing.stackSm, lineSpacing: Spacing.stackSm) {
                        ForEach(Occasion.allCases, id: \.self) { occasion in
                            SelectableChip(
                                text: occasion.displayName,
                                isSelected: viewModel.draftOccasions.contains(occasion)
                            ) {
                                viewModel.toggleOccasion(occasion)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
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
