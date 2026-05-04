import Foundation

struct ClosetItem: Codable, Identifiable, Sendable, Hashable {
    var id: String
    var ownerId: String
    var name: String
    var type: ItemType
    var seasons: Set<Season>
    var occasions: Set<Occasion>
    var primaryColor: ColorTag
    var materials: [String]
    var imagePath: String?
    var createdAt: Date

    /// SF Symbol name used as a placeholder thumbnail until real images exist.
    var placeholderSymbol: String {
        switch type {
        case .tops:        return "tshirt"
        case .bottoms:     return "rectangle.portrait"
        case .shoes:       return "shoe"
        case .accessories: return "bag"
        case .outerwear:   return "tshirt.fill"
        case .dress:       return "figure.dress.line.vertical.figure"
        }
    }
}
