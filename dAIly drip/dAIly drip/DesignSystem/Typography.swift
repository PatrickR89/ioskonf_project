import SwiftUI

/// Typography token registry. Today every token resolves to a system font with the right
/// weight and design (serif vs default). When real Noto Serif + Manrope files are added to
/// the bundle, swap the `font` computed property to return `Font.custom(...)` keyed off the
/// PostScript names — every call site routes through here.
enum AppFont {
    case displayLg, displayMd
    case headlineLg, headlineMd
    case bodyLg, bodyMd, bodySm
    case labelLg, labelMd

    var size: CGFloat {
        switch self {
        case .displayLg:  return 40
        case .displayMd:  return 32
        case .headlineLg: return 24
        case .headlineMd: return 20
        case .bodyLg:     return 18
        case .bodyMd:     return 16
        case .bodySm:     return 14
        case .labelLg:    return 14
        case .labelMd:    return 12
        }
    }

    var lineHeight: CGFloat {
        switch self {
        case .displayLg:  return 48
        case .displayMd:  return 40
        case .headlineLg: return 32
        case .headlineMd: return 28
        case .bodyLg:     return 28
        case .bodyMd:     return 24
        case .bodySm:     return 20
        case .labelLg:    return 20
        case .labelMd:    return 16
        }
    }

    var tracking: CGFloat {
        switch self {
        case .displayLg: return -0.02 * size
        case .displayMd: return -0.01 * size
        case .labelLg, .labelMd: return 0.05 * size
        default: return 0
        }
    }

    var weight: Font.Weight {
        switch self {
        case .displayLg, .displayMd: return .semibold
        case .headlineLg, .headlineMd: return .medium
        case .bodyLg, .bodyMd, .bodySm: return .regular
        case .labelLg, .labelMd: return .semibold
        }
    }

    var isSerif: Bool {
        switch self {
        case .displayLg, .displayMd, .headlineLg, .headlineMd: return true
        default: return false
        }
    }

    var font: Font {
        Font.system(size: size, weight: weight, design: isSerif ? .serif : .default)
    }
}

extension View {
    func appFont(_ token: AppFont) -> some View {
        modifier(AppFontModifier(token: token))
    }
}

private struct AppFontModifier: ViewModifier {
    let token: AppFont

    func body(content: Content) -> some View {
        content
            .font(token.font)
            .tracking(token.tracking)
            .lineSpacing(max(0, token.lineHeight - token.size))
            .textCase((token == .labelLg || token == .labelMd) ? .uppercase : nil)
    }
}

/// "DAIly Drip" wordmark — Noto Serif italic in the mockups.
struct DAIlyDripWordmark: View {
    var body: some View {
        Text("dAIly drip")
            .font(.system(size: 24, weight: .medium, design: .serif).italic())
            .foregroundStyle(AppColor.onSurface)
            .accessibilityAddTraits(.isHeader)
    }
}
