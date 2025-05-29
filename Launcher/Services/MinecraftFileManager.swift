import Foundation
import CommonCrypto

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
    static let maxConcurrentDownloads = 8
    static let assetChunkSize = 50
    static let downloadTimeout: TimeInterval = 30
    static let retryCount = 3
    static let retryDelay: TimeInterval = 2
    static let memoryBufferSize = 1024 * 1024 // 1MB buffer for file operations
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
    private let downloadQueue = DispatchQueue(label: "com.launcher.download", qos: .userInitiated)
    private let fileManager = FileManager.default
    private let session: URLSession
    
    var onProgressUpdate: ((String, Int, Int, DownloadType) -> Void)?
    
    enum DownloadType {
        case core
        case resources
    }
    
    // MARK: - Initialization
    init(metaDirectory: URL, profileDirectory: URL) {
        self.metaDirectory = metaDirectory
        self.profileDirectory = profileDirectory
        
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = Constants.downloadTimeout
        config.timeoutIntervalForResource = Constants.downloadTimeout
        config.httpMaximumConnectionsPerHost = Constants.maxConcurrentDownloads
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Public Methods
    func downloadVersionFiles(manifest: MinecraftVersionManifest) async throws {
        Logger.shared.info("开始下载 Minecraft 版本：\(manifest.id)")
        
        try createDirectories(manifestId: manifest.id)
        
        // Use bounded task groups to limit concurrency
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { [weak self] in
                try await self?.downloadCoreFiles(manifest: manifest)
            }
            group.addTask { [weak self] in
                try await self?.downloadAssets(manifest: manifest)
            }
            
            try await group.waitForAll()
        }
        
        Logger.shared.info("完成下载 Minecraft 版本文件：\(manifest.id)")
    }
    
    // MARK: - Private Methods
    private func calculateTotalFiles(_ manifest: MinecraftVersionManifest) -> Int {
        1 + manifest.libraries.count + 1 + 1 // Client JAR + Libraries + Asset index + Logging config
    }
    
    private func createDirectories(manifestId: String) throws {
        // Create all directories in one pass
        let directoriesToCreate = Constants.metaSubdirectories.map {
            metaDirectory.appendingPathComponent($0)
        } + [
            metaDirectory.appendingPathComponent("versions").appendingPathComponent(manifestId),
            profileDirectory
        ]
        
        for directory in directoriesToCreate {
            if !fileManager.fileExists(atPath: directory.path) {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
                Logger.shared.debug("创建目录：\(directory.path)")
            }
        }
    }
    
    private func downloadCoreFiles(manifest: MinecraftVersionManifest) async throws {
        coreTotalFiles = calculateTotalFiles(manifest)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { [weak self] in
                try await self?.downloadClientJar(manifest: manifest)
            }
            group.addTask { [weak self] in
                try await self?.downloadLibraries(manifest: manifest)
            }
            group.addTask { [weak self] in
                try await self?.downloadLoggingConfig(manifest: manifest)
            }
            
            try await group.waitForAll()
        }
    }
    
    private func downloadClientJar(manifest: MinecraftVersionManifest) async throws {
        let versionDir = metaDirectory.appendingPathComponent("versions").appendingPathComponent(manifest.id)
        let destinationURL = versionDir.appendingPathComponent("\(manifest.id).jar")
        
        try await downloadAndSaveFile(
            from: manifest.downloads.client.url,
            to: destinationURL,
            sha1: manifest.downloads.client.sha1,
            fileNameForNotification: NSLocalizedString("file.client.jar", comment: ""),
            type: .core
        )
    }
    
    private func downloadLibraries(manifest: MinecraftVersionManifest) async throws {
        Logger.shared.info("开始下载库文件")
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for library in manifest.libraries {
                group.addTask { [weak self] in
                    try await self?.downloadLibrary(MinecraftLibrary(from: library))
                }
            }
            
            try await group.waitForAll()
        }
        
        Logger.shared.info("完成下载库文件")
    }
    
    private func downloadLibrary(_ library: MinecraftLibrary) async throws {
        if let downloads = library.downloads {
            if let artifact = downloads.artifact {
                let destinationURL = metaDirectory.appendingPathComponent("libraries").appendingPathComponent(artifact.path)
                try await downloadAndSaveFile(
                    from: artifact.url,
                    to: destinationURL,
                    sha1: artifact.sha1,
                    fileNameForNotification: String(format: NSLocalizedString("file.library", comment: ""), library.name),
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
                fileNameForNotification: String(format: NSLocalizedString("file.library", comment: ""), library.name),
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
                fileNameForNotification: String(format: NSLocalizedString("file.native", comment: ""), library.name),
                type: .core
            )
        }
    }
    
    private func downloadAssets(manifest: MinecraftVersionManifest) async throws {
        Logger.shared.info("开始下载 Minecraft 版本资源：\(manifest.id)")
        
        let assetIndex = try await downloadAssetIndex(manifest: manifest)
        resourceTotalFiles = assetIndex.objects.count
        
        try await downloadAllAssets(assetIndex: assetIndex)
        
        Logger.shared.info("完成下载 Minecraft 版本资源：\(manifest.id)")
    }
    
    private func downloadAssetIndex(manifest: MinecraftVersionManifest) async throws -> MinecraftAssetIndex {
        let destinationURL = metaDirectory.appendingPathComponent("assets/indexes").appendingPathComponent("\(manifest.assetIndex.id).json")
        
        if !fileManager.fileExists(atPath: destinationURL.path) {
            try await downloadAndSaveFile(
                from: manifest.assetIndex.url,
                to: destinationURL,
                sha1: manifest.assetIndex.sha1,
                fileNameForNotification: NSLocalizedString("file.asset.index", comment: ""),
                type: .core
            )
        }
        
        let data = try Data(contentsOf: destinationURL)
        let assetIndexData = try JSONDecoder().decode(AssetIndexData.self, from: data)
        
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
            fileNameForNotification: NSLocalizedString("file.logging.config", comment: ""),
            type: .core
        )
    }
    
    private func downloadAndSaveFile(from url: URL, to destinationURL: URL, sha1: String?, fileNameForNotification: String? = nil, type: DownloadType) async throws {
        // Check existing file first
        if fileManager.fileExists(atPath: destinationURL.path), let expectedSha1 = sha1 {
            if try await verifyExistingFile(at: destinationURL, expectedSha1: expectedSha1) {
                incrementCompletedFilesCount(fileName: fileNameForNotification ?? destinationURL.lastPathComponent, type: type)
                return
            }
        }
        
        // Create parent directory if needed
        try fileManager.createDirectory(at: destinationURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        
        // Download with retry
        var lastError: Error?
        for attempt in 0..<Constants.retryCount {
            do {
                let (tempFileURL, response) = try await session.download(from: url)
                defer { try? fileManager.removeItem(at: tempFileURL) }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw MinecraftFileManagerError.invalidResponse
                }
                
                // Verify SHA1 if needed
                if let expectedSha1 = sha1 {
                    let downloadedSha1 = try await calculateFileSHA1(at: tempFileURL)
                    if downloadedSha1 != expectedSha1 {
                        throw MinecraftFileManagerError.sha1Mismatch(expected: expectedSha1, actual: downloadedSha1)
                    }
                }
                
                // Move file to final location atomically
                try fileManager.moveItem(at: tempFileURL, to: destinationURL)
                
                incrementCompletedFilesCount(fileName: fileNameForNotification ?? destinationURL.lastPathComponent, type: type)
                return
                
            } catch {
                lastError = error
                if attempt < Constants.retryCount - 1 {
                    try await Task.sleep(nanoseconds: UInt64(Constants.retryDelay * 1_000_000_000))
                    continue
                }
            }
        }
        
        throw lastError ?? MinecraftFileManagerError.requestFailed(URLError(.unknown))
    }
    
    private func verifyExistingFile(at url: URL, expectedSha1: String) async throws -> Bool {
        let fileSha1 = try await calculateFileSHA1(at: url)
        return fileSha1 == expectedSha1
    }
    
    private func calculateFileSHA1(at url: URL) async throws -> String {
        let fileHandle = try FileHandle(forReadingFrom: url)
        defer { try? fileHandle.close() }
        
        var context = CC_SHA1_CTX()
        CC_SHA1_Init(&context)
        
        while autoreleasepool(invoking: {
            let data = fileHandle.readData(ofLength: Constants.memoryBufferSize)
            if !data.isEmpty {
                data.withUnsafeBytes { bytes in
                    _ = CC_SHA1_Update(&context, bytes.baseAddress, CC_LONG(data.count))
                }
                return true
            }
            return false
        }) {}
        
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        _ = CC_SHA1_Final(&digest, &context)
        
        return digest.map { String(format: "%02hhx", $0) }.joined()
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
    
    private func downloadAllAssets(assetIndex: MinecraftAssetIndex) async throws {
        let objectsDirectory = metaDirectory.appendingPathComponent("assets/objects")
        let assets = Array(assetIndex.objects)
        
        // Process assets in chunks to balance memory usage and performance
        for chunk in stride(from: 0, to: assets.count, by: Constants.assetChunkSize) {
            let end = min(chunk + Constants.assetChunkSize, assets.count)
            let currentChunk = assets[chunk..<end]
            
            try await withThrowingTaskGroup(of: Void.self) { group in
                for (path, asset) in currentChunk {
                    group.addTask { [weak self] in
                        try await self?.downloadAsset(asset: asset, path: path, objectsDirectory: objectsDirectory)
                    }
                }
                try await group.waitForAll()
            }
        }
    }
    
    private func downloadAsset(asset: MinecraftAsset, path: String, objectsDirectory: URL) async throws {
        let hashPrefix = String(asset.hash.prefix(2))
        let assetDirectory = objectsDirectory.appendingPathComponent(hashPrefix)
        let destinationURL = assetDirectory.appendingPathComponent(asset.hash)
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            if try await verifyExistingFile(at: destinationURL, expectedSha1: asset.hash) {
                incrementCompletedFilesCount(fileName: String(format: NSLocalizedString("file.asset", comment: ""), path), type: .resources)
                return
            }
        }
        
        try await downloadAndSaveFile(
            from: asset.url,
            to: destinationURL,
            sha1: asset.hash,
            fileNameForNotification: String(format: NSLocalizedString("file.asset", comment: ""), path),
            type: .resources
        )
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

// MARK: - Thread-safe Counter
final class NSLockingCounter {
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