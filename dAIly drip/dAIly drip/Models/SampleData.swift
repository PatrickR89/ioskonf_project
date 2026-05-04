import Foundation

/// Lightweight fixtures for flows that are not backed by local persistence yet.
enum SampleData {
    static let userId = "sample-user"

    static let scanCandidate = ClosetItem(
        id: "scan-candidate",
        ownerId: userId,
        name: "Beige Trench",
        type: .outerwear,
        seasons: [.spring, .autumn],
        occasions: [.formal, .casual],
        primaryColor: ColorTag(name: "Beige", hex: "#E3D5C1"),
        materials: ["Cotton Gabardine"],
        imagePath: "closet_trench_coat",
        createdAt: .now
    )

    static let outfits: [Outfit] = [
        Outfit(
            id: "o1", prompt: "Chic Dinner Date",
            optionLabel: "Option 01", title: "Evening Elegance",
            itemIds: ["seed-slip-dress", "seed-loafers", "seed-trench"],
            rationale: "Champagne silk with structured accents.",
            createdAt: .now
        ),
        Outfit(
            id: "o2", prompt: "Chic Dinner Date",
            optionLabel: "Option 02", title: "Modern Noir",
            itemIds: ["seed-trench", "seed-denim", "seed-loafers"],
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
