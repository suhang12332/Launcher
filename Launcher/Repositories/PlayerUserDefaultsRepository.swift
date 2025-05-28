import Foundation

// 引入全局 JSONCodableHelper 工具类

class PlayerUserDefaultsRepository {
    private let playersKey = "players"

    func fetchAll() -> [Player] {
        guard let data = UserDefaults.standard.data(forKey: playersKey),
            let players = JSONCodableHelper.decode([Player].self, from: data)
        else {
            return []
        }
        return players
    }

    func add(_ player: Player) {
        var players = fetchAll()
        players.append(player)
        if let data = JSONCodableHelper.encode(players) {
            UserDefaults.standard.set(data, forKey: playersKey)
        }
    }

    func update(_ player: Player) {
        var players = fetchAll()
        if let idx = players.firstIndex(where: { $0.id == player.id }) {
            players[idx] = player
            if let data = JSONCodableHelper.encode(players) {
                UserDefaults.standard.set(data, forKey: playersKey)
            }
        }
    }

    func delete(playerId: String) {
        var players = fetchAll()
        players.removeAll { $0.id == playerId }
        if let data = JSONCodableHelper.encode(players) {
            UserDefaults.standard.set(data, forKey: playersKey)
        }
    }

    // 新增：清空所有用户信息
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: playersKey)
    }
}
