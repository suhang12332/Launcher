import Foundation
import SwiftUI

// 用于包装 Data 的类
private final class DataWrapper {
    let data: Data
    init(data: Data) { self.data = data }
}

enum ResourceService {
    // 缓存管理
    enum Cache {
        private static let cache = NSCache<NSString, DataWrapper>()
        
        static func getImageData(for key: String) -> Data? {
            return cache.object(forKey: key as NSString)?.data
        }
        
        static func setImageData(_ data: Data, for key: String) {
            cache.setObject(DataWrapper(data: data), forKey: key as NSString)
        }
        
        static func clearCache() {
            cache.removeAllObjects()
        }
    }
}

enum ResourceError: Error {
    case invalidImageData
    case downloadFailed
    case cacheError
} 
