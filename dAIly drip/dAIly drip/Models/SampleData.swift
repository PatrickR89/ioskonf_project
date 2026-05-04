import Foundation

/// Fixtures used by views and previews while the persistence layer is stubbed.
/// All hex values come from the DESIGN.md palette or are neutral fabric tones used
/// only as decorative swatches inside cards (never as UI chrome).
enum SampleData {
    static let userId = "sample-user"

    static let profile = UserProfile(
        id: userId,
        rawDescription: "I love high-waisted tailored trousers in neutral linen, paired with silk camisoles and oversized cashmere sweaters for a sophisticated but relaxed Parisian feel.",
        age: 32,
        gender: .female,
        preferredStyles: ["Minimalist"],
        preferredColors: ["Earth Tones"],
        vibe: "Sophisticated",
        updatedAt: .now
    )

    static let closet: [ClosetItem] = [
        ClosetItem(
            id: "i1", ownerId: userId, name: "Silk Overshirt",
            type: .tops, seasons: [.spring, .autumn], occasions: [.casual, .evening],
            primaryColor: ColorTag(name: "White", hex: "#ffffff"),
            materials: ["Silk"], imagePath: nil, createdAt: .now
        ),
        ClosetItem(
            id: "i2", ownerId: userId, name: "Cashmere Knit",
            type: .tops, seasons: [.winter, .autumn], occasions: [.casual, .business],
            primaryColor: ColorTag(name: "Navy", hex: "#1f2a44"),
            materials: ["Cashmere"], imagePath: nil, createdAt: .now
        ),
        ClosetItem(
            id: "i3", ownerId: userId, name: "Tailored Coat",
            type: .outerwear, seasons: [.winter], occasions: [.formal, .business],
            primaryColor: ColorTag(name: "Black", hex: "#000000"),
            materials: ["Wool"], imagePath: nil, createdAt: .now
        ),
        ClosetItem(
            id: "i4", ownerId: userId, name: "Essential Tee",
            type: .tops, seasons: [.summer, .spring], occasions: [.casual],
            primaryColor: ColorTag(name: "Charcoal", hex: "#3a3a3a"),
            materials: ["Cotton"], imagePath: nil, createdAt: .now
        ),
        ClosetItem(
            id: "i5", ownerId: userId, name: "Linen Trousers",
            type: .bottoms, seasons: [.spring, .summer], occasions: [.casual, .business],
            primaryColor: ColorTag(name: "Beige", hex: "#E3D5C1"),
            materials: ["Linen"], imagePath: nil, createdAt: .now
        ),
        ClosetItem(
            id: "i6", ownerId: userId, name: "Wide-leg Denim",
            type: .bottoms, seasons: [.spring, .autumn, .winter], occasions: [.casual],
            primaryColor: ColorTag(name: "Indigo", hex: "#3b4d6b"),
            materials: ["Denim"], imagePath: nil, createdAt: .now
        ),
        ClosetItem(
            id: "i7", ownerId: userId, name: "Leather Loafers",
            type: .shoes, seasons: [.spring, .autumn], occasions: [.business, .casual],
            primaryColor: ColorTag(name: "Cognac", hex: "#7a4a2b"),
            materials: ["Leather"], imagePath: nil, createdAt: .now
        ),
        ClosetItem(
            id: "i8", ownerId: userId, name: "Pointed Boots",
            type: .shoes, seasons: [.autumn, .winter], occasions: [.evening, .formal],
            primaryColor: ColorTag(name: "Black", hex: "#000000"),
            materials: ["Leather"], imagePath: nil, createdAt: .now
        ),
        ClosetItem(
            id: "i9", ownerId: userId, name: "Gold Clutch",
            type: .accessories, seasons: [.spring, .summer, .autumn], occasions: [.evening, .formal],
            primaryColor: ColorTag(name: "Champagne", hex: "#c5a059"),
            materials: ["Metallic"], imagePath: nil, createdAt: .now
        ),
        ClosetItem(
            id: "i10", ownerId: userId, name: "Slip Dress",
            type: .dress, seasons: [.summer], occasions: [.evening, .formal],
            primaryColor: ColorTag(name: "Champagne", hex: "#c5a059"),
            materials: ["Silk"], imagePath: nil, createdAt: .now
        ),
    ]

    static let scanCandidate = ClosetItem(
        id: "scan-candidate",
        ownerId: userId,
        name: "Beige Trench",
        type: .outerwear,
        seasons: [.spring, .autumn],
        occasions: [.formal, .casual],
        primaryColor: ColorTag(name: "Beige", hex: "#E3D5C1"),
        materials: ["Cotton Gabardine"],
        imagePath: nil,
        createdAt: .now
    )

    static let outfits: [Outfit] = [
        Outfit(
            id: "o1", prompt: "Chic Dinner Date",
            optionLabel: "Option 01", title: "Evening Elegance",
            itemIds: ["i10", "i8", "i9"],
            rationale: "Champagne silk with structured accents.",
            createdAt: .now
        ),
        Outfit(
            id: "o2", prompt: "Chic Dinner Date",
            optionLabel: "Option 02", title: "Modern Noir",
            itemIds: ["i3", "i6", "i8"],
            rationale: "Tailored layers in deep tonal blacks.",
            createdAt: .now
        ),
    ]

    static let occasionPrompts = [
        "Chic Dinner Date",
        "Business Casual",
        "Weekend Brunch",
        "Wedding Guest",
        "Travel Day",
    ]
}
