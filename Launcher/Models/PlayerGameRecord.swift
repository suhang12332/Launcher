import Foundation

struct PlayerGameRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let playerId: UUID  // 关联 Player.id
    let gameVersionId: UUID  // 关联 GameVersionInfo.id
    let startPlayTime: Date  // 初始游玩时间
    var playTime: TimeInterval  // 累计游玩时间，单位：秒
    var lastPlayed: Date  // 最后游玩时间
    let gameVersion: String
    // 兼容旧数据的初始化
    init(
        id: UUID,
        playerId: UUID,
        gameVersionId: UUID,
        startPlayTime: Date,
        playTime: TimeInterval,
        lastPlayed: Date,
        gameVersion: String
    ) {
        self.id = id
        self.playerId = playerId
        self.gameVersionId = gameVersionId
        self.startPlayTime = startPlayTime
        self.playTime = playTime
        self.lastPlayed = lastPlayed
        self.gameVersion = gameVersion
    }
}
