import Foundation

struct GameVersionInfo: Codable, Equatable, Identifiable {
    let id: String
    let gameName: String
    let gameIcon: String  // 图片名或URL
    let gameVersion: String
    let modLoader: String
    let isUserAdded: Bool  // true: 自己添加，false: 下载的整合包
    let createdAt: Date
    var lastPlayed: Date
    var isRunning: Bool  // 新增字段，是否正在运行

    init(
        id: UUID = UUID(),
        gameName: String,
        gameIcon: String,
        gameVersion: String,
        modLoader: String,
        isUserAdded: Bool,
        createdAt: Date = Date(),
        lastPlayed: Date = Date(),
        isRunning: Bool = false
    ) {
        self.id = id.uuidString
        self.gameName = gameName
        self.gameIcon = gameIcon
        self.gameVersion = gameVersion
        self.modLoader = modLoader
        self.isUserAdded = isUserAdded
        self.createdAt = createdAt
        self.lastPlayed = lastPlayed
        self.isRunning = isRunning
    }
}
