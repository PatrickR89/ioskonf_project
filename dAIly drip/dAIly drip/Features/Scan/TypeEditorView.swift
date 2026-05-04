import SwiftUI

struct TypeEditorView: View {
    @Bindable var viewModel: ScanReviewViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                FlowLayout(spacing: Spacing.stackSm, lineSpacing: Spacing.stackSm) {
                    ForEach(ItemType.allCases) { type in
                        SelectableChip(
                            text: type.displayName,
                            isSelected: viewModel.draftType == type
                        ) {
                            viewModel.setType(type)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Spacing.containerMargin)
            }
            .background(AppColor.background)
            .navigationTitle("Type")
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
    TypeEditorView(viewModel: ScanReviewViewModel())
}
