import Combine
import Foundation

@MainActor
final class ClosetRepository: ObservableObject {
    @Published private(set) var closetItems: [ClosetItem]
    @Published private(set) var userProfile: UserProfile
    @Published private(set) var generatedOutfits: [Outfit]

    private let store: ClosetLocalStoring
    private let seedSnapshot: ClosetRepositorySnapshot

    init(
        store: ClosetLocalStoring = UserDefaultsClosetStore(),
        seedSnapshot: ClosetRepositorySnapshot = SeedDataProvider.load()
    ) {
        self.store = store
        self.seedSnapshot = seedSnapshot

        if let snapshot = store.load() {
            closetItems = snapshot.closetItems
            userProfile = snapshot.userProfile
            generatedOutfits = snapshot.generatedOutfits
            BackendLogger.info(
                "Loaded closet repository snapshot",
                metadata: [
                    "closetItemCount": snapshot.closetItems.count,
                    "generatedOutfitCount": snapshot.generatedOutfits.count,
                    "hasUserDescription": snapshot.userProfile.rawDescription.isEmpty == false,
                ]
            )
        } else {
            closetItems = seedSnapshot.closetItems
            userProfile = seedSnapshot.userProfile
            generatedOutfits = seedSnapshot.generatedOutfits
            BackendLogger.info(
                "Initialized closet repository from seed snapshot",
                metadata: [
                    "closetItemCount": seedSnapshot.closetItems.count,
                    "generatedOutfitCount": seedSnapshot.generatedOutfits.count,
                ]
            )
            persist()
        }
    }

    func addClosetItem(_ item: ClosetItem) {
        if let index = closetItems.firstIndex(where: { $0.id == item.id }) {
            closetItems[index] = item
            persist()
            return
        }

        closetItems.insert(item, at: 0)
        persist()
    }

    func updateClosetItem(_ item: ClosetItem) {
        guard let index = closetItems.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        closetItems[index] = item
        persist()
    }

    func deleteClosetItem(id: ClosetItem.ID) {
        closetItems.removeAll { $0.id == id }
        persist()
    }

    func updateUserProfile(_ profile: UserProfile) {
        var updatedProfile = profile
        updatedProfile.updatedAt = .now
        userProfile = updatedProfile
        persist()
    }

    func updateGeneratedOutfits(_ outfits: [Outfit]) {
        generatedOutfits = outfits
        BackendLogger.info(
            "Updating generated outfits",
            metadata: [
                "generatedOutfitCount": outfits.count,
                "itemIds": outfits.map { $0.itemIds.joined(separator: ",") }.joined(separator: " | "),
            ]
        )
        persist()
    }

    func clearGeneratedOutfits() {
        generatedOutfits = []
        BackendLogger.info("Cleared generated outfits")
        persist()
    }

    func resetToSeedData() {
        closetItems = seedSnapshot.closetItems
        userProfile = seedSnapshot.userProfile
        generatedOutfits = seedSnapshot.generatedOutfits
        persist()
    }

    private func persist() {
        store.save(
            ClosetRepositorySnapshot(
                closetItems: closetItems,
                userProfile: userProfile,
                generatedOutfits: generatedOutfits
            )
        )
    }
}

struct ClosetRepositorySnapshot: Codable, Sendable {
    var closetItems: [ClosetItem]
    var userProfile: UserProfile
    var generatedOutfits: [Outfit]

    init(
        closetItems: [ClosetItem],
        userProfile: UserProfile,
        generatedOutfits: [Outfit] = []
    ) {
        self.closetItems = closetItems
        self.userProfile = userProfile
        self.generatedOutfits = generatedOutfits
    }

    private enum CodingKeys: String, CodingKey {
        case closetItems
        case userProfile
        case generatedOutfits
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        closetItems = try container.decode([ClosetItem].self, forKey: .closetItems)
        userProfile = try container.decode(UserProfile.self, forKey: .userProfile)
        generatedOutfits = try container.decodeIfPresent([Outfit].self, forKey: .generatedOutfits) ?? []
    }
}

protocol ClosetLocalStoring {
    func load() -> ClosetRepositorySnapshot?
    func save(_ snapshot: ClosetRepositorySnapshot)
}

struct UserDefaultsClosetStore: ClosetLocalStoring {
    private let defaults: UserDefaults
    private let storageKey: String
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(
        defaults: UserDefaults = .standard,
        storageKey: String = "daily-drip.closet-repository.snapshot"
    ) {
        self.defaults = defaults
        self.storageKey = storageKey
    }

    func load() -> ClosetRepositorySnapshot? {
        guard let data = defaults.data(forKey: storageKey) else {
            BackendLogger.info(
                "No persisted closet repository snapshot found",
                metadata: ["storageKey": storageKey]
            )
            return nil
        }
        do {
            let snapshot = try decoder.decode(ClosetRepositorySnapshot.self, from: data)
            BackendLogger.info(
                "Decoded persisted closet repository snapshot",
                metadata: [
                    "storageKey": storageKey,
                    "dataBytes": data.count,
                    "closetItemCount": snapshot.closetItems.count,
                    "generatedOutfitCount": snapshot.generatedOutfits.count,
                ]
            )
            return snapshot
        } catch {
            BackendLogger.error(
                "Failed to decode persisted closet repository snapshot",
                error: error,
                metadata: [
                    "storageKey": storageKey,
                    "dataBytes": data.count,
                ]
            )
            return nil
        }
    }

    func save(_ snapshot: ClosetRepositorySnapshot) {
        let data: Data
        do {
            data = try encoder.encode(snapshot)
        } catch {
            BackendLogger.error(
                "Failed to encode closet repository snapshot",
                error: error,
                metadata: [
                    "storageKey": storageKey,
                    "closetItemCount": snapshot.closetItems.count,
                    "generatedOutfitCount": snapshot.generatedOutfits.count,
                ]
            )
            return
        }
        defaults.set(data, forKey: storageKey)
        BackendLogger.info(
            "Saved closet repository snapshot",
            metadata: [
                "storageKey": storageKey,
                "dataBytes": data.count,
                "closetItemCount": snapshot.closetItems.count,
                "generatedOutfitCount": snapshot.generatedOutfits.count,
            ]
        )
    }
}
