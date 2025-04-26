import Foundation
import OSLog

class MinecraftVersionService {
    private let logger = Logger(subsystem: "com.launcher", category: "MinecraftVersionService")
    
    func fetchReleaseVersions() async throws -> [MinecraftVersion] {
        logger.debug("开始获取 Minecraft 版本列表")
        
        do {
            logger.debug("正在从 Mojang 服务器获取版本清单")
            let (data, response) = try await URLSession.shared.data(from: URLConfig.API.Minecraft.versionList)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("无效的 HTTP 响应")
                throw URLError(.badServerResponse)
            }
            
            guard httpResponse.statusCode == 200 else {
                logger.error("获取版本清单失败 - HTTP 状态码: \(httpResponse.statusCode)")
                throw URLError(.badServerResponse)
            }
            
            logger.debug("成功获取版本清单，开始解析数据")
            let manifest = try JSONDecoder().decode(VersionManifest.self, from: data)
            
            let releaseVersions = manifest.versions.filter { $0.type == "release" }
            logger.info("成功获取 \(releaseVersions.count) 个正式版本")
            
            return releaseVersions
        } catch let error as DecodingError {
            logger.error("解析版本清单失败: \(error.localizedDescription)")
            throw error
        } catch let error as URLError {
            logger.error("网络请求失败: \(error.localizedDescription)")
            throw error
        } catch {
            logger.error("获取版本清单时发生未知错误: \(error.localizedDescription)")
            throw error
        }
    }
} 