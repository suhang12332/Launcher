import Combine
import Foundation

/// 游戏版本信息仓库
/// 负责游戏版本信息的持久化存储和管理
class GameRepository: ObservableObject {
    // MARK: - Properties

    /// 已保存的游戏列表
    @Published private(set) var games: [GameVersionInfo] = []

    /// UserDefaults 存储键
    private let gamesKey = "savedGames"

    // MARK: - Initialization

    init() {
        loadGames()
    }

    // MARK: - Public Methods

    /// 添加新游戏
    /// - Parameter game: 要添加的游戏版本信息
    func addGame(_ game: GameVersionInfo) {
        games.append(game)
        saveGames()
    }

    /// 删除游戏
    /// - Parameter id: 要删除的游戏ID
    func deleteGame(id: String) {
        games.removeAll { $0.id == id }
        saveGames()
    }

    /// 更新游戏信息
    /// - Parameter updatedGame: 更新后的游戏版本信息
    func updateGame(_ updatedGame: GameVersionInfo) {
        if let index = games.firstIndex(where: { $0.id == updatedGame.id }) {
            games[index] = updatedGame
            saveGames()
        }
    }

    // MARK: - Private Methods

    /// 从 UserDefaults 加载游戏列表
    private func loadGames() {
        guard let savedGamesData = UserDefaults.standard.data(forKey: gamesKey)
        else {
            games = []
            return
        }

        do {
            let decoder = JSONDecoder()
            games = try decoder.decode(
                [GameVersionInfo].self,
                from: savedGamesData
            )
        } catch {
            Logger.shared.error(
                "Failed to load games: \(error.localizedDescription)"
            )
            games = []
        }
    }

    /// 保存游戏列表到 UserDefaults
    private func saveGames() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(games)
            UserDefaults.standard.set(encodedData, forKey: gamesKey)
        } catch {
            Logger.shared.error(
                "Failed to save games: \(error.localizedDescription)"
            )
        }
    }
}
