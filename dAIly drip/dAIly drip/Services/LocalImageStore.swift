import Foundation
import UIKit

/// Reads and writes closet item images on local disk.
/// Files live under `Documents/ClosetImages/`. The relative path
/// (e.g. `ClosetImages/{id}.jpg`) is what gets persisted on `ClosetItem.imagePath`.
enum LocalImageStore {
    private static let directoryName = "ClosetImages"

    enum StoreError: LocalizedError {
        case noDocumentsDirectory

        var errorDescription: String? {
            switch self {
            case .noDocumentsDirectory:
                return "Could not locate the app's Documents directory."
            }
        }
    }

    /// Writes JPEG bytes for the given item id and returns the relative path
    /// suitable for persisting on `ClosetItem.imagePath`.
    static func write(jpeg data: Data, for id: String) throws -> String {
        let directory = try imagesDirectory()
        let url = directory.appendingPathComponent("\(id).jpg")
        try data.write(to: url, options: .atomic)
        return "\(directoryName)/\(id).jpg"
    }

    /// Loads a UIImage for a previously-stored relative path. Returns nil if
    /// the file is missing (e.g. the user wiped Documents) or unreadable.
    static func loadImage(forRelativePath path: String) -> UIImage? {
        guard let url = absoluteURL(forRelativePath: path) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    /// Resolves a relative path stored on `ClosetItem.imagePath` to a full file URL.
    static func absoluteURL(forRelativePath path: String) -> URL? {
        guard let documents = documentsDirectory() else { return nil }
        return documents.appendingPathComponent(path)
    }

    /// True if the given path looks like a relative on-disk reference (rather
    /// than an asset-catalog name). Used by `ItemCard` to decide how to load.
    static func isManagedPath(_ path: String) -> Bool {
        path.hasPrefix("\(directoryName)/")
    }

    private static func imagesDirectory() throws -> URL {
        guard let documents = documentsDirectory() else {
            throw StoreError.noDocumentsDirectory
        }
        let directory = documents.appendingPathComponent(directoryName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
        }
        return directory
    }

    private static func documentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
