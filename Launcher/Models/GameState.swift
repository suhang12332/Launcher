import Foundation

class GameState: ObservableObject {
    static let shared = GameState()
    
    @Published var versions: [MinecraftVersion] = []
    @Published var isLoading = true  // 默认为加载状态
    @Published var error: Error?
    
    private let versionService = MinecraftVersionService()
    
    private init() {}
    
    @MainActor
    func loadVersions() async {
        isLoading = true
        do {
            versions = try await versionService.fetchReleaseVersions()
        } catch {
            self.error = error
        }
        isLoading = false
    }
} 