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
    @Test func repositorySeedsHardcodedDataWhenLocalStorageIsEmpty() {
        let store = InMemoryClosetStore()

        let repository = ClosetRepository(store: store)

        #expect(repository.closetItems == SampleData.closet)
        #expect(repository.userProfile.id == SampleData.profile.id)
        #expect(store.snapshot?.closetItems == SampleData.closet)
        #expect(store.snapshot?.userProfile.id == SampleData.profile.id)
    }

    @MainActor
    @Test func repositoryPersistsClosetAndProfileChanges() {
        let store = InMemoryClosetStore()
        let repository = ClosetRepository(store: store)
        var profile = repository.userProfile
        profile.rawDescription = "Updated local profile"

        repository.addClosetItem(SampleData.scanCandidate)
        repository.updateUserProfile(profile)

        #expect(repository.closetItems.first?.id == SampleData.scanCandidate.id)
        #expect(repository.userProfile.rawDescription == "Updated local profile")
        #expect(store.snapshot?.closetItems.first?.id == SampleData.scanCandidate.id)
        #expect(store.snapshot?.userProfile.rawDescription == "Updated local profile")
    }

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
