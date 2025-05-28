import Foundation

struct Player: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let avatarName: String  // 头像图片名或URL字符串
    let createdAt: Date
    var lastPlayed: Date
    var isOnlineAccount: Bool  // 新增字段，是否为在线账户
    var isCurrent: Bool  // 新增字段，是否为当前正在玩的玩家
    var gameRecords: [String: PlayerGameRecord]  // key: 游戏名或ID

    init(
        name: String,
        createdAt: Date = Date(),
        lastPlayed: Date = Date(),
        isOnlineAccount: Bool = false,
        isCurrent: Bool = false,
        gameRecords: [String: PlayerGameRecord] = [:]
    ) throws {
        let uid = try PlayerUtils.generateOfflineUUID(for: name)
        self.id = uid
        self.name = name
        self.avatarName = PlayerUtils.avatarName(for: uid) ?? "steve"
        self.createdAt = createdAt
        self.lastPlayed = lastPlayed
        self.isOnlineAccount = isOnlineAccount
        self.isCurrent = isCurrent
        self.gameRecords = gameRecords
    }
}
