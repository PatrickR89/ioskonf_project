import Foundation

struct UserProfile: Codable, Identifiable, Sendable {
    var id: String
    var rawDescription: String
    var age: Int?
    var gender: Gender?
    var preferredStyles: [String]
    var preferredColors: [String]
    var vibe: String?
    var updatedAt: Date

    static let empty = UserProfile(
        id: "preview",
        rawDescription: "",
        age: nil,
        gender: nil,
        preferredStyles: [],
        preferredColors: [],
        vibe: nil,
        updatedAt: .now
    )
}
