import SwiftUI
import OSLog

enum PlayerUtils {
    private static let logger = Logger(subsystem: "com.launcher", category: "PlayerUtils")
    
    static func addPlayer(
        name: String,
        playerService: PlayerService,
        onSuccess: @escaping () -> Void,
        onError: @escaping (PlayerError) -> Void
    ) async {
        logger.debug("开始添加新玩家 - 名称：\(name)")
        
        do {
            try await playerService.addPlayer(name: name)
            logger.info("添加玩家成功 - 名称：\(name)")
            onSuccess()
        } catch {
            let playerError = (error as? PlayerError) ?? .unknown
            logger.error("添加玩家失败 - 名称：\(name), 错误：\(playerError.localizedDescription)")
            onError(playerError)
        }
    }
} 