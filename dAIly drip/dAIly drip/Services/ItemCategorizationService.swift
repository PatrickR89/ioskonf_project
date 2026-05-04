import FirebaseAILogic
import Foundation

struct ItemCategorizationService: Sendable {
    private static let backendName = "Gemini Developer API"
    private static let modelName = "gemini-2.5-flash"

    struct Suggestion: Sendable {
        var type: ItemType
        var seasons: Set<Season>
        var occasions: Set<Occasion>
        var primaryColor: ColorTag
    }

    private struct Payload: Decodable {
        var type: String
        var seasons: [String]?
        var occasions: [String]?
        var colorName: String
        var colorHex: String
    }

    enum CategorizationError: LocalizedError {
        case emptyResponse
        case unknownType(String)

        var errorDescription: String? {
            switch self {
            case .emptyResponse:
                return "The AI response did not include category details."
            case .unknownType(let raw):
                return "Unrecognized item type \"\(raw)\"."
            }
        }
    }

    func categorize(imageJpeg: Data) async throws -> Suggestion {
        BackendLogger.info(
            "Starting item categorization",
            metadata: [
                "backend": Self.backendName,
                "model": Self.modelName,
                "jpegBytes": imageJpeg.count,
            ]
        )

        let model = FirebaseAI.firebaseAI(backend: .googleAI()).generativeModel(
            modelName: Self.modelName,
            generationConfig: GenerationConfig(
                temperature: 0.2,
                maxOutputTokens: 2500,
                responseMIMEType: "application/json",
                responseSchema: Self.responseSchema
            ),
            systemInstruction: ModelContent(parts: Self.systemInstruction)
        )

        let imagePart = InlineDataPart(data: imageJpeg, mimeType: "image/jpeg")

        let response = try await {
            do {
                return try await model.generateContent(
                    Self.userPrompt,
                    imagePart
                )
            } catch {
                BackendLogger.error(
                    "Firebase AI item categorization request failed",
                    error: error,
                    metadata: [
                        "backend": Self.backendName,
                        "model": Self.modelName,
                        "jpegBytes": imageJpeg.count,
                    ]
                )
                throw error
            }
        }()

        guard let responseText = response.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !responseText.isEmpty else {
            BackendLogger.error(
                "Firebase AI item categorization returned an empty response",
                metadata: [
                    "backend": Self.backendName,
                    "model": Self.modelName,
                    "jpegBytes": imageJpeg.count,
                ]
            )
            throw CategorizationError.emptyResponse
        }

        BackendLogger.info(
            "Firebase AI item categorization response received",
            metadata: [
                "backend": Self.backendName,
                "model": Self.modelName,
                "responseCharacters": responseText.count,
                "responsePreview": BackendLogger.preview(responseText),
            ]
        )

        let sanitizedResponseText = Self.sanitizedJSON(responseText)
        let payload: Payload
        do {
            payload = try JSONDecoder().decode(
                Payload.self,
                from: Data(sanitizedResponseText.utf8)
            )
        } catch {
            BackendLogger.error(
                "Failed to decode Firebase AI item categorization response",
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

        let suggestion = try Self.suggestion(from: payload)

        BackendLogger.info(
            "Item categorization completed",
            metadata: [
                "backend": Self.backendName,
                "model": Self.modelName,
                "type": suggestion.type.rawValue,
                "seasonCount": suggestion.seasons.count,
                "occasionCount": suggestion.occasions.count,
                "color": suggestion.primaryColor.name,
            ]
        )

        return suggestion
    }

    private static let responseSchema = Schema.object(
        properties: [
            "type": .enumeration(
                values: ItemType.allCases.map(\.rawValue),
                description: "Exactly one item category."
            ),
            "seasons": .array(
                items: .enumeration(values: Season.allCases.map(\.rawValue)),
                description: "Seasons the garment suits — only those you are confident about."
            ),
            "occasions": .array(
                items: .enumeration(values: Occasion.allCases.map(\.rawValue)),
                description: "Occasions the garment suits — only those you are confident about."
            ),
            "colorName": .string(
                description: "Dominant color name in title case (e.g. Beige, Navy, Burnt Orange)."
            ),
            "colorHex": .string(
                description: "Six-digit hex string for the dominant color, prefixed with '#' (e.g. #1f2a44)."
            ),
        ],
        propertyOrdering: [
            "type",
            "seasons",
            "occasions",
            "colorName",
            "colorHex",
        ]
    )

    private static let systemInstruction = """
    You categorize a single clothing item from one photograph for a wardrobe app.
    Return only details grounded in the photo. Pick exactly one type from \
    {tops, bottoms, shoes, accessories, outerwear, dress}.
    Choose seasons and occasions conservatively — include only those you are confident apply.
    colorName is the dominant color in title case. colorHex is a six-digit hex starting with '#'.
    """

    private static let userPrompt = """
    Categorize this garment. Return JSON matching the response schema, with no extra prose.
    """

    private static func sanitizedJSON(_ text: String) -> String {
        text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func suggestion(from payload: Payload) throws -> Suggestion {
        guard let type = ItemType(rawValue: payload.type.lowercased()) else {
            throw CategorizationError.unknownType(payload.type)
        }
        let seasons = Set((payload.seasons ?? []).compactMap { Season(rawValue: $0.lowercased()) })
        let occasions = Set((payload.occasions ?? []).compactMap { Occasion(rawValue: $0.lowercased()) })

        var hex = payload.colorHex.trimmingCharacters(in: .whitespacesAndNewlines)
        if !hex.hasPrefix("#") { hex = "#" + hex }

        let trimmedName = payload.colorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = trimmedName.isEmpty ? "Color" : trimmedName

        return Suggestion(
            type: type,
            seasons: seasons,
            occasions: occasions,
            primaryColor: ColorTag(name: name, hex: hex)
        )
    }
}
