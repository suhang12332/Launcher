import SwiftUI

struct ContentView: View {
    @State private var selectedItem: SidebarItem = .mods
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showingInspector: Bool = false
    @State private var showingAddPlayer = false
    @State private var searchQuery = ""
    @StateObject private var playerService = PlayerService.shared
    // 分页相关
    @State private var currentPage: Int = 1
    @State private var totalItems: Int = 0
    @State private var itemsPerPage: Int = 20
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(selection: $selectedItem)
                .navigationSplitViewColumnWidth(180)
        } content: {
            ToolbarContentView(title: NSLocalizedString("sidebar.resources", comment: "")) {
//                if let selectedItem {
//                    switch selectedItem {
//                    case .mods:
//                        ModsContent()
//                    case .dataPacks:
//                        ModPacksContent()
//                    case .shaders:
//                        ShadersContent()
//                    case .resourcePacks:
//                        ResourcePacksContent()
//                    case .modPacks:
//                        ModPacksContent()
//                    }
//                }
            } toolbarContent: {
                ContentToolbar(showingAddPlayer: $showingAddPlayer)
            }
            .navigationSplitViewColumnWidth(min: 230, ideal: 230, max: 350)
        } detail: {
            ToolbarContentView(title: NSLocalizedString("game.version.title", comment: ""), showDivider: false) {
                ModrinthDetailView(
                    query: selectedItem.name,
                    currentPage: $currentPage,
                    totalItems: $totalItems,
                    itemsPerPage: $itemsPerPage
                )
            } toolbarContent: {
                DetailToolbar(
                    totalItems: totalItems,
                    itemsPerPage: itemsPerPage,
                    currentPage: $currentPage
                )
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

