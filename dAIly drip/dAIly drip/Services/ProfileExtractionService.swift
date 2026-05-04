import FirebaseAILogic
import Foundation

struct ProfileExtractionService: Sendable {
    private static let backendName = "Gemini Developer API"
    private static let modelName = "gemini-2.5-flash"
    private static let backend = Backend.vertexAI()

    private struct ExtractedProfile: Decodable {
        var age: Int?
        var gender: String?
        var preferredStyles: [String]?
        var preferredColors: [String]?
        var vibe: String?
        var moodboard: ExtractedMoodboard?
    }

    private struct ExtractedMoodboard: Decodable {
        var title: String?
        var subtitle: String?
        var tiles: [ExtractedMoodboardTile]?
    }

    private struct ExtractedMoodboardTile: Decodable {
        var itemId: String
        var title: String?
        var note: String?
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

    func extractProfile(
        from description: String,
        currentProfile: UserProfile,
        closetItems: [ClosetItem]
    ) async throws -> UserProfile {
        let requestPrompt = Self.prompt(
            for: description,
            currentProfile: currentProfile,
            closetItems: closetItems
        )
        BackendLogger.info(
            "Starting profile extraction",
            metadata: [
                "backend": Self.backendName,
                "model": Self.modelName,
                "descriptionCharacters": description.count,
                "promptCharacters": requestPrompt.count,
                "hasExistingProfile": currentProfile.rawDescription.isEmpty == false,
                "closetItemCount": closetItems.count,
            ]
        )

        let model = FirebaseAI.firebaseAI(backend: Self.backend).generativeModel(
            modelName: Self.modelName,
            generationConfig: GenerationConfig(
                temperature: 0.2,
                maxOutputTokens: 5000,
                responseMIMEType: "application/json",
                responseSchema: Self.profileSchema
            ),
            systemInstruction: ModelContent(parts: Self.systemInstruction)
        )

        let response = try await {
            do {
                return try await model.generateContent(requestPrompt)
            } catch {
                BackendLogger.error(
                    "Firebase AI profile extraction request failed",
                    error: error,
                    metadata: [
                        "backend": Self.backendName,
                        "model": Self.modelName,
                        "descriptionPreview": BackendLogger.preview(description),
                        "promptCharacters": requestPrompt.count,
                    ]
                )
                throw error
            }
        }()

        guard let responseText = response.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !responseText.isEmpty else {
            BackendLogger.error(
                "Firebase AI profile extraction returned an empty response",
                metadata: [
                    "backend": Self.backendName,
                    "model": Self.modelName,
                    "descriptionCharacters": description.count,
                ]
            )
            throw ExtractionError.emptyResponse
        }

        BackendLogger.info(
            "Firebase AI profile extraction response received",
            metadata: [
                "backend": Self.backendName,
                "model": Self.modelName,
                "responseCharacters": responseText.count,
                "responsePreview": BackendLogger.preview(responseText),
            ]
        )

        let sanitizedResponseText = Self.sanitizedJSON(responseText)
        let extractedProfile: ExtractedProfile
        do {
            extractedProfile = try JSONDecoder().decode(
                ExtractedProfile.self,
                from: Data(sanitizedResponseText.utf8)
            )
        } catch {
            BackendLogger.error(
                "Failed to decode Firebase AI profile extraction response",
                error: error,
                metadata: [
                    "backend": Self.backendName,
                    "model": Self.modelName,
                    "sanitizedResponseCharacters": sanitizedResponseText.count,
                    "sanitizedResponsePreview": BackendLogger.preview(sanitizedResponseText),
                ]
            )
            throw error
        }

        var profile = currentProfile
        profile.rawDescription = description
        profile.age = Self.normalizedAge(extractedProfile.age)
        profile.gender = Self.normalizedGender(extractedProfile.gender)
        profile.preferredStyles = Self.normalizedList(extractedProfile.preferredStyles)
        profile.preferredColors = Self.normalizedList(extractedProfile.preferredColors)
        profile.vibe = Self.normalizedText(extractedProfile.vibe)
        profile.moodboard = Self.normalizedMoodboard(
            extractedProfile.moodboard,
            closetItems: closetItems,
            fallback: currentProfile.moodboard
        )

        BackendLogger.info(
            "Profile extraction completed",
            metadata: [
                "backend": Self.backendName,
                "model": Self.modelName,
                "age": profile.age,
                "gender": profile.gender?.rawValue,
                "styleCount": profile.preferredStyles.count,
                "colorCount": profile.preferredColors.count,
                "hasVibe": profile.vibe != nil,
                "moodboardTileCount": profile.moodboard.tiles.count,
            ]
        )

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
            "moodboard": .object(
                properties: [
                    "title": .string(
                        description: "Short editorial heading for the moodboard, two to five words.",
                        nullable: true
                    ),
                    "subtitle": .string(
                        description: "One concise sentence about the style direction anchored in the profile and closet.",
                        nullable: true
                    ),
                    "tiles": .array(
                        items: .object(
                            properties: [
                                "itemId": .string(description: "A closet item ID from the provided catalog."),
                                "title": .string(
                                    description: "Two to four word styling label for this tile.",
                                    nullable: true
                                ),
                                "note": .string(
                                    description: "One short sentence explaining why this closet item belongs in the moodboard.",
                                    nullable: true
                                ),
                            ],
                            propertyOrdering: ["itemId", "title", "note"]
                        ),
                        description: "Exactly three moodboard tiles using distinct closet item IDs."
                    ),
                ],
                propertyOrdering: ["title", "subtitle", "tiles"]
            ),
        ],
        propertyOrdering: [
            "age",
            "gender",
            "preferredStyles",
            "preferredColors",
            "vibe",
            "moodboard",
        ]
    )

