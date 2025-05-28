//
//  LauncherApp.swift
//  Launcher
//
//  Created by su on 2025/4/24.
//

import SwiftUI

@main
struct LauncherApp: App {

    @StateObject private var languageManager = LanguageManager.shared
    // Create an instance of the GameRepository
    @StateObject private var gameRepository = GameRepository()

    init() {
        let savedLanguage =
            UserDefaults.standard.string(forKey: "selectedLanguage")
            ?? "zh-Hans"
        Bundle.setLanguage(savedLanguage)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Attach the GameRepository to the environment
                .environmentObject(gameRepository)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .windowResizability(.contentMinSize)
        // 设置(左上角)
        Settings {
            SettingsView()
        }
        // 菜单
        .commands {
            CommandMenu("Task") {
                Button("Add new Task") {

                }
                .keyboardShortcut(
                    KeyEquivalent("r"),
                    modifiers: /*@START_MENU_TOKEN@*/
                        .command /*@END_MENU_TOKEN@*/
                )
            }

            CommandGroup(after: .newItem) {
                Button("Add new Group") {

                }
            }
        }
        // 右上角的状态栏(可以显示图标的)
        MenuBarExtra("Menu") {
            Button("Do something amazing") {

            }
        }

    }

}

// 扩展 Bundle 以支持动态切换语言
extension Bundle {
    static func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, AnyLanguageBundle.self)
        }

        objc_setAssociatedObject(
            Bundle.main,
            &bundleKey,
            language,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
}

var bundleKey: UInt8 = 0

class AnyLanguageBundle: Bundle, @unchecked Sendable {
    override func localizedString(
        forKey key: String,
        value: String?,
        table tableName: String?
    ) -> String {
        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
            let bundle = Bundle.main.path(forResource: path, ofType: "lproj")
                .flatMap(Bundle.init(path:))
        else {
            return super.localizedString(
                forKey: key,
                value: value,
                table: tableName
            )
        }

        return bundle.localizedString(
            forKey: key,
            value: value,
            table: tableName
        )
    }
}
