import SwiftUI
import CryptoKit

/// 玩家工具类，提供UUID生成和头像名称获取等功能
enum PlayerUtils {
    // MARK: - Constants
    
    /// 预定义的玩家名称列表
    private static let names = ["alex", "ari", "efe", "kai", "makena", "noor", "steve", "sunny", "zuri"]
    
    /// UUID 前缀
    private static let offlinePrefix = "OfflinePlayer:"
    
    // MARK: - UUID Generation
    
    /// 为离线玩家生成UUID
    /// - Parameter username: 玩家用户名
    /// - Returns: 生成的UUID字符串（小写）
    /// - Throws: 如果用户名无效或生成过程出错
    static func generateOfflineUUID(for username: String) throws -> String {
        guard !username.isEmpty else {
            throw PlayerError.invalidUsername
        }
        
        let input = offlinePrefix + username
        guard let data = input.data(using: .utf8) else {
            throw PlayerError.encodingError
        }
        
        let digest = Insecure.MD5.hash(data: data)
        var bytes = [UInt8](digest)
        
        // 设置 UUID 版本为 3 (MD5)
        bytes[6] = (bytes[6] & 0x0F) | 0x30
        // 设置 UUID 变体为 RFC 4122
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        
        let uuid = bytes.withUnsafeBytes { ptr in
            UUID(uuid: ptr.load(as: uuid_t.self))
        }
        
        let uuidString = uuid.uuidString.lowercased()
        Logger.shared.debug("生成离线 UUID - 用户名：\(username), UUID：\(uuidString)")
        
        return uuidString
    }
    
    // MARK: - Avatar Name Generation
    
    /// 根据UUID获取对应的头像名称
    /// - Parameter uuid: 玩家UUID
    /// - Returns: 头像名称，如果UUID无效则返回nil
    static func avatarName(for uuid: String) -> String? {
        guard let index = nameIndex(for: uuid) else {
            Logger.shared.warning("无法获取头像名称 - 无效的UUID: \(uuid)")
            return nil
        }
        return names[index]
    }
    
    /// 根据UUID计算名称数组的索引
    /// - Parameter uuid: 玩家UUID
    /// - Returns: 名称数组的索引（0~8），如果UUID无效则返回nil
    private static func nameIndex(for uuid: String) -> Int? {
        let cleanUUID = uuid.replacingOccurrences(of: "-", with: "")
        guard cleanUUID.count >= 32 else { return nil }
        
        let iStr = String(cleanUUID.prefix(16))
        let uStr = String(cleanUUID.dropFirst(16).prefix(16))
        
        guard let i = UInt64(iStr, radix: 16),
              let u = UInt64(uStr, radix: 16) else { return nil }
        
        let f = i ^ u
        let mixedBits = (f ^ (f >> 32)) & 0xffffffff
        let I = Int32(bitPattern: UInt32(truncatingIfNeeded: mixedBits))
        
        return (Int(I) % names.count + names.count) % names.count
    }
}

// MARK: - Error Handling

/// 玩家相关错误类型
enum PlayerError: LocalizedError {
    case invalidUsername
    case encodingError
    case uuidGenerationFailed
    case custom(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidUsername:
            return "无效的用户名"
        case .encodingError:
            return "字符串编码错误"
        case .uuidGenerationFailed:
            return "UUID生成失败"
        case .custom(let message):
            return message
        }
    }
    
    init(localizedDescription: String) {
        self = .custom(localizedDescription)
    }
}




