import Foundation
import CryptoKit
import OSLog

enum UUIDUtils {
    private static let logger = Logger(subsystem: "com.launcher", category: "UUIDUtils")
    
    static func generateOfflineUUID(for username: String) -> UUID {
        let prefix = "OfflinePlayer:"
        let input = prefix + username
        let data = input.data(using: .utf8)!
        
        // 使用 MD5 生成哈希
        let digest = Insecure.MD5.hash(data: data)
        var bytes = [UInt8](digest)
        
        // 设置 UUID 版本为 3 (MD5)
        bytes[6] = (bytes[6] & 0x0F) | 0x30
        // 设置 UUID 变体为 RFC 4122
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        
        // 创建 UUID
        let uuid = bytes.withUnsafeBytes { ptr in
            UUID(uuid: ptr.load(as: uuid_t.self))
        }
        
        // 将 UUID 字符串转换为小写
        let uuidString = uuid.uuidString.lowercased()
        logger.debug("生成离线 UUID - 用户名：\(username), UUID：\(uuidString)")
        
        // 从小写字符串重新创建 UUID
        return UUID(uuidString: uuidString) ?? uuid
    }
} 
