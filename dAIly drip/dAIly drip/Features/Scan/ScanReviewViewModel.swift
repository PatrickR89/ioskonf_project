import PhotosUI
import SwiftUI

enum AttributeField: Identifiable, Hashable {
    case type, seasons, occasions, color
    var id: Self { self }
}

@MainActor
@Observable
final class ScanReviewViewModel {
    var selectedImage: UIImage?
    var photoPickerItem: PhotosPickerItem?
    var isSourceDialogPresented = false
    var isLibraryPresented = false
    var isCameraPresented = false
    var loadError: String?

    var draftType: ItemType = SampleData.scanCandidate.type
    var draftSeasons: Set<Season> = SampleData.scanCandidate.seasons
    var draftOccasions: Set<Occasion> = SampleData.scanCandidate.occasions
    var draftColor: ColorTag = SampleData.scanCandidate.primaryColor
    var editingField: AttributeField?

    private var loadTask: Task<Void, Never>?

    func presentSourceDialog() {
        isSourceDialogPresented = true
    }

    func chooseLibrary() {
        isLibraryPresented = true
    }

    func chooseCamera() {
        isCameraPresented = true
    }

    func beginEdit(_ field: AttributeField) {
        editingField = field
    }

    func endEdit() {
        editingField = nil
    }

    func setType(_ type: ItemType) {
        draftType = type
        endEdit()
    }

    func toggleSeason(_ season: Season) {
        if draftSeasons.contains(season) {
            draftSeasons.remove(season)
        } else {
            draftSeasons.insert(season)
        }
    }

    func toggleOccasion(_ occasion: Occasion) {
        if draftOccasions.contains(occasion) {
            draftOccasions.remove(occasion)
        } else {
            draftOccasions.insert(occasion)
        }
    }

    func setColor(_ color: ColorTag) {
        draftColor = color
        endEdit()
    }

    func handlePickerSelection(_ item: PhotosPickerItem?) {
        guard let item else { return }
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            await self?.load(from: item)
        }
    }

    func setCapturedImage(_ image: UIImage) {
        selectedImage = image
        loadError = nil
    }

    private func load(from item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                loadError = "Could not read the selected photo."
                return
            }
            try Task.checkCancellation()
            guard let image = UIImage(data: data) else {
                loadError = "Unsupported image format."
                return
            }
            selectedImage = image
            loadError = nil
        } catch is CancellationError {
            // Superseded by a newer selection — ignore.
        } catch {
            loadError = error.localizedDescription
        }
    }
}
