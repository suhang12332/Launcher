import SwiftUI

struct GameVersionView: View {
    @StateObject private var gameState = GameState.shared
    
    var body: some View {
        VStack {
            if gameState.isLoading {
                ProgressView("加载中...")
            } else if let error = gameState.error {
                Text("错误: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else {
                MinecraftVersionsView(versions: gameState.versions)
            }
        }
    }
} 