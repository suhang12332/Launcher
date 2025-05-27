import Foundation
// Removed import CryptoKit
// import CryptoKit
import CommonCrypto
import UserNotifications // Import UserNotifications for notifications

// MARK: - Minecraft Types
struct MinecraftLibrary {
    let name: String
    let downloads: MinecraftLibraryDownloads?
    let natives: [String: String]?
    let url: URL?
    
    struct MinecraftLibraryDownloads {
        let artifact: MinecraftArtifact?
        let classifiers: [String: MinecraftArtifact]?
    }
    
    init(from library: Library) {
        self.name = library.name
        self.downloads = library.downloads.map { downloads in
            MinecraftLibraryDownloads(
                artifact: downloads.artifact.map { artifact in
                    MinecraftArtifact(
                        path: artifact.path,
                        url: artifact.url,
                        sha1: artifact.sha1
                    )
                },
                classifiers: downloads.classifiers?.mapValues { artifact in
                    MinecraftArtifact(
                        path: artifact.path,
                        url: artifact.url,
                        sha1: artifact.sha1
                    )
                }
            )
        }
        self.natives = library.natives
        self.url = library.url
    }
}

struct MinecraftArtifact {
    let path: String
    let url: URL
    let sha1: String
}

struct MinecraftAsset {
    let hash: String
    let size: Int
    let url: URL
}

struct MinecraftAssetIndex {
    let id: String
    let url: URL
    let sha1: String
    let totalSize: Int
    let objects: [String: MinecraftAsset]
}

// MARK: - Errors
enum MinecraftFileManagerError: Error {
    case cannotCreateDirectory(URL)
    case cannotWriteFile(URL, Error)
    case missingDownloadInfo
    case invalidFilePath(String)
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case noData
    case sha1Mismatch(expected: String, actual: String)
}

// MARK: - Constants
private enum Constants {
    static let metaSubdirectories = [
        "versions",
        "libraries",
        "assets",
        "assets/indexes",
        "assets/objects"
    ]
}

// MARK: - MinecraftFileManager
class MinecraftFileManager {
    // MARK: - Properties
    private let metaDirectory: URL
    private let profileDirectory: URL
    private let coreFilesCount = NSLockingCounter()
    private let resourceFilesCount = NSLockingCounter()
    private var coreTotalFiles = 0
    private var resourceTotalFiles = 0
    var onProgressUpdate: ((String, Int, Int, DownloadType) -> Void)?
    
    enum DownloadType {
        case core
        case resources
    }
    
    // MARK: - Initialization
    init(metaDirectory: URL, profileDirectory: URL) {
        self.metaDirectory = metaDirectory
        self.profileDirectory = profileDirectory
    }
    
    // MARK: - Public Methods
    func downloadVersionFiles(manifest: MinecraftVersionManifest) async throws {
        Logger.shared.info("Starting download for Minecraft version: \(manifest.id)")
        
        do {
            try createDirectories(manifestId: manifest.id)
            
            // Start both core files and assets download concurrently
            async let coreFilesDownload = downloadCoreFiles(manifest: manifest)
            async let assetsDownload = downloadAssets(manifest: manifest)
            
            // Wait for both to complete
            _ = try await [coreFilesDownload, assetsDownload]
            
            Logger.shared.info("Finished downloading files for Minecraft version: \(manifest.id)")
        } catch {
            Logger.shared.error("Error during file download for version \(manifest.id): \(error)")
            throw error
        }
    }
    
    func downloadAssets(manifest: MinecraftVersionManifest) async throws {
        Logger.shared.info("Starting asset downloads for Minecraft version: \(manifest.id)")
        
        // Download and parse asset index
        let assetIndex = try await downloadAssetIndex(manifest: manifest)
        
        // Update total files count for progress tracking
        resourceTotalFiles = assetIndex.objects.count
        
        // Download all assets with increased concurrency
        try await downloadAllAssets(assetIndex: assetIndex)
        
        Logger.shared.info("Finished downloading assets for Minecraft version: \(manifest.id)")
    }
    
    // MARK: - Private Methods
    private func calculateTotalFiles(_ manifest: MinecraftVersionManifest) -> Int {
        1 + // Client JAR
        manifest.libraries.count + // Libraries
        1 + // Asset index
        (manifest.logging.client.file != nil ? 1 : 0) // Logging config
    }
    
