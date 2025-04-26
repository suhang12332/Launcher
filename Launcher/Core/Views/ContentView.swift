import SwiftUI

struct ContentView: View {
    @State private var selectedItem: SidebarItem?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showingInspector: Bool = false
    @State private var showingAddPlayer = false
    @StateObject private var gameState = GameState.shared
    @StateObject private var playerService = PlayerService.shared
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(selection: $selectedItem)
                .frame(width: 140)
                .navigationSplitViewColumnWidth(140)
        } content: {
            ToolbarContentView(title: NSLocalizedString("sidebar.resources", comment: "")) {
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
                ContentToolbar(showingAddPlayer: $showingAddPlayer)
            }
            .navigationSplitViewColumnWidth(230)
        } detail: {
            ToolbarContentView(title: NSLocalizedString("game.version.title", comment: ""), showDivider: false) {
                GameVersionView()
            } toolbarContent: {
                DetailToolbar()
            }
        }.inspector(isPresented: $showingInspector) {
            ToolbarContentView(title: NSLocalizedString("game.version.title", comment: ""), showDivider: false) {
                PlayerProfileView(player: playerService.selectedPlayer)
            } toolbarContent: {
                InspectorToolbar(showingInspector: $showingInspector)
            }
        }
    }
} 
