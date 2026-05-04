import PhotosUI
import SwiftUI

@MainActor
@Observable
final class ScanReviewViewModel {
    var selectedImage: UIImage?
    var photoPickerItem: PhotosPickerItem?
    var isSourceDialogPresented = false
    var isLibraryPresented = false
    var isCameraPresented = false
    var loadError: String?

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
