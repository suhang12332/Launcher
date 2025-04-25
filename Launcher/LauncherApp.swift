//
//  LauncherApp.swift
//  Launcher
//
//  Created by su on 2025/4/24.
//

import SwiftUI

@main
struct LauncherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowToolbarStyle(.unified(showsTitle: false)) // not the same as using .windowStyle(.hiddenTitleBar)
            .windowStyle(.titleBar)
            .windowResizability(.contentMinSize)
    }
}
