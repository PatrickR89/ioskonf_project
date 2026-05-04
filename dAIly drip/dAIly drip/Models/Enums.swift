import Foundation

enum Gender: String, Codable, CaseIterable, Sendable {
    case female, male, nonBinary, preferNotToSay
}

enum ItemType: String, Codable, CaseIterable, Identifiable, Sendable {
    case tops, bottoms, shoes, accessories, outerwear, dress

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tops:        return "Tops"
        case .bottoms:     return "Bottoms"
        case .shoes:       return "Shoes"
        case .accessories: return "Accessories"
        case .outerwear:   return "Outerwear"
        case .dress:       return "Dress"
        }
    }
}

enum Season: String, Codable, CaseIterable, Sendable {
    case spring, summer, autumn, winter

    var displayName: String { rawValue.capitalized }
}

enum Occasion: String, Codable, CaseIterable, Sendable {
    case casual, formal, business, sport, evening, beach

    var displayName: String { rawValue.capitalized }
}

struct ColorTag: Codable, Hashable, Sendable {
    var name: String
    var hex: String
}
