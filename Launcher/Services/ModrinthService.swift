import Foundation

enum ModrinthService {

    static func fetchProject(id: String) async throws -> ModrinthProject {
        let (data, _) = try await URLSession.shared.data(
            from: URLConfig.API.Modrinth.project(id: id)
        )
        return try JSONDecoder().decode(ModrinthProject.self, from: data)
    }

    static func searchProjects(
        facets: [[String]]? = nil,
        index: String,
        offset: Int = 0,
        limit: Int
    ) async throws -> ModrinthResult {
        var components = URLComponents(
            url: URLConfig.API.Modrinth.search,
            resolvingAgainstBaseURL: true
        )!
        var queryItems = [
            URLQueryItem(name: "index", value: index),
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "limit", value: String(min(limit, 100))),
        ]
        if let facets = facets {
            let facetsJson = try JSONEncoder().encode(facets)
            if let facetsString = String(data: facetsJson, encoding: .utf8) {
                queryItems.append(
                    URLQueryItem(name: "facets", value: facetsString)
                )
            }
        }
        components.queryItems = queryItems
        guard let url = components.url else { throw URLError(.badURL) }
        Logger.shared.info("Modrinth 搜索 URL：\(url.absoluteString)")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(ModrinthResult.self, from: data)
    }

    static func fetchLoaders() async throws -> [Loader] {
        let (data, _) = try await URLSession.shared.data(
            from: URLConfig.API.Modrinth.Tag.loader
        )
        return try JSONDecoder().decode([Loader].self, from: data)
    }

    static func fetchCategories() async throws -> [Category] {
        let (data, _) = try await URLSession.shared.data(
            from: URLConfig.API.Modrinth.Tag.category
        )
        return try JSONDecoder().decode([Category].self, from: data)
    }

    

    static func fetchGameVersions() async throws -> [GameVersion] {
        let (data, _) = try await URLSession.shared.data(
            from: URLConfig.API.Modrinth.Tag.gameVersion
        )
        return try JSONDecoder().decode([GameVersion].self, from: data)
    }

    static func fetchProjectDetails(id: String) async throws -> ModrinthProjectDetail {
        let url = URLConfig.API.Modrinth.project(id: id)
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return try decoder.decode(ModrinthProjectDetail.self, from: data)
    }
}
