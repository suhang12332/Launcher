import SwiftUI

struct ContentView: View {
    @State private var selectedItem: SidebarItem?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showingInspector: Bool = true
    @StateObject private var gameState = GameState.shared
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(selection: $selectedItem)
                .frame(width: 140)
                .navigationSplitViewColumnWidth(140)
        } content: {
            ToolbarContentView(title: "Content") {
                if let selectedItem {
                    switch selectedItem {
                    case .mods:
                        ModsContent()
                    case .dataPacks:
                        ModPacksContent()
                    case .shaders:
                        ShadersContent()
                    case .resourcePacks:
                        ResourcePacksContent()
                    case .modPacks:
                        ModPacksContent()
                    }
                }
            } toolbarContent: {
                Button(action: {}) {
                    Image(systemName: "person.badge.plus")
                }
                .help("添加用户")
                Spacer()
                Button(action: {}) {
                    Image(systemName: "person.badge.plus")
                }
                .help("添加用户")
            }
            .navigationSplitViewColumnWidth(230)
        } detail: {
            ToolbarContentView(title: "游戏版本", showDivider: false) {
                GameVersionView()
            } toolbarContent: {
                Text("游戏版本")
                    .font(.headline)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "gear")
                }
                .help("设置")
            }
        }.inspector(isPresented: $showingInspector) {
            ToolbarContentView(title: "游戏版本", showDivider: false) {
                GameVersionView()
            } toolbarContent: {
                Text("游戏版本")
                    .font(.headline)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "gear")
                }
                .help("设置")
                Spacer()
                Button(action: {
                    withAnimation {
                        showingInspector.toggle()
                    }
                }) {
                    Image(systemName: showingInspector ? "sidebar.right" : "sidebar.left")
                }
                .help(showingInspector ? "隐藏检查器" : "显示检查器")
            }
        }
    }
} 
