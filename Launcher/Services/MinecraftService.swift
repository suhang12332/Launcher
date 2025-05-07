import Foundation


struct VersionDetail: Codable {}

enum MinecraftService {
    static func fetchVersionList() async throws -> VersionManifest {
        let (data, _) = try await URLSession.shared.data(from: URLConfig.API.Minecraft.versionList)
        return try JSONDecoder().decode(VersionManifest.self, from: data)
    }

//    static func fetchVersionDetail(version: String) async throws -> VersionDetail {
//        let (data, _) = try await URLSession.shared.data(from: URLConfig.API.Minecraft.versionDetail(version: version))
//        return try JSONDecoder().decode(VersionDetail.self, from: data)
//    }
} 
