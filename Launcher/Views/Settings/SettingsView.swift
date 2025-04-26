import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage = "zh-Hans"
    @StateObject private var languageManager = LanguageManager.shared
    @State private var showingRestartAlert = false
    
    private let languages = [
        ("zh-Hans", "简体中文"),
        ("zh-Hant", "繁體中文"),
        ("en", "English")
    ]
    
    var body: some View {
        TabView {
            // General Settings
            Form {
                Section {
                    Picker(NSLocalizedString("settings.language", comment: ""), selection: $selectedLanguage) {
                        ForEach(languages, id: \.0) { language in
                            Text(NSLocalizedString("settings.language.\(language.0)", comment: ""))
                                .tag(language.0)
                        }
                    }
                    .onChange(of: selectedLanguage) { _, newValue in
                        if newValue != languageManager.getCurrentLanguage() {
                            showingRestartAlert = true
                        }
                    }
                } header: {
                    Text(NSLocalizedString("settings.general", comment: ""))
                }
            }
            .tabItem {
                Label(NSLocalizedString("settings.general", comment: ""), systemImage: "gearshape.fill")
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
                            Text(NSLocalizedString("app.name", comment: ""))
                                .font(.headline)
                            Text("Version 1.0.0")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .tabItem {
                Label(NSLocalizedString("settings.about", comment: ""), systemImage: "info.circle.fill")
            }
        }
        .frame(width: 500, height: 300)
        .padding()
        .alert(NSLocalizedString("settings.restart.title", comment: ""), isPresented: $showingRestartAlert) {
            Button(NSLocalizedString("settings.restart.cancel", comment: "")) {
                selectedLanguage = languageManager.getCurrentLanguage()
            }
            Button(NSLocalizedString("settings.restart.confirm", comment: "")) {
                languageManager.setLanguage(selectedLanguage)
                restartApp()
            }
        } message: {
            if languageManager.getCurrentLanguage() == "zh-Hans" || languageManager.getCurrentLanguage() == "zh-Hant" {
                Text(NSLocalizedString("settings.chinese.message", comment: ""))
            } else {
                Text(NSLocalizedString("settings.restart.message", comment: ""))
            }
        }
    }
    
    private func restartApp() {
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("MacOS")
            .appendingPathComponent(Bundle.main.executableURL!.lastPathComponent)
        
        let process = Process()
        process.executableURL = url
        process.arguments = CommandLine.arguments
        
        try? process.run()
        NSApplication.shared.terminate(nil)
    }
} 