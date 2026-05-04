import SwiftUI

struct StyleAITopBar: View {
    enum Leading { case menu, close, none }

    var leading: Leading = .menu
    var leadingAction: () -> Void = {}
    var trailingAction: () -> Void = {}
    var leadingTinted: Bool = false
    var trailingTinted: Bool = false

    var body: some View {
        HStack {
            leadingButton
                .frame(width: 32, height: 32, alignment: .leading)
            Spacer()
            StyleAIWordmark()
            Spacer()
            Button(action: trailingAction) {
                Label("Account", systemImage: "person.crop.circle")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(trailingTinted ? AppColor.primary : AppColor.outline)
            }
            .frame(width: 32, height: 32, alignment: .trailing)
        }
        .padding(.horizontal, Spacing.containerMargin)
        .frame(height: 56)
        .background(AppColor.surface)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppColor.outlineVariant.opacity(0.6))
                .frame(height: 1)
        }
    }

    @ViewBuilder
    private var leadingButton: some View {
        switch leading {
        case .menu:
            Button(action: leadingAction) {
                Label("Menu", systemImage: "line.3.horizontal")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(leadingTinted ? AppColor.primary : AppColor.outline)
            }
        case .close:
            Button(action: leadingAction) {
                Label("Close", systemImage: "xmark")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(AppColor.outline)
            }
        case .none:
            Color.clear
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        StyleAITopBar()
        StyleAITopBar(leading: .close)
        StyleAITopBar(leadingTinted: true, trailingTinted: true)
    }
    .background(AppColor.surface)
}
