import Foundation


enum ModrinthService {
    enum SearchIndex: String {
        case relevance, downloads, follows, newest, updated
    }

    static func fetchProject(id: String) async throws -> ModrinthProject {
        let (data, _) = try await URLSession.shared.data(from: URLConfig.API.Modrinth.project(id: id))
        return try JSONDecoder().decode(ModrinthProject.self, from: data)
    }

    static func searchProjects(
        facets: [[String]]? = nil,
        index: SearchIndex = .relevance,
        offset: Int = 0,
        limit: Int
    ) async throws -> ModrinthResult {
        var components = URLComponents(url: URLConfig.API.Modrinth.search, resolvingAgainstBaseURL: true)!
        var queryItems = [
            URLQueryItem(name: "index", value: index.rawValue),
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "limit", value: String(min(limit, 100)))
        ]
        if let facets = facets {
            let facetsJson = try JSONEncoder().encode(facets)
            if let facetsString = String(data: facetsJson, encoding: .utf8) {
                queryItems.append(URLQueryItem(name: "facets", value: facetsString))
            }
        }
        components.queryItems = queryItems
        guard let url = components.url else { throw URLError(.badURL) }
        Logger.shared.info(url.absoluteString)
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(ModrinthResult.self, from: data)
    }
} 
