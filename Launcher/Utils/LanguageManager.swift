import Foundation
import SwiftUI

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var currentLanguage: String
    private let userDefaults = UserDefaults.standard
    private let languageKey = "selectedLanguage"

    private init() {
        // 先从 UserDefaults 读取语言设置
        if let cachedLanguage = userDefaults.string(forKey: languageKey) {
            self.currentLanguage = cachedLanguage
        } else {
            // 如果没有缓存的语言设置，则使用系统语言
            let systemLanguage =
                Locale.current.language.languageCode?.identifier ?? "en"
            let systemRegion = Locale.current.region?.identifier ?? ""

            // 根据系统语言和地区设置默认语言
            switch (systemLanguage, systemRegion) {
            case ("zh", "CN"):
                self.currentLanguage = "zh-Hans"
            case ("zh", "TW"), ("zh", "HK"):
                self.currentLanguage = "zh-Hant"
            case ("zh", _):  // 处理其他中文变体
                self.currentLanguage = "zh-Hans"
            default:
                self.currentLanguage = "en"
            }

            // 保存默认语言设置
            userDefaults.set(self.currentLanguage, forKey: languageKey)
        }
    }

    func setLanguage(_ language: String) {
        // 确保语言代码格式正确
        let normalizedLanguage = normalizeLanguageCode(language)
        userDefaults.set(normalizedLanguage, forKey: languageKey)
        currentLanguage = normalizedLanguage
    }

    func getCurrentLanguage() -> String {
        return currentLanguage
    }

    private func normalizeLanguageCode(_ code: String) -> String {
        switch code.lowercased() {
        case "zh-cn", "zh_hans", "zh-hans":
            return "zh-Hans"
        case "zh-tw", "zh-hk", "zh_hant", "zh-hant":
            return "zh-Hant"
        case "en", "en-us", "en_gb":
            return "en"
        default:
            return code
        }
    }
}
// 全局错误本地化工具
func localizedErrorMessage(_ error: Error) -> String {
    let nsError = error as NSError
    if nsError.domain == NSURLErrorDomain {
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet:
            return NSLocalizedString("error.network.offline", comment: "网络未连接")
        case NSURLErrorTimedOut:
            return NSLocalizedString("error.network.timeout", comment: "网络连接超时")
        default:
            return NSLocalizedString("error.unknown", comment: "未知错误")
        }
    }
    return NSLocalizedString("error.unknown", comment: "未知错误")
}
