import SwiftUI

struct TypeEditorView: View {
    @Bindable var viewModel: ScanReviewViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 110), spacing: Spacing.stackSm)],
                    alignment: .leading,
                    spacing: Spacing.stackSm
                ) {
                    ForEach(ItemType.allCases) { type in
                        SelectableChip(
                            text: type.displayName,
                            isSelected: viewModel.draftType == type
                        ) {
                            viewModel.setType(type)
                        }
                    }
                }
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
