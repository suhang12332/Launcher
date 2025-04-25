//
//  LauncherApp.swift
//  Launcher
//
//  Created by su on 2025/4/24.
//

import SwiftUI

@main
struct LauncherApp: App {
    @StateObject private var gameState = GameState.shared
    
    init() {
        Task {
            await GameState.shared.loadVersions()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if gameState.isLoading {
                LoadingView()
            } else {
                ContentView()
            }
        }.windowToolbarStyle(.unified(showsTitle: false)) // not the same as using .windowStyle(.hiddenTitleBar)
            .windowStyle(.titleBar)
            .windowResizability(.contentMinSize)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .controlSize(.large)
            Text("正在加载游戏版本...")
                .padding(.top)
        }
    }
}
