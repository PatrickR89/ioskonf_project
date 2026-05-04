import FirebaseAILogic
import Foundation

struct ProfileExtractionService: Sendable {
    private struct ExtractedProfile: Decodable {
        var age: Int?
        var gender: String?
        var preferredStyles: [String]?
        var preferredColors: [String]?
        var vibe: String?
    }

    enum ExtractionError: LocalizedError {
        case emptyResponse

        var errorDescription: String? {
            switch self {
            case .emptyResponse:
                return "The AI response did not include profile details."
            }
        }
    }

    func extractProfile(from description: String, currentProfile: UserProfile) async throws -> UserProfile {
        let model = FirebaseAI.firebaseAI(backend: .googleAI()).generativeModel(
            modelName: "gemini-2.5-flash-lite",
            generationConfig: GenerationConfig(
                temperature: 0.2,
                maxOutputTokens: 256,
                responseMIMEType: "application/json",
                responseSchema: Self.profileSchema
            ),
            systemInstruction: ModelContent(parts: Self.systemInstruction)
        )

        let response = try await model.generateContent(Self.prompt(for: description))
        guard let responseText = response.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !responseText.isEmpty else {
            throw ExtractionError.emptyResponse
        }

        let extractedProfile = try JSONDecoder().decode(
            ExtractedProfile.self,
            from: Data(Self.sanitizedJSON(responseText).utf8)
        )

        var profile = currentProfile
        profile.rawDescription = description
        profile.age = Self.normalizedAge(extractedProfile.age)
        profile.gender = Self.normalizedGender(extractedProfile.gender)
        profile.preferredStyles = Self.normalizedList(extractedProfile.preferredStyles)
        profile.preferredColors = Self.normalizedList(extractedProfile.preferredColors)
        profile.vibe = Self.normalizedText(extractedProfile.vibe)

        return profile
    }

    private static let profileSchema = Schema.object(
        properties: [
            "age": .integer(
                description: "The user's age as an integer if explicitly stated or strongly implied.",
                nullable: true
            ),
            "gender": .enumeration(
                values: Gender.allCases.map(\.rawValue),
                description: "Use preferNotToSay when gender is absent or unclear.",
                nullable: true
            ),
            "preferredStyles": .array(
                items: .string(),
                description: "Three to six concise style labels, title cased."
            ),
            "preferredColors": .array(
                items: .string(),
                description: "Three to six color names or palette labels, title cased."
            ),
            "vibe": .string(
                description: "A short two to four word phrase describing the user's overall outfit mood.",
                nullable: true
            ),
        ],
        propertyOrdering: [
            "age",
            "gender",
            "preferredStyles",
            "preferredColors",
            "vibe",
        ]
    )

    private static let systemInstruction = """
    You extract fashion user profile details from a natural-language style description.
    Return only details grounded in the description. Prefer concise, reusable wardrobe taxonomy.
    Extract age as an integer when the user states it, such as "I'm 28" or "28 years old".
    Do not invent age. Use gender preferNotToSay unless the text clearly identifies gender.
    """

    private static func prompt(for description: String) -> String {
        """
        Extract a complete user style profile from this description.
        Include age, gender, preferredStyles, preferredColors, and vibe in the JSON response.

        \(description)
        """
    }

    private static func sanitizedJSON(_ text: String) -> String {
        text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalizedAge(_ age: Int?) -> Int? {
        guard let age, (13...100).contains(age) else {
            return nil
        }
        return age
    }

    private static func normalizedGender(_ gender: String?) -> Gender? {
        guard let gender else {
            return nil
        }
        return Gender(rawValue: gender)
    }

    private static func normalizedList(_ values: [String]?) -> [String] {
        var seenValues = Set<String>()
        return (values ?? [])
            .compactMap(normalizedText)
            .filter { value in
                let key = value.lowercased()
                if seenValues.contains(key) {
                    return false
                }
                seenValues.insert(key)
                return true
            }
    }

    private static func normalizedText(_ value: String?) -> String? {
        guard let value else {
            return nil
        }
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}
