import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage = "zh-Hans"
    @StateObject private var languageManager = LanguageManager.shared
    @State private var showingRestartAlert = false

    private let languages = [
        ("zh-Hans", "简体中文"),
        ("zh-Hant", "繁體中文"),
        ("en", "English"),
    ]

    var body: some View {
        TabView {
            // General Settings
            Form {
                Section {
                    Picker(
                        NSLocalizedString("settings.language", comment: "语言设置"),
                        selection: $selectedLanguage
                    ) {
                        ForEach(languages, id: \.0) { language in
                            Text(
                                NSLocalizedString(
                                    "settings.language.\(language.0)",
                                    comment: "语言选项：\(language.1)"
                                )
                            )
                            .tag(language.0)
                        }
                    }
                    .onChange(of: selectedLanguage) { _, newValue in
                        if newValue != languageManager.getCurrentLanguage() {
                            showingRestartAlert = true
                        }
                    }
                } header: {
                    Text(NSLocalizedString("settings.general", comment: "通用设置"))
                }
            }
            .tabItem {
                Label(
                    NSLocalizedString("settings.general", comment: "通用设置"),
                    systemImage: "gearshape"
                )
            }

            // About
            Form {
                Section {
                    HStack {
                        Image("AppIcon")
                            .resizable()
                            .frame(width: 64, height: 64)
                            .cornerRadius(12)

                        VStack(alignment: .leading) {
                            Text(NSLocalizedString("app.name", comment: "应用名称"))
                                .font(.headline)
                            Text("Version 1.0.0")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .tabItem {
                Label(
                    NSLocalizedString("settings.about", comment: "关于"),
                    systemImage: "info.circle"
                )
            }
        }
        .frame(width: 500, height: 300)
        .padding()
        .alert(
            NSLocalizedString("settings.restart.title", comment: "需要重启"),
            isPresented: $showingRestartAlert
        ) {
            Button(NSLocalizedString("settings.restart.cancel", comment: "取消"))
            {
                selectedLanguage = languageManager.getCurrentLanguage()
            }
            Button(NSLocalizedString("settings.restart.confirm", comment: "确认"))
            {
                languageManager.setLanguage(selectedLanguage)
                restartApp()
            }
        } message: {
            Text(
                NSLocalizedString(
                    "settings.restart.message",
                    comment: "更改语言需要重启应用才能生效"
                )
            )
        }
    }

    private func restartApp() {
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("MacOS")
            .appendingPathComponent(
                Bundle.main.executableURL!.lastPathComponent
            )

        let process = Process()
        process.executableURL = url
        process.arguments = CommandLine.arguments

        try? process.run()
        NSApplication.shared.terminate(nil)
    }
}
