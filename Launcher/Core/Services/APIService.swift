import Foundation

enum APIService {
    // Minecraft API 服务
    enum Minecraft {
        static func fetchVersionList() async throws -> VersionList {
            let (data, _) = try await URLSession.shared.data(from: URLConfig.API.Minecraft.versionList)
            return try JSONDecoder().decode(VersionList.self, from: data)
        }
        
        static func fetchVersionDetail(version: String) async throws -> VersionDetail {
            let (data, _) = try await URLSession.shared.data(from: URLConfig.API.Minecraft.versionDetail(version: version))
            return try JSONDecoder().decode(VersionDetail.self, from: data)
        }
    }
    
    // Modrinth API 服务
    enum Modrinth {
        // 项目相关
        static func fetchProject(id: String) async throws -> ModrinthProject {
            let (data, _) = try await URLSession.shared.data(from: URLConfig.API.Modrinth.project(id: id))
            return try JSONDecoder().decode(ModrinthProject.self, from: data)
        }
        
        // 版本相关
        static func fetchVersion(id: String) async throws -> ModrinthVersion {
            let (data, _) = try await URLSession.shared.data(from: URLConfig.API.Modrinth.version(id: id))
            return try JSONDecoder().decode(ModrinthVersion.self, from: data)
        }
        
        // 搜索相关
        static func searchProjects(query: String, limit: Int = 10) async throws -> ModrinthSearchResult {
            var components = URLComponents(url: URLConfig.API.Modrinth.search, resolvingAgainstBaseURL: true)!
            components.queryItems = [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "limit", value: String(limit))
            ]
            
            let (data, _) = try await URLSession.shared.data(from: components.url!)
            return try JSONDecoder().decode(ModrinthSearchResult.self, from: data)
        }
    }
    
    // 其他第三方 API 服务
    enum ThirdParty {
        static func sendAnalytics(event: AnalyticsEvent) async throws {
            var request = URLRequest(url: URLConfig.API.ThirdParty.analytics)
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(event)
            _ = try await URLSession.shared.data(for: request)
        }
        
        static func checkUpdate() async throws -> UpdateInfo {
            let (data, _) = try await URLSession.shared.data(from: URLConfig.API.ThirdParty.updateCheck)
            return try JSONDecoder().decode(UpdateInfo.self, from: data)
        }
    }
}

// 临时模型，后续需要完善
struct VersionList: Codable {}
struct VersionDetail: Codable {}
struct AnalyticsEvent: Codable {}
struct UpdateInfo: Codable {}

// Modrinth 相关模型
struct ModrinthProject: Codable {
    let id: String
    let slug: String
    let title: String
    let description: String
    let iconUrl: String?
    let downloads: Int
    let followers: Int
    let team: String
    let published: String
    let updated: String
    let status: String
    let license: ModrinthLicense
    let clientSide: String
    let serverSide: String
    let gameVersions: [String]
    let loaders: [String]
}

struct ModrinthVersion: Codable {
    let id: String
    let projectId: String
    let name: String
    let versionNumber: String
    let changelog: String?
    let files: [ModrinthFile]
    let dependencies: [ModrinthDependency]
    let gameVersions: [String]
    let loaders: [String]
    let featured: Bool
    let status: String
    let requestedStatus: String?
    let published: String
}

struct ModrinthFile: Codable {
    let hashes: [String: String]
    let url: String
    let filename: String
    let primary: Bool
    let size: Int
}

struct ModrinthDependency: Codable {
    let versionId: String?
    let projectId: String?
    let dependencyType: String
}

struct ModrinthLicense: Codable {
    let id: String
    let name: String
    let url: String?
}

struct ModrinthSearchResult: Codable {
    let hits: [ModrinthProject]
    let offset: Int
    let limit: Int
    let totalHits: Int
} 