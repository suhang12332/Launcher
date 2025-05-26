import Foundation

// Modrinth 项目模型
struct ModrinthProject: Codable {
    let projectId: String
    let projectType: String
    let slug: String
    let author: String
    let title: String
    let description: String
    let categories: [String]
    let displayCategories: [String]
    let versions: [String]
    let downloads: Int
    let follows: Int
    let iconUrl: String?
    let dateCreated: String
    let dateModified: String
    let latestVersion: String
    let license: String
    let clientSide: String
    let serverSide: String
    let gallery: [String]?
    let featuredGallery: String?
    let color: Int?

    enum CodingKeys: String, CodingKey {
        case projectId = "project_id"
        case projectType = "project_type"
        case slug, author, title, description, categories
        case displayCategories = "display_categories"
        case versions, downloads, follows
        case iconUrl = "icon_url"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
        case latestVersion = "latest_version"
        case license
        case clientSide = "client_side"
        case serverSide = "server_side"
        case gallery
        case featuredGallery = "featured_gallery"
        case color
    }
}

// Modrinth 版本模型
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

// Modrinth 文件模型
struct ModrinthFile: Codable {
    let hashes: [String: String]
    let url: String
    let filename: String
    let primary: Bool
    let size: Int
}

// Modrinth 依赖模型
struct ModrinthDependency: Codable {
    let versionId: String?
    let projectId: String?
    let dependencyType: String
}

// Modrinth 许可证模型
struct ModrinthLicense: Codable {
    let id: String
    let name: String
    let url: String?
}

// Modrinth 搜索结果模型
struct ModrinthResult: Codable {
    let hits: [ModrinthProject]
    let offset: Int
    let limit: Int
    let totalHits: Int

    enum CodingKeys: String, CodingKey {
        case hits, offset, limit
        case totalHits = "total_hits"
    }
} 

// 游戏版本
struct GameVersion: Codable, Identifiable {
    let version: String
    let version_type: String
    let date: String
    let major: Bool
    
    var id: String { version }
}

// 加载器
struct Loader: Codable, Identifiable {
    let name: String
    let icon: String
    let supported_project_types: [String]
    
    var id: String { name }
}

// 分类
struct Category: Codable, Identifiable {
    let name: String
    let icon: String
    let project_type: String
    let header: String
    
    var id: String { name }
}

// 许可证
struct License: Codable, Identifiable {
    let name: String
    let short: String
    var id: String { name }
}
