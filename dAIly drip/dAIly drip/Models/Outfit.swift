import Foundation

struct Outfit: Codable, Identifiable, Sendable {
    var id: String
    var prompt: String
    var optionLabel: String
    var title: String
    var itemIds: [String]
    var rationale: String
    var createdAt: Date
}
