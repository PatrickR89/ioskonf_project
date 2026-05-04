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

    var isAnalyzingImage = false
    var analyzeError: String?

    private var loadTask: Task<Void, Never>?
    private var analyzeTask: Task<Void, Never>?
    private let categorizationService = ItemCategorizationService()

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

    /// Builds a `ClosetItem` from the current draft attributes. `ownerId` and
    /// `imagePath` are supplied by the caller because they live outside this
    /// view model's responsibility (auth + storage layers).
    func makeClosetItem(
        id: String = UUID().uuidString,
        ownerId: String,
        imagePath: String? = nil
    ) -> ClosetItem {
        let suggestedName = "\(draftColor.name) \(draftType.displayName)"
            .trimmingCharacters(in: .whitespaces)
        return ClosetItem(
            id: id,
            ownerId: ownerId,
            name: suggestedName,
            type: draftType,
            seasons: draftSeasons,
            occasions: draftOccasions,
            primaryColor: draftColor,
            materials: [],
            imagePath: imagePath,
            createdAt: .now
        )
    }

    /// Persists the current `selectedImage` (if any) to local disk and returns a
    /// fully-formed `ClosetItem` ready to hand to `ClosetRepository.addClosetItem`.
    /// Caller is responsible for the actual `addClosetItem` call so the repo
    /// stays out of the view model.
    func buildItemForSave(ownerId: String) -> ClosetItem {
        let id = UUID().uuidString
        var imagePath: String?

        if let image = selectedImage {
            let resized = image.downscaled(maxEdge: 1600)
            if let jpeg = resized.jpegData(compressionQuality: 0.85) {
                do {
                    imagePath = try LocalImageStore.write(jpeg: jpeg, for: id)
                } catch {
                    BackendLogger.error(
                        "Failed to write closet image to local disk",
                        error: error,
                        metadata: ["id": id, "jpegBytes": jpeg.count]
                    )
                }
            } else {
                BackendLogger.warning(
                    "Could not encode closet image as JPEG",
                    metadata: ["id": id]
                )
            }
        }

        return makeClosetItem(id: id, ownerId: ownerId, imagePath: imagePath)
    }

    /// Clears the form so the user can scan another item. Called after a
    /// successful save.
    func resetAfterSave() {
        analyzeTask?.cancel()
        loadTask?.cancel()
        selectedImage = nil
        photoPickerItem = nil
        loadError = nil
        analyzeError = nil
        isAnalyzingImage = false
        draftType = SampleData.scanCandidate.type
        draftSeasons = SampleData.scanCandidate.seasons
        draftOccasions = SampleData.scanCandidate.occasions
        draftColor = SampleData.scanCandidate.primaryColor
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
        analyze(image)
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
            analyze(image)
        } catch is CancellationError {
            // Superseded by a newer selection — ignore.
        } catch {
            loadError = error.localizedDescription
        }
    }

    private func analyze(_ image: UIImage) {
        analyzeTask?.cancel()
        analyzeError = nil

        let resized = image.downscaled(maxEdge: 1600)
        guard let jpeg = resized.jpegData(compressionQuality: 0.8) else {
            analyzeError = "Could not encode the photo for analysis."
            return
        }

        isAnalyzingImage = true
        let service = categorizationService

        analyzeTask = Task { [weak self] in
            defer { self?.isAnalyzingImage = false }
            do {
                let suggestion = try await service.categorize(imageJpeg: jpeg)
                try Task.checkCancellation()
                self?.applySuggestion(suggestion)
            } catch is CancellationError {
                // A newer image was picked; ignore.
            } catch {
                BackendLogger.error(
                    "Item categorization failed in scan flow",
                    error: error,
                    metadata: ["jpegBytes": jpeg.count]
                )
                self?.analyzeError = error.localizedDescription
            }
        }
    }

    private func applySuggestion(_ suggestion: ItemCategorizationService.Suggestion) {
        draftType = suggestion.type
        if !suggestion.seasons.isEmpty {
            draftSeasons = suggestion.seasons
        }
        if !suggestion.occasions.isEmpty {
            draftOccasions = suggestion.occasions
        }
        draftColor = suggestion.primaryColor
    }
}

private extension UIImage {
    func downscaled(maxEdge: CGFloat) -> UIImage {
        let longest = max(size.width, size.height)
        guard longest > maxEdge, longest > 0 else { return self }
        let scale = maxEdge / longest
        let target = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: target, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: target))
        }
    }
}
