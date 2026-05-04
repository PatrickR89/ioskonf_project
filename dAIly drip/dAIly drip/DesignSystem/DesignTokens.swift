import SwiftUI

extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        let r = Double((hex >> 16) & 0xff) / 255.0
        let g = Double((hex >> 8) & 0xff) / 255.0
        let b = Double(hex & 0xff) / 255.0
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}

/// Color tokens — sourced verbatim from `stitch_design/DESIGN.md`.
/// Do not introduce additional named colors; if a new shade is required, update DESIGN.md first.
enum AppColor {
    static let primary             = Color(hex: 0x775a19)
    static let onPrimary           = Color(hex: 0xffffff)
    static let primaryContainer    = Color(hex: 0xc5a059)
    static let onPrimaryContainer  = Color(hex: 0x4e3700)
    static let inversePrimary      = Color(hex: 0xe9c176)
    static let primaryFixed        = Color(hex: 0xffdea5)
    static let primaryFixedDim     = Color(hex: 0xe9c176)
    static let onPrimaryFixed      = Color(hex: 0x261900)
    static let onPrimaryFixedVariant = Color(hex: 0x5d4201)

    static let secondary           = Color(hex: 0x5f5e5e)
    static let onSecondary         = Color(hex: 0xffffff)
    static let secondaryContainer  = Color(hex: 0xe2dfde)
    static let onSecondaryContainer = Color(hex: 0x636262)
    static let secondaryFixed      = Color(hex: 0xe5e2e1)
    static let secondaryFixedDim   = Color(hex: 0xc8c6c5)
    static let onSecondaryFixed    = Color(hex: 0x1c1b1b)
    static let onSecondaryFixedVariant = Color(hex: 0x474746)

    static let tertiary            = Color(hex: 0x5e5e5b)
    static let onTertiary          = Color(hex: 0xffffff)
    static let tertiaryContainer   = Color(hex: 0xa6a5a1)
    static let onTertiaryContainer = Color(hex: 0x3b3b38)
    static let tertiaryFixed       = Color(hex: 0xe4e2dd)
    static let tertiaryFixedDim    = Color(hex: 0xc8c6c2)
    static let onTertiaryFixed     = Color(hex: 0x1b1c19)
    static let onTertiaryFixedVariant = Color(hex: 0x474744)

    static let surface             = Color(hex: 0xfbf9f9)
    static let surfaceDim          = Color(hex: 0xdbdad9)
    static let surfaceBright       = Color(hex: 0xfbf9f9)
    static let surfaceContainerLowest = Color(hex: 0xffffff)
    static let surfaceContainerLow = Color(hex: 0xf5f3f3)
    static let surfaceContainer    = Color(hex: 0xefeded)
    static let surfaceContainerHigh = Color(hex: 0xe9e8e7)
    static let surfaceContainerHighest = Color(hex: 0xe4e2e2)
    static let surfaceVariant      = Color(hex: 0xe4e2e2)
    static let surfaceTint         = Color(hex: 0x775a19)

    static let background          = Color(hex: 0xfbf9f9)
    static let onBackground        = Color(hex: 0x1b1c1c)
    static let onSurface           = Color(hex: 0x1b1c1c)
    static let onSurfaceVariant    = Color(hex: 0x4e4639)

    static let inverseSurface      = Color(hex: 0x303031)
    static let inverseOnSurface    = Color(hex: 0xf2f0f0)

    static let outline             = Color(hex: 0x7f7667)
    static let outlineVariant      = Color(hex: 0xd1c5b4)

    static let error               = Color(hex: 0xba1a1a)
    static let onError             = Color(hex: 0xffffff)
    static let errorContainer      = Color(hex: 0xffdad6)
    static let onErrorContainer    = Color(hex: 0x93000a)
}

enum Spacing {
    static let unit: CGFloat = 4
    static let stackSm: CGFloat = 8
    static let stackMd: CGFloat = 16
    static let gutter: CGFloat = 16
    static let containerMargin: CGFloat = 24
    static let stackLg: CGFloat = 32
    static let stackXl: CGFloat = 64
}

enum Radius {
    static let sm: CGFloat = 4
    static let standard: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
}

struct AmbientShadow: ViewModifier {
    var blur: CGFloat = 24
    var y: CGFloat = 10
    var opacity: Double = 0.05

    func body(content: Content) -> some View {
        content.shadow(
            color: AppColor.onSurface.opacity(opacity),
            radius: blur / 2,
            x: 0,
            y: y
        )
    }
}

extension View {
    func ambientShadow(blur: CGFloat = 24, y: CGFloat = 10, opacity: Double = 0.05) -> some View {
        modifier(AmbientShadow(blur: blur, y: y, opacity: opacity))
    }
}
