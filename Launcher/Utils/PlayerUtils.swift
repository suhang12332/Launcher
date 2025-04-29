import SwiftUI
import CryptoKit

enum PlayerUtils {
    
    
    static func generateOfflineUUID(for username: String) -> String {
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
        Logger.shared.debug("生成离线 UUID - 用户名：\(username), UUID：\(uuidString)")
        // 从小写字符串重新创建 UUID
        return uuidString.lowercased()
    }
    
    static let names = ["alex", "ari", "efe", "kai", "makena", "noor", "steve", "sunny", "zuri"]
    
    /// 根据uuid字符串返回唯一名字数组的下标（0~8）
    static func nameIndex(for uuid: String) -> Int? {
        let cleanUUID = uuid.replacingOccurrences(of: "-", with: "")
        guard cleanUUID.count >= 32 else { return nil }
        let iStr = String(cleanUUID.prefix(16))
        let uStr = String(cleanUUID.dropFirst(16).prefix(16))
        guard let i = UInt64(iStr, radix: 16),
              let u = UInt64(uStr, radix: 16) else { return nil }
        let f = i ^ u
        let mixedBits = (f ^ (f >> 32)) & 0xffffffff
        let I = Int32(bitPattern: UInt32(truncatingIfNeeded: mixedBits))
        let index = (Int(I) % names.count + names.count) % names.count
        return index
    }
    
    /// 根据uuid获取头像名
    static func avatarName(for uuid: String) -> String? {
        guard let idx = nameIndex(for: uuid) else { return nil }
        return names[idx]
    }
}




