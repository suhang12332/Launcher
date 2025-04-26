import SwiftUI

struct ContentView: View {
    @State private var selectedItem: SidebarItem?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showingInspector: Bool = false
    @State private var showingAddPlayer = false
    @State private var newPlayerName = ""
    @State private var error: PlayerError?
    @State private var showError = false
    @State private var isPlayerNameValid = false
    @StateObject private var gameState = GameState.shared
    @StateObject private var playerService = PlayerService.shared
    
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
                Button(action: {
                    showingAddPlayer = true
                }) {
                    Image(systemName: "person.badge.plus")
                }
                .help("添加玩家")
                .alert("添加玩家", isPresented: $showingAddPlayer) {
                    TextField("玩家名称", text: $newPlayerName)
                        .onChange(of: newPlayerName) { newValue in
                            checkPlayerName(newValue)
                        }
                    Button("取消", role: .cancel) {
                        newPlayerName = ""
                        isPlayerNameValid = false
                    }
                    Button("添加") {
                        Task {
                            await PlayerUtils.addPlayer(
                                name: newPlayerName,
                                playerService: playerService,
                                onSuccess: {
                                    newPlayerName = ""
                                    isPlayerNameValid = false
                                },
                                onError: { error in
                                    self.error = error
                                    showError = true
                                }
                            )
                        }
                    }
                    .disabled(!isPlayerNameValid)
                } message: {
                    if !isPlayerNameValid && !newPlayerName.isEmpty {
                        Text("玩家名已存在")
                            .foregroundColor(.red)
                    } else {
                        Text("请输入玩家名称")
                    }
                }
                .alert("错误", isPresented: $showError, presenting: error) { _ in
                    Button("确定", role: .cancel) {}
                } message: { error in
                    Text(error.localizedDescription)
                }
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
    
    private func checkPlayerName(_ name: String) {
        isPlayerNameValid = !playerService.players.contains { $0.name == name } && !name.isEmpty
    }
} 
