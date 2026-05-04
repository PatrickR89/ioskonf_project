import FirebaseAILogic
import Foundation

struct OutfitGenerationService: Sendable {
    private static let backendName = "Gemini Developer API"
    private static let modelName = "gemini-2.5-flash-lite"

    private struct OutfitResponse: Decodable {
        var outfits: [GeneratedOutfit]
    }

    private struct GeneratedOutfit: Decodable {
        var title: String
        var itemIds: [String]
        var rationale: String
    }

    enum GenerationError: LocalizedError {
        case emptyCloset
        case emptyResponse
        case noCompleteOutfits

        var errorDescription: String? {
            switch self {
            case .emptyCloset:
                return "Add closet items before generating outfits."
            case .emptyResponse:
                return "The AI response did not include outfit suggestions."
            case .noCompleteOutfits:
                return "The closet does not have enough compatible items for a complete outfit."
            }
        }
    }

    func generateOutfits(
        prompt: String,
        userProfile: UserProfile,
        closetItems: [ClosetItem]
    ) async throws -> [Outfit] {
        guard !closetItems.isEmpty else {
            BackendLogger.warning(
                "Outfit generation skipped because closet is empty",
                metadata: [
                    "backend": Self.backendName,
                    "model": Self.modelName,
                    "promptPreview": BackendLogger.preview(prompt),
                ]
            )
            throw GenerationError.emptyCloset
        }

        let requestPrompt = Self.prompt(
            prompt: prompt,
            userProfile: userProfile,
            closetItems: closetItems
        )
        let itemCountsByType = Dictionary(grouping: closetItems, by: { $0.type.rawValue })
            .mapValues(\.count)
            .sorted { $0.key < $1.key }
            .map { "\($0.key):\($0.value)" }
            .joined(separator: ",")

        BackendLogger.info(
            "Starting outfit generation",
            metadata: [
                "backend": Self.backendName,
                "model": Self.modelName,
                "closetItemCount": closetItems.count,
                "closetItemCountsByType": itemCountsByType,
                "promptCharacters": prompt.count,
                "requestCharacters": requestPrompt.count,
                "profileHasAge": userProfile.age != nil,
                "profileStyleCount": userProfile.preferredStyles.count,
                "profileColorCount": userProfile.preferredColors.count,
                "promptPreview": BackendLogger.preview(prompt),
            ]
        )

        let model = FirebaseAI.firebaseAI(backend: .googleAI()).generativeModel(
            modelName: Self.modelName,
            generationConfig: GenerationConfig(
                temperature: 0.35,
                maxOutputTokens: 512,
                responseMIMEType: "application/json",
                responseSchema: Self.responseSchema
            ),
            systemInstruction: ModelContent(parts: Self.systemInstruction)
        )

        let response = try await {
            do {
                return try await model.generateContent(requestPrompt)
            } catch {
                BackendLogger.error(
                    "Firebase AI outfit generation request failed",
                    error: error,
                    metadata: [
                        "backend": Self.backendName,
                        "model": Self.modelName,
                        "closetItemCount": closetItems.count,
                        "requestCharacters": requestPrompt.count,
                        "promptPreview": BackendLogger.preview(prompt),
                    ]
                )
                throw error
            }
        }()

        guard let responseText = response.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !responseText.isEmpty else {
            BackendLogger.error(
                "Firebase AI outfit generation returned an empty response",
                metadata: [
                    "backend": Self.backendName,
                    "model": Self.modelName,
                    "closetItemCount": closetItems.count,
                    "requestCharacters": requestPrompt.count,
                ]
            )
            throw GenerationError.emptyResponse
        }

        BackendLogger.info(
            "Firebase AI outfit generation response received",
            metadata: [
                "backend": Self.backendName,
                "model": Self.modelName,
                "responseCharacters": responseText.count,
                "responsePreview": BackendLogger.preview(responseText),
            ]
        )

        let sanitizedResponseText = Self.sanitizedJSON(responseText)
        let decodedResponse: OutfitResponse
        do {
            decodedResponse = try JSONDecoder().decode(
                OutfitResponse.self,
                from: Data(sanitizedResponseText.utf8)
            )
        } catch {
            BackendLogger.error(
                "Failed to decode Firebase AI outfit generation response",
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

        let validatedOutfits = decodedResponse.outfits
            .prefix(3)
            .compactMap { generatedOutfit in
                Self.validatedOutfit(
                    generatedOutfit,
                    prompt: prompt,
                    closetItems: closetItems
                )
            }

        guard !validatedOutfits.isEmpty else {
            BackendLogger.error(
                "No complete outfits remained after local validation",
                metadata: [
                    "backend": Self.backendName,
                    "model": Self.modelName,
                    "rawOutfitCount": decodedResponse.outfits.count,
                    "closetItemCount": closetItems.count,
                    "closetItemCountsByType": itemCountsByType,
                    "rawItemIds": decodedResponse.outfits.map { $0.itemIds.joined(separator: ",") }.joined(separator: " | "),
                ]
            )
            throw GenerationError.noCompleteOutfits
        }

        let outfits = validatedOutfits.enumerated().map { index, outfit in
            Outfit(
                id: "generated-\(UUID().uuidString)",
                prompt: prompt,
                optionLabel: String(format: "Option %02d", index + 1),
                title: outfit.title,
                itemIds: outfit.itemIds,
                rationale: outfit.rationale,
                createdAt: .now
            )
        }

        BackendLogger.info(
            "Outfit generation completed",
            metadata: [
                "backend": Self.backendName,
                "model": Self.modelName,
                "rawOutfitCount": decodedResponse.outfits.count,
                "validatedOutfitCount": outfits.count,
                "selectedItemIds": outfits.map { $0.itemIds.joined(separator: ",") }.joined(separator: " | "),
            ]
        )

        return outfits
    }

    private static let responseSchema = Schema.object(
        properties: [
            "outfits": .array(
                items: .object(
                    properties: [
                        "title": .string(description: "Short editorial outfit title."),
                        "itemIds": .array(
                            items: .string(),
                            description: "Only IDs from the provided closet catalog."
                        ),
                        "rationale": .string(description: "One concise sentence explaining the outfit choice."),
                    ],
                    propertyOrdering: ["title", "itemIds", "rationale"]
                ),
                description: "Two or three complete outfits."
            ),
        ]
    )

    private static let systemInstruction = """
    You are a wardrobe stylist. Generate complete, wearable outfits using only closet item IDs provided by the app.
    A complete outfit must include either:
    - one dress and shoes, or
    - one top, one bottom, and shoes.
    Outerwear and accessories are optional add-ons. Do not create outfits missing bottoms when no dress is selected.
    Never invent item IDs. Prefer items matching the occasion, user profile, colors, materials, and vibe.
    """

    private static func prompt(
        prompt: String,
        userProfile: UserProfile,
        closetItems: [ClosetItem]
    ) -> String {
        """
        Occasion or request:
        \(prompt)

        User profile:
        \(profileSummary(userProfile))

        Closet catalog:
        \(closetSummary(closetItems))

        Return two or three complete outfits. Use each outfit's itemIds in styling priority order: main garment, supporting garment, shoes, then optional outerwear/accessories.
        """
    }

    private static func profileSummary(_ profile: UserProfile) -> String {
        [
            profile.age.map { "age: \($0)" },
            profile.gender.map { "gender: \($0.rawValue)" },
            profile.preferredStyles.isEmpty ? nil : "styles: \(profile.preferredStyles.joined(separator: ", "))",
            profile.preferredColors.isEmpty ? nil : "colors: \(profile.preferredColors.joined(separator: ", "))",
            profile.vibe.map { "vibe: \($0)" },
            profile.rawDescription.isEmpty ? nil : "description: \(profile.rawDescription)",
        ]
            .compactMap(\.self)
            .joined(separator: "\n")
    }

    private static func closetSummary(_ items: [ClosetItem]) -> String {
        items.map { item in
            """
            - id: \(item.id); name: \(item.name); type: \(item.type.rawValue); seasons: \(displayValues(item.seasons)); occasions: \(displayValues(item.occasions)); color: \(item.primaryColor.name); materials: \(item.materials.joined(separator: ", "))
            """
        }
        .joined(separator: "\n")
    }

    private static func displayValues<T: RawRepresentable>(_ values: Set<T>) -> String where T.RawValue == String {
        values
            .map(\.rawValue)
            .sorted()
            .joined(separator: ", ")
    }

    private static func sanitizedJSON(_ text: String) -> String {
        text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func validatedOutfit(
        _ generatedOutfit: GeneratedOutfit,
        prompt: String,
        closetItems: [ClosetItem]
    ) -> GeneratedOutfit? {
        let itemById = Dictionary(uniqueKeysWithValues: closetItems.map { ($0.id, $0) })
        var selectedItems = uniqueItems(
            generatedOutfit.itemIds.compactMap { itemById[$0] }
        )

        selectedItems = repairedItems(
            selectedItems,
            prompt: prompt,
            closetItems: closetItems
        )

        guard isComplete(selectedItems, closetItems: closetItems) else {
            return nil
        }

        return GeneratedOutfit(
            title: generatedOutfit.title.trimmingCharacters(in: .whitespacesAndNewlines),
            itemIds: selectedItems.map(\.id),
            rationale: generatedOutfit.rationale.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    private static func uniqueItems(_ items: [ClosetItem]) -> [ClosetItem] {
        var seenIds = Set<ClosetItem.ID>()
        return items.filter { item in
            if seenIds.contains(item.id) {
                return false
            }
            seenIds.insert(item.id)
            return true
        }
    }

    private static func repairedItems(
        _ items: [ClosetItem],
        prompt: String,
        closetItems: [ClosetItem]
    ) -> [ClosetItem] {
        var repairedItems = items

        if repairedItems.contains(where: { $0.type == .dress }) {
            repairedItems.removeAll { $0.type == .tops || $0.type == .bottoms }
            appendBestItem(type: .shoes, to: &repairedItems, prompt: prompt, closetItems: closetItems)
            return uniqueItems(Array(orderedItems(repairedItems).prefix(4)))
        }

        appendBestItem(type: .tops, to: &repairedItems, prompt: prompt, closetItems: closetItems)
        appendBestItem(type: .bottoms, to: &repairedItems, prompt: prompt, closetItems: closetItems)
        appendBestItem(type: .shoes, to: &repairedItems, prompt: prompt, closetItems: closetItems)

        return uniqueItems(Array(orderedItems(repairedItems).prefix(5)))
    }

    private static func appendBestItem(
        type: ItemType,
        to items: inout [ClosetItem],
        prompt: String,
        closetItems: [ClosetItem]
    ) {
        guard !items.contains(where: { $0.type == type }),
              let bestItem = closetItems
                  .filter({ $0.type == type })
                  .sorted(by: { score($0, prompt: prompt) > score($1, prompt: prompt) })
                  .first else {
            return
        }
        items.append(bestItem)
    }

    private static func isComplete(_ items: [ClosetItem], closetItems: [ClosetItem]) -> Bool {
        let selectedTypes = Set(items.map(\.type))
        let shoesRequired = closetItems.contains { $0.type == .shoes }
        let hasShoes = !shoesRequired || selectedTypes.contains(.shoes)

        if selectedTypes.contains(.dress) {
            return hasShoes
        }

        return selectedTypes.contains(.tops)
            && selectedTypes.contains(.bottoms)
            && hasShoes
    }

    private static func orderedItems(_ items: [ClosetItem]) -> [ClosetItem] {
        items.sorted { lhs, rhs in
            priority(lhs.type) < priority(rhs.type)
        }
    }

    private static func priority(_ type: ItemType) -> Int {
        switch type {
        case .dress:       return 0
        case .tops:        return 1
        case .bottoms:     return 2
        case .shoes:       return 3
        case .outerwear:   return 4
        case .accessories: return 5
        }
    }

    private static func score(_ item: ClosetItem, prompt: String) -> Int {
        let lowercasedPrompt = prompt.lowercased()
        var score = 0

        if item.occasions.contains(where: { lowercasedPrompt.contains($0.rawValue) }) {
            score += 4
        }

        if lowercasedPrompt.contains(item.primaryColor.name.lowercased()) {
            score += 2
        }

        score += item.materials.filter { lowercasedPrompt.contains($0.lowercased()) }.count
        return score
    }
}