    private static let systemInstruction = """
    You extract fashion user profile details from a natural-language style description.
    Return only details grounded in the description. Prefer concise, reusable wardrobe taxonomy.
    Extract age as an integer when the user states it, such as "I'm 28" or "28 years old".
    Do not invent age. Use gender preferNotToSay unless the text clearly identifies gender.
    For the moodboard, use only closet item IDs from the catalog and anchor the notes in the described aesthetic, colors, materials, and silhouettes.
    """

    private static func prompt(
        for description: String,
        currentProfile: UserProfile,
        closetItems: [ClosetItem]
    ) -> String {
        """
        Extract a complete user style profile from this description.
        Include age, gender, preferredStyles, preferredColors, vibe, and moodboard in the JSON response.

        Build the moodboard from the closet catalog. Select exactly three distinct items that best represent the described style direction.
        Favor items that align with the description's materials, palette, and silhouette language.

        Existing profile context:
        \(profileSummary(currentProfile))

        Closet catalog:
        \(closetSummary(closetItems))

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

    private static func normalizedMoodboard(
        _ moodboard: ExtractedMoodboard?,
        closetItems: [ClosetItem],
        fallback: MoodboardInspiration
    ) -> MoodboardInspiration {
        guard let moodboard else {
            return fallback
        }

        let itemById = Dictionary(uniqueKeysWithValues: closetItems.map { ($0.id, $0) })
        var seenItemIDs = Set<String>()

        let tiles = (moodboard.tiles ?? [])
            .compactMap { tile -> MoodboardTile? in
                let itemId = normalizedText(tile.itemId)
                guard let itemId,
                      itemById[itemId] != nil,
                      seenItemIDs.insert(itemId).inserted else {
                    return nil
                }

                let itemName = itemById[itemId]?.name ?? "Closet Item"
                return MoodboardTile(
                    id: "moodboard-\(itemId)",
                    itemId: itemId,
                    title: normalizedText(tile.title) ?? itemName,
                    note: normalizedText(tile.note) ?? "Supports the overall style direction."
                )
            }
            .prefix(3)

        guard !tiles.isEmpty else {
            return fallback
        }

        return MoodboardInspiration(
            title: normalizedText(moodboard.title),
            subtitle: normalizedText(moodboard.subtitle),
            tiles: Array(tiles)
        )
    }

    private static func profileSummary(_ profile: UserProfile) -> String {
        [
            profile.age.map { "age: \($0)" },
            profile.gender.map { "gender: \($0.rawValue)" },
            profile.preferredStyles.isEmpty ? nil : "styles: \(profile.preferredStyles.joined(separator: ", "))",
            profile.preferredColors.isEmpty ? nil : "colors: \(profile.preferredColors.joined(separator: ", "))",
            profile.vibe.map { "vibe: \($0)" },
        ]
        .compactMap { $0 }
        .joined(separator: "\n")
    }

    private static func closetSummary(_ closetItems: [ClosetItem]) -> String {
        closetItems.map { item in
            let seasons = item.seasons.map(\.displayName).sorted().joined(separator: ", ")
            let occasions = item.occasions.map(\.displayName).sorted().joined(separator: ", ")
            let materials = item.materials.joined(separator: ", ")
            return """
            - id: \(item.id)
              name: \(item.name)
              type: \(item.type.rawValue)
              color: \(item.primaryColor.name)
              materials: \(materials)
              seasons: \(seasons)
              occasions: \(occasions)
            """
        }
        .joined(separator: "\n")
    }
}
