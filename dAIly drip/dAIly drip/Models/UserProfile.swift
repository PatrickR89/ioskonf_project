import Foundation

struct UserProfile: Codable, Identifiable, Sendable {
    var id: String
    var rawDescription: String
    var age: Int?
    var gender: Gender?
    var preferredStyles: [String]
    var preferredColors: [String]
    var vibe: String?
    var moodboard: MoodboardInspiration
    var updatedAt: Date

    static let empty = UserProfile(
        id: "preview",
        rawDescription: "",
        age: nil,
        gender: nil,
        preferredStyles: [],
        preferredColors: [],
        vibe: nil,
        moodboard: .empty,
        updatedAt: .now
    )

    init(
        id: String,
        rawDescription: String,
        age: Int?,
        gender: Gender?,
        preferredStyles: [String],
        preferredColors: [String],
        vibe: String?,
        moodboard: MoodboardInspiration,
        updatedAt: Date
    ) {
        self.id = id
        self.rawDescription = rawDescription
        self.age = age
        self.gender = gender
        self.preferredStyles = preferredStyles
        self.preferredColors = preferredColors
        self.vibe = vibe
        self.moodboard = moodboard
        self.updatedAt = updatedAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case rawDescription
        case age
        case gender
        case preferredStyles
        case preferredColors
        case vibe
        case moodboard
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        rawDescription = try container.decode(String.self, forKey: .rawDescription)
        age = try container.decodeIfPresent(Int.self, forKey: .age)
        gender = try container.decodeIfPresent(Gender.self, forKey: .gender)
        preferredStyles = try container.decodeIfPresent([String].self, forKey: .preferredStyles) ?? []
        preferredColors = try container.decodeIfPresent([String].self, forKey: .preferredColors) ?? []
        vibe = try container.decodeIfPresent(String.self, forKey: .vibe)
        moodboard = try container.decodeIfPresent(MoodboardInspiration.self, forKey: .moodboard) ?? .empty
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}

struct MoodboardInspiration: Codable, Sendable {
    var title: String?
    var subtitle: String?
    var tiles: [MoodboardTile]

    static let empty = MoodboardInspiration(title: nil, subtitle: nil, tiles: [])
}

struct MoodboardTile: Codable, Identifiable, Sendable {
    var id: String
    var itemId: String
    var title: String
    var note: String
}
