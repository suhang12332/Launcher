import Foundation

struct MinecraftVersion: Codable, Identifiable {
    let id: String
    let type: String
    let url: String
    let time: String
    let releaseTime: String
}

struct VersionManifest: Codable {
    let latest: LatestVersion
    let versions: [MinecraftVersion]
}

struct LatestVersion: Codable {
    let release: String
    let snapshot: String
} 