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
            ContentView()
            
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .windowResizability(.contentMinSize)
        // 是否保留上次关闭时的状态
        //.restorationBehavior(.disabled)
        
        //        WindowGroup("Special window") {
        //            Text("special window")
        //                .frame(minWidth: 200, idealWidth: 300, minHeight: 200).toolbar(removing: .title)
        //                .toolbarBackground(.hidden, for: .windowToolbar).containerBackground(.bar, for: .window)
        //        }.windowResizability(.contentSize).windowStyle(.plain)
        //        // 菜单栏
        //        .commands {
        //            CommandMenu("Task") {
        //                Button("Add new Task") {
        //
        //                }
        //                .keyboardShortcut(KeyEquivalent("r"), modifiers: /*@START_MENU_TOKEN@*/.command/*@END_MENU_TOKEN@*/)
        //            }
        //
        //            CommandGroup(after: .newItem) {
        //                Button("Add new Group") {
        //
        //                }
        //            }
        //        }
        //        .defaultPosition(.leading)
        //        // 设置
        //        Settings {
        //            Text("Setting")
        //                .frame(maxWidth: .infinity, maxHeight: .infinity)
        //        }
        //
        //        // 任务栏
        //        MenuBarExtra("Menu") {
        //            Button("Do something amazing") {
        //
        //            }
        //        }
        
    }
    
}



