import Foundation

enum SeedDataProvider {
    static func load(from bundle: Bundle = .main) -> ClosetRepositorySnapshot {
        guard
            let url = bundle.url(forResource: "SeedData", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let snapshot = try? decoder.decode(ClosetRepositorySnapshot.self, from: data)
        else {
            return ClosetRepositorySnapshot(closetItems: [], userProfile: .empty)
        }

        return snapshot
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
