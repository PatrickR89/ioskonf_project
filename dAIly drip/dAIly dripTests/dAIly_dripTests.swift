//
//  dAIly_dripTests.swift
//  dAIly dripTests
//
//  Created by Patrick Ružman on 04.05.2026..
//

import Testing
@testable import dAIly_drip

struct dAIly_dripTests {

    @MainActor
    @Test func repositorySeedsInitialDataWhenLocalStorageIsEmpty() {
        let store = InMemoryClosetStore()
        let seed = Self.seedSnapshot

        let repository = ClosetRepository(store: store, seedSnapshot: seed)

        #expect(repository.closetItems == seed.closetItems)
        #expect(repository.userProfile.id == seed.userProfile.id)
        #expect(store.snapshot?.closetItems == seed.closetItems)
        #expect(store.snapshot?.userProfile.id == seed.userProfile.id)
    }

    @MainActor
    @Test func repositoryPersistsClosetAndProfileChanges() {
        let store = InMemoryClosetStore()
        let repository = ClosetRepository(store: store, seedSnapshot: Self.seedSnapshot)
        var profile = repository.userProfile
        profile.rawDescription = "Updated local profile"
        let item = ClosetItem(
            id: "test-item",
            ownerId: profile.id,
            name: "Test Jacket",
            type: .outerwear,
            seasons: [.autumn],
            occasions: [.casual],
            primaryColor: ColorTag(name: "Black", hex: "#000000"),
            materials: ["Wool"],
            imagePath: "closet_trench_coat",
            createdAt: .now
        )

        repository.addClosetItem(item)
        repository.updateUserProfile(profile)

        #expect(repository.closetItems.first?.id == item.id)
        #expect(repository.userProfile.rawDescription == "Updated local profile")
        #expect(store.snapshot?.closetItems.first?.id == item.id)
        #expect(store.snapshot?.userProfile.rawDescription == "Updated local profile")
    }

    private static let seedSnapshot = ClosetRepositorySnapshot(
        closetItems: [
            ClosetItem(
                id: "seed-test-shirt",
                ownerId: "seed-test-user",
                name: "Seed Shirt",
                type: .tops,
                seasons: [.spring],
                occasions: [.casual],
                primaryColor: ColorTag(name: "White", hex: "#ffffff"),
                materials: ["Cotton"],
                imagePath: "closet_white_shirt",
                createdAt: .now
            )
        ],
        userProfile: UserProfile(
            id: "seed-test-user",
            rawDescription: "Seed profile",
            age: nil,
            gender: nil,
            preferredStyles: [],
            preferredColors: [],
            vibe: nil,
            updatedAt: .now
        )
    )

}

private final class InMemoryClosetStore: ClosetLocalStoring {
    var snapshot: ClosetRepositorySnapshot?

    func load() -> ClosetRepositorySnapshot? {
        snapshot
    }

    func save(_ snapshot: ClosetRepositorySnapshot) {
        self.snapshot = snapshot
    }
}