    private func createDirectories(manifestId: String) throws {
        let fileManager = FileManager.default
        
        // Create meta directories
        for subdirectory in Constants.metaSubdirectories {
            let directory = metaDirectory.appendingPathComponent(subdirectory)
            if !fileManager.fileExists(atPath: directory.path) {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
                Logger.shared.debug("Created directory: \(directory.path)")
            }
        }
        
        // Create version-specific directory
        let versionDir = metaDirectory.appendingPathComponent("versions").appendingPathComponent(manifestId)
        if !fileManager.fileExists(atPath: versionDir.path) {
            try fileManager.createDirectory(at: versionDir, withIntermediateDirectories: true, attributes: nil)
            Logger.shared.debug("Created directory: \(versionDir.path)")
        }
        
        // Create profile directory
        if !fileManager.fileExists(atPath: profileDirectory.path) {
            try fileManager.createDirectory(at: profileDirectory, withIntermediateDirectories: true, attributes: nil)
            Logger.shared.debug("Created directory: \(profileDirectory.path)")
        }
    }
    
    private func downloadCoreFiles(manifest: MinecraftVersionManifest) async throws {
        coreTotalFiles = calculateTotalFiles(manifest)
        
        async let clientJarDownload = downloadClientJar(manifest: manifest)
        async let librariesDownload = downloadLibraries(manifest: manifest)
        async let loggingConfigDownload = downloadLoggingConfig(manifest: manifest)
        
        _ = try await [clientJarDownload, librariesDownload, loggingConfigDownload]
    }
    
    private func downloadClientJar(manifest: MinecraftVersionManifest) async throws {
        let versionDir = metaDirectory.appendingPathComponent("versions").appendingPathComponent(manifest.id)
        let destinationURL = versionDir.appendingPathComponent("\(manifest.id).jar")
        
        try await downloadAndSaveFile(
            from: manifest.downloads.client.url,
            to: destinationURL,
            sha1: manifest.downloads.client.sha1,
            fileNameForNotification: NSLocalizedString("file.client.jar", comment: "Client JAR"),
            type: .core
        )
    }
    
    private func downloadLibraries(manifest: MinecraftVersionManifest) async throws {
        Logger.shared.info("Starting library downloads.")
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for library in manifest.libraries {
                group.addTask {
                    try await self.downloadLibrary(MinecraftLibrary(from: library))
                }
            }
        }
        
