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
    @StateObject private var languageManager = LanguageManager.shared
    
    init() {
        // 设置语言
        if let language = UserDefaults.standard.string(forKey: "selectedLanguage") {
            Bundle.setLanguage(language)
        }
        
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
        
        Settings {
            SettingsView()
        }
        
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

// 扩展 Bundle 以支持动态切换语言
extension Bundle {
    static func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, AnyLanguageBundle.self)
        }
        
        objc_setAssociatedObject(Bundle.main, &bundleKey, language, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

var bundleKey: UInt8 = 0

class AnyLanguageBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
              let bundle = Bundle.main.path(forResource: path, ofType: "lproj").flatMap(Bundle.init(path:)) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}



