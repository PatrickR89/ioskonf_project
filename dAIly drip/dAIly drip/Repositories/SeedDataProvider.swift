import Foundation

enum SeedDataProvider {
    static func load(from bundle: Bundle = .main) -> ClosetRepositorySnapshot {
        guard let url = bundle.url(forResource: "SeedData", withExtension: "json") else {
            BackendLogger.error("Seed data file was not found in the app bundle")
            return ClosetRepositorySnapshot(closetItems: [], userProfile: .empty)
        }

        do {
            let data = try Data(contentsOf: url)
            let snapshot = try decoder.decode(ClosetRepositorySnapshot.self, from: data)
            BackendLogger.info(
                "Loaded seed data snapshot",
                metadata: [
                    "url": url.lastPathComponent,
                    "dataBytes": data.count,
                    "closetItemCount": snapshot.closetItems.count,
                ]
            )
            return snapshot
        } catch {
            BackendLogger.error(
                "Failed to load seed data snapshot",
                error: error,
                metadata: ["url": url.absoluteString]
            )
            return ClosetRepositorySnapshot(closetItems: [], userProfile: .empty)
        }
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