        Logger.shared.info("Finished library downloads.")
    }
    
    private func downloadLibrary(_ library: MinecraftLibrary) async throws {
        if let downloads = library.downloads {
            if let artifact = downloads.artifact {
                let destinationURL = metaDirectory.appendingPathComponent("libraries").appendingPathComponent(artifact.path)
                try await downloadAndSaveFile(
                    from: artifact.url,
                    to: destinationURL,
                    sha1: artifact.sha1,
                    fileNameForNotification: String(format: NSLocalizedString("file.library", comment: "Library: %@"), library.name),
                    type: .core
                )
            }
            
            if let classifiers = downloads.classifiers {
                try await downloadNativeLibrary(library: library, classifiers: classifiers)
            }
        } else if let directURL = library.url {
            let libraryPath = library.name.replacingOccurrences(of: ":", with: "/")
                .replacingOccurrences(of: ".", with: "/") + ".jar"
            let destinationURL = metaDirectory.appendingPathComponent("libraries").appendingPathComponent(libraryPath)
            try await downloadAndSaveFile(
                from: directURL,
                to: destinationURL,
                sha1: nil,
                fileNameForNotification: String(format: NSLocalizedString("file.library", comment: "Library: %@"), library.name),
                type: .core
            )
        }
    }
    
    private func downloadNativeLibrary(library: MinecraftLibrary, classifiers: [String: MinecraftArtifact]) async throws {
        #if os(macOS)
        let osClassifier = library.natives?["osx"]
        #elseif os(Linux)
        let osClassifier = library.natives?["linux"]
        #elseif os(Windows)
        let osClassifier = library.natives?["windows"]
        #else
        let osClassifier = nil
        #endif
        
        if let classifierKey = osClassifier,
           let nativeArtifact = classifiers[classifierKey] {
            let destinationURL = metaDirectory.appendingPathComponent("natives").appendingPathComponent(nativeArtifact.path)
            try await downloadAndSaveFile(
                from: nativeArtifact.url,
                to: destinationURL,
                sha1: nativeArtifact.sha1,
                fileNameForNotification: String(format: NSLocalizedString("file.native", comment: "Native: %@"), library.name),
                type: .core
            )
        }
    }
    
    private func downloadAssetIndex(manifest: MinecraftVersionManifest) async throws -> MinecraftAssetIndex {
        let destinationURL = metaDirectory.appendingPathComponent("assets/indexes").appendingPathComponent("\(manifest.assetIndex.id).json")
        
        // Download asset index if needed
        if !FileManager.default.fileExists(atPath: destinationURL.path) {
            try await downloadAndSaveFile(
                from: manifest.assetIndex.url,
                to: destinationURL,
                sha1: manifest.assetIndex.sha1,
                fileNameForNotification: NSLocalizedString("file.asset.index", comment: "Asset Index"),
                type: .core
            )
        }
        
        // Parse asset index
        let data = try Data(contentsOf: destinationURL)
        let decoder = JSONDecoder()
        let assetIndexData = try decoder.decode(AssetIndexData.self, from: data)
        
        // Convert to MinecraftAssetIndex
        var totalSize = 0
        var objects: [String: MinecraftAsset] = [:]
        
        for (path, object) in assetIndexData.objects {
            let asset = MinecraftAsset(
                hash: object.hash,
                size: object.size,
                url: URL(string: "https://resources.download.minecraft.net/\(String(object.hash.prefix(2)))/\(object.hash)")!
            )
            objects[path] = asset
            totalSize += object.size
        }
        
        return MinecraftAssetIndex(
            id: manifest.assetIndex.id,
            url: manifest.assetIndex.url,
            sha1: manifest.assetIndex.sha1,
            totalSize: totalSize,
            objects: objects
        )
    }
    
    private func downloadLoggingConfig(manifest: MinecraftVersionManifest) async throws {
        let loggingFile = manifest.logging.client.file
        let versionDir = metaDirectory.appendingPathComponent("versions").appendingPathComponent(manifest.id)
        let destinationURL = versionDir.appendingPathComponent(loggingFile.id)
        
        try await downloadAndSaveFile(
            from: loggingFile.url,
            to: destinationURL,
            sha1: loggingFile.sha1,
            fileNameForNotification: NSLocalizedString("file.logging.config", comment: "Logging Config"),
            type: .core
        )
    }
    
    private func downloadAndSaveFile(from url: URL, to destinationURL: URL, sha1: String?, fileNameForNotification: String? = nil, type: DownloadType) async throws {
        let fileManager = FileManager.default
        
        // Create parent directory if needed
        let parentDirectory = destinationURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: parentDirectory.path) {
            try fileManager.createDirectory(at: parentDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Check existing file
        if fileManager.fileExists(atPath: destinationURL.path), let expectedSha1 = sha1 {
            if try await verifyExistingFile(at: destinationURL, expectedSha1: expectedSha1) {
                incrementCompletedFilesCount(fileName: fileNameForNotification ?? destinationURL.lastPathComponent, type: type)
                return
            }
        }
        
        // Download and save file
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw MinecraftFileManagerError.invalidResponse
            }
            
            guard !data.isEmpty else {
                throw MinecraftFileManagerError.noData
            }
            
            // Verify SHA1 if provided
            if let expectedSha1 = sha1 {
                let downloadedSha1 = data.sha1CommonCrypto()
                if downloadedSha1 != expectedSha1 {
                    throw MinecraftFileManagerError.sha1Mismatch(expected: expectedSha1, actual: downloadedSha1)
                }
            }
            
            try data.write(to: destinationURL)
            Logger.shared.debug("Saved file to: \(destinationURL.path)")
            
            incrementCompletedFilesCount(fileName: fileNameForNotification ?? destinationURL.lastPathComponent, type: type)
            
        } catch let urlError as URLError {
            Logger.shared.error("Download failed for \(url.absoluteString): \(urlError.localizedDescription)")
            throw MinecraftFileManagerError.requestFailed(urlError)
        } catch {
            Logger.shared.error("Failed to save file to \(destinationURL.path): \(error.localizedDescription)")
            throw MinecraftFileManagerError.cannotWriteFile(destinationURL, error)
        }
    }
    
    private func verifyExistingFile(at url: URL, expectedSha1: String) async throws -> Bool {
        do {
            let fileData = try Data(contentsOf: url)
            let fileSha1 = fileData.sha1CommonCrypto()
            if fileSha1 == expectedSha1 {
                Logger.shared.info("File already exists and SHA1 matches: \(url.lastPathComponent)")
                return true
            } else {
                Logger.shared.warning("File exists but SHA1 mismatch: \(url.lastPathComponent). Redownloading.")
                return false
            }
        } catch {
            Logger.shared.error("Could not read existing file \(url.path) for SHA1 check: \(error)")
            return false
        }
    }
    
    private func incrementCompletedFilesCount(fileName: String, type: DownloadType) {
        let currentCount: Int
        let total: Int
        
        switch type {
        case .core:
            currentCount = coreFilesCount.increment()
            total = coreTotalFiles
        case .resources:
            currentCount = resourceFilesCount.increment()
            total = resourceTotalFiles
        }
        
        onProgressUpdate?(fileName, currentCount, total, type)
    }
    
    /// Downloads the content from a URL string.
    /// - Parameter urlString: The URL string of the file to download.
    /// - Returns: The downloaded Data.
    /// - Throws: A DownloadError if the URL is invalid or the download fails.
    // This method is less likely to be used within this class after merging,
    // but keeping it for completeness if needed elsewhere.
    func downloadFile(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw MinecraftFileManagerError.invalidURL
        }
        
         do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw MinecraftFileManagerError.invalidResponse
            }
            
            guard !data.isEmpty else {
                throw MinecraftFileManagerError.noData
            }
            
            return data
            
         } catch let urlError as URLError {
             throw MinecraftFileManagerError.requestFailed(urlError)
         } catch {
            throw MinecraftFileManagerError.requestFailed(error) // Generic request failed for download only method
        }
    }
    
    private func downloadAllAssets(assetIndex: MinecraftAssetIndex) async throws {
        let objectsDirectory = metaDirectory.appendingPathComponent("assets/objects")
        let assets = Array(assetIndex.objects)
        let chunkSize = 20 // Process 20 assets at a time for better concurrency
        
        // Process assets in chunks to maintain reasonable concurrency
        for chunk in stride(from: 0, to: assets.count, by: chunkSize) {
            let end = min(chunk + chunkSize, assets.count)
            let currentChunk = assets[chunk..<end]
            
            try await withThrowingTaskGroup(of: Void.self) { group in
                for (path, asset) in currentChunk {
                    group.addTask {
                        try await self.downloadAsset(asset: asset, path: path, objectsDirectory: objectsDirectory)
                    }
                }
            }
        }
    }
    
    private func downloadAsset(asset: MinecraftAsset, path: String, objectsDirectory: URL) async throws {
        let hashPrefix = String(asset.hash.prefix(2))
        let assetDirectory = objectsDirectory.appendingPathComponent(hashPrefix)
        let destinationURL = assetDirectory.appendingPathComponent(asset.hash)
        
        // Skip if file already exists and hash matches
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            if try await verifyExistingFile(at: destinationURL, expectedSha1: asset.hash) {
                incrementCompletedFilesCount(fileName: String(format: NSLocalizedString("file.asset", comment: "Asset: %@"), path), type: .resources)
                return
            }
        }
        
        try await downloadAndSaveFile(
            from: asset.url,
            to: destinationURL,
            sha1: asset.hash,
            fileNameForNotification: String(format: NSLocalizedString("file.asset", comment: "Asset: %@"), path),
            type: .resources
        )
    }
}

// Helper extension for SHA1 calculation using CommonCrypto
import CommonCrypto

extension Data {
    func sha1CommonCrypto() -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        _ = self.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            CC_SHA1(bytes.baseAddress, CC_LONG(bytes.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}

// Simple thread-safe counter using OSAllocatedUnfairLock
// Requires importing OSAllocatedUnfairLock from the os library, or implementing a similar lock manually.
// For simplicity and assuming a modern OS deployment target, we'll use NSLocking for now.
// Note: NSLocking is an AppKit/UIKit type. A more pure Foundation way would be os_unfair_lock_t or similar low-level primitive.
// For this example, let's use NSLock as a widely available Foundation class.
import Foundation // NSLock is in Foundation

class NSLockingCounter {
    private var count = 0
    private let lock = NSLock()
    
    func increment() -> Int {
        lock.lock()
        defer { lock.unlock() }
        count += 1
        return count
    }
    
    func reset() {
        lock.lock()
        defer { lock.unlock() }
        count = 0
    }
}

// MARK: - Asset Index Data Types
private struct AssetIndexData: Codable {
    let objects: [String: AssetObject]
    
    struct AssetObject: Codable {
        let hash: String
        let size: Int
    }
} 
 