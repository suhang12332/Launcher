import Foundation

@MainActor
final class PlayerService: ObservableObject {
    static let shared = PlayerService()
    private let repository = PlayerUserDefaultsRepository()

    @Published private(set) var players: [Player] = [] {
        didSet {
            selectedPlayer = players.first(where: { $0.isCurrent })
        }
    }
    @Published private(set) var selectedPlayer: Player?

    private init() {
        fetchPlayers()
    }

    func fetchPlayers() {
        let fetched = repository.fetchAll()
        if fetched.isEmpty {
            Logger.shared.warning("未查询到任何玩家信息！")
        } else {
            Logger.shared.info("查询到玩家数量：\(fetched.count)")
        }
        self.players = fetched
        if let selected = self.selectedPlayer {
            Logger.shared.info("当前选中用户：\(selected.name) (id: \(selected.id))")
        } else {
            Logger.shared.info("当前没有选中用户")
        }
    }

    func addPlayer(_ player: Player) {
        let allPlayers = repository.fetchAll()
        if let current = allPlayers.first(where: { $0.isCurrent }) {
            var prev = current
            prev.isCurrent = false
            prev.lastPlayed = Date()
            repository.update(prev)
            Logger.shared.info("上一个玩家 \(prev.name) (id: \(prev.id)) 取消选中并更新时间")
        }
        var newPlayer = player
        newPlayer.isCurrent = true
        repository.add(newPlayer)
        Logger.shared.info(
            "添加新玩家：\(newPlayer.name) (id: \(newPlayer.id)) 并设为当前用户"
        )
        fetchPlayers()
    }

    func selectPlayer(by id: String) {
        let allPlayers = repository.fetchAll()
        if let prev = allPlayers.first(where: { $0.isCurrent }) {
            var updatedPrev = prev
            updatedPrev.isCurrent = false
            updatedPrev.lastPlayed = Date()
            repository.update(updatedPrev)
            Logger.shared.info(
                "上一个玩家 \(updatedPrev.name) (id: \(updatedPrev.id)) 取消选中并更新时间"
            )
        }
        if let target = allPlayers.first(where: { $0.id == id }) {
            var updatedTarget = target
            updatedTarget.isCurrent = true
            repository.update(updatedTarget)
            Logger.shared.info(
                "切换当前玩家为：\(updatedTarget.name) (id: \(updatedTarget.id))"
            )
        }
        fetchPlayers()
    }

    func updatePlayer(_ player: Player) {
        repository.update(player)
        Logger.shared.info("更新玩家信息：\(player.name) (id: \(player.id))")
        fetchPlayers()
    }

    func removePlayer(by id: String) {
        let allPlayers = repository.fetchAll()
        let isCurrent =
            allPlayers.first(where: { $0.id == id })?.isCurrent ?? false
        repository.delete(playerId: id)
        Logger.shared.info("删除玩家 (id: \(id))")
        if isCurrent, var first = repository.fetchAll().first {
            first.isCurrent = true
            repository.update(first)
            Logger.shared.info("删除的是当前玩家，自动切换到：\(first.name) (id: \(first.id))")
        }
        fetchPlayers()
    }

    func getAllPlayers() -> [Player] {
        return repository.fetchAll()
    }
}
