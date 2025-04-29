import Foundation

struct AnalyticsEvent: Codable {}
struct UpdateInfo: Codable {}

enum ThirdPartyService {
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