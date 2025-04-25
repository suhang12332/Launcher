import Foundation

class MinecraftVersionService {
    private let versionManifestURL = "https://launchermeta.mojang.com/mc/game/version_manifest.json"
    
    func fetchReleaseVersions() async throws -> [MinecraftVersion] {
        guard let url = URL(string: versionManifestURL) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let manifest = try JSONDecoder().decode(VersionManifest.self, from: data)
        
        // Filter only release versions
        return manifest.versions.filter { $0.type == "release" }
    }
} 