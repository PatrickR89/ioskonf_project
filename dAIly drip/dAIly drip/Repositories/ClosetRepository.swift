import Combine
import Foundation

@MainActor
final class ClosetRepository: ObservableObject {
    @Published private(set) var closetItems: [ClosetItem]
    @Published private(set) var userProfile: UserProfile

    private let store: ClosetLocalStoring

    init(store: ClosetLocalStoring = UserDefaultsClosetStore()) {
        self.store = store

        if let snapshot = store.load() {
            closetItems = snapshot.closetItems
            userProfile = snapshot.userProfile
        } else {
            closetItems = SampleData.closet
            userProfile = SampleData.profile
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

    func resetToSeedData() {
        closetItems = SampleData.closet
        userProfile = SampleData.profile
        persist()
    }

    private func persist() {
        store.save(
            ClosetRepositorySnapshot(
                closetItems: closetItems,
                userProfile: userProfile
            )
        )
    }
}

struct ClosetRepositorySnapshot: Codable, Sendable {
    var closetItems: [ClosetItem]
    var userProfile: UserProfile
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
            return nil
        }
        return try? decoder.decode(ClosetRepositorySnapshot.self, from: data)
    }

    func save(_ snapshot: ClosetRepositorySnapshot) {
        guard let data = try? encoder.encode(snapshot) else {
            return
        }
        defaults.set(data, forKey: storageKey)
    }
}
