import Foundation

enum URLConfig {
    // API 端点
    enum API {
        // Minecraft API
        enum Minecraft {
            static let baseURL = URL(string: "https://launchermeta.mojang.com")!

            static let versionList = baseURL.appendingPathComponent(
                "mc/game/version_manifest.json"
            )
        }

        // Modrinth API
        enum Modrinth {
            static let baseURL = URL(string: "https://api.modrinth.com/v2")!

            // 项目相关
            static let projects = baseURL.appendingPathComponent("project")
            static func project(id: String) -> URL {
                baseURL.appendingPathComponent("project/\(id)")
            }

            // 版本相关
            static let versions = baseURL.appendingPathComponent("version")
            static func version(id: String) -> URL {
                baseURL.appendingPathComponent("version/\(id)")
            }

            // 搜索相关
            static let search = baseURL.appendingPathComponent("search")

            // 用户相关
            static let users = baseURL.appendingPathComponent("user")
            static func user(id: String) -> URL {
                baseURL.appendingPathComponent("user/\(id)")
            }

            // 标签相关
            enum Tag {
                static let baseURL = Modrinth.baseURL.appendingPathComponent(
                    "tag"
                )

                // 游戏版本
                static let gameVersion = baseURL.appendingPathComponent(
                    "game_version"
                )

                // 加载器
                static let loader = baseURL.appendingPathComponent("loader")

                // 分类
                static let category = baseURL.appendingPathComponent("category")

                // 许可证
                static let license = baseURL.appendingPathComponent("license")
            }
        }

        // 其他第三方 API
        enum ThirdParty {
            static let baseURL = URL(string: "https://api.example.com")!

            static let analytics = baseURL.appendingPathComponent("analytics")
            static let updateCheck = baseURL.appendingPathComponent("update")
        }
    }

    // 资源文件
    enum Resources {
        // Minecraft 资源
        enum Minecraft {
            static let baseURL = URL(string: "https://api.mojang.com")!

            static func playerAvatar(name: String) -> URL {
                baseURL.appendingPathComponent(
                    "users/profiles/minecraft/\(name)"
                )
            }

            static func playerSkin(name: String) -> URL {
                baseURL.appendingPathComponent(
                    "users/profiles/minecraft/\(name)"
                )
            }
        }

        // Modrinth 资源
        enum Modrinth {
            static let baseURL = URL(string: "https://cdn.modrinth.com")!

            static func projectIcon(id: String) -> URL {
                baseURL.appendingPathComponent("data/\(id)/icon.png")
            }

            static func versionFile(id: String) -> URL {
                baseURL.appendingPathComponent("data/\(id)/file")
            }
        }
    }
}
