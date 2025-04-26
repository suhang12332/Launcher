import Foundation
import OSLog

enum PlayerError: LocalizedError {
    case playerAlreadyExists
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .playerAlreadyExists:
            return NSLocalizedString("player.add.error.exists", comment: "")
        case .unknown:
            return NSLocalizedString("player.add.error.unknown", comment: "")
        }
    }
}

struct Player: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let lastPlayed: Date
    
    init(id: UUID? = nil, name: String, lastPlayed: Date = Date()) {
        self.id = id ?? UUIDUtils.generateOfflineUUID(for: name)
        self.name = name
        self.lastPlayed = lastPlayed
    }
}

@MainActor
final class PlayerService: ObservableObject {
    static let shared = PlayerService()
    
    @Published private(set) var players: [Player] = []
    @Published private(set) var selectedPlayer: Player?
    
    private let userDefaults = UserDefaults.standard
    private let playersKey = "players"
    private let selectedPlayerKey = "selectedPlayer"
    private let logger = Logger(subsystem: "com.launcher", category: "PlayerService")
    
    private init() {
        loadPlayers()
        loadSelectedPlayer()
    }
    
    func addPlayer(name: String) async throws {
        guard !self.players.contains(where: { $0.name == name }) else {
            logger.error("添加离线用户失败：离线用户名已存在 - \(name)")
            throw PlayerError.playerAlreadyExists
        }
        
        let player = Player(name: name)
        self.players.insert(player, at: 0)
        savePlayers()
        
        logger.info("添加新离线用户成功 - 名称：\(name), UUID：\(player.id.uuidString.lowercased())")
        
        try await selectPlayer(player)
    }
    
    func selectPlayer(_ player: Player) async throws {
        guard self.players.contains(player) else {
            return
        }
        
        // 更新最后游玩时间
        if let index = self.players.firstIndex(of: player) {
            var updatedPlayer = player
            updatedPlayer = Player(id: player.id, name: player.name, lastPlayed: Date())
            self.players[index] = updatedPlayer
            self.selectedPlayer = updatedPlayer
            savePlayers()
            saveSelectedPlayer()
            
            logger.info("选择离线用户 - 名称：\(player.name), UUID：\(player.id.uuidString.lowercased())")
        }
    }
    
    func removePlayer(_ player: Player) {
        self.players.removeAll { $0.id == player.id }
        savePlayers()
        
        if self.selectedPlayer?.id == player.id {
            self.selectedPlayer = self.players.first
            saveSelectedPlayer()
        }
        
        logger.info("移除离线用户 - 名称：\(player.name), UUID：\(player.id.uuidString.lowercased())")
    }
    
    private func savePlayers() {
        if let encoded = try? JSONEncoder().encode(self.players) {
            userDefaults.set(encoded, forKey: playersKey)
            logger.debug("保存离线用户列表成功 - 离线用户数量：\(self.players.count)")
        } else {
            logger.error("保存离线用户列表失败")
        }
    }
    
    private func saveSelectedPlayer() {
        if let player = self.selectedPlayer,
           let encoded = try? JSONEncoder().encode(player) {
            userDefaults.set(encoded, forKey: selectedPlayerKey)
            logger.debug("保存选中离线用户成功 - 名称：\(player.name)")
        } else {
            userDefaults.removeObject(forKey: selectedPlayerKey)
            logger.debug("清除选中离线用户")
        }
    }
    
    private func loadPlayers() {
        if let data = userDefaults.data(forKey: playersKey),
           let decoded = try? JSONDecoder().decode([Player].self, from: data) {
            self.players = decoded.sorted { $0.lastPlayed > $1.lastPlayed }
            logger.debug("加载离线用户列表成功 - 离线用户数量：\(self.players.count)")
        } else {
            logger.debug("加载离线用户列表失败或为空")
        }
    }
    
    private func loadSelectedPlayer() {
        if let data = userDefaults.data(forKey: selectedPlayerKey),
           let decoded = try? JSONDecoder().decode(Player.self, from: data) {
            self.selectedPlayer = decoded
            logger.debug("加载选中离线用户成功 - 名称：\(decoded.name)")
        } else {
            self.selectedPlayer = self.players.first
            logger.debug("加载选中离线用户失败，使用第一个离线用户")
        }
    }
} 