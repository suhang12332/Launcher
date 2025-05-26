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
    @State private var sortIndex: String = "relevance"
    @State private var selectedVersions: [String] = []
    @State private var selectedLicenses: [String] = []
    @State private var selectedCategories: [String] = []
    @State private var selectedFeatures: [String] = []
    @State private var selectedResolutions: [String] = []
    @State private var selectedPerformanceImpact: [String] = []
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(selection: $selectedItem)
                .navigationSplitViewColumnWidth(180)
        } content: {
            ToolbarContentView(title: NSLocalizedString("sidebar.resources", comment: "")) {
                ModrinthContentView(
                    selectedVersion: $selectedVersions,
                    selectedLicense: $selectedLicenses,
                    selectedItem: $selectedItem,
                    selectedCategories: $selectedCategories,
                    selectedFeatures: $selectedFeatures,
                    selectedResolutions: $selectedResolutions,
                    selectedPerformanceImpact: $selectedPerformanceImpact
                )
            } toolbarContent: {
                ContentToolbar(showingAddPlayer: $showingAddPlayer)
            }
            .navigationSplitViewColumnWidth(min: 240, ideal: 240, max: 350)
        } detail: {

            ToolbarContentView(title: NSLocalizedString("game.version.title", comment: ""), showDivider: false) {
                ModrinthDetailView(
                    query: selectedItem.name,
                    currentPage: $currentPage,
                    totalItems: $totalItems,
                    itemsPerPage: $itemsPerPage,
                    sortIndex: $sortIndex
                )
            } toolbarContent: {
                DetailToolbar(
                    totalItems: totalItems,
                    itemsPerPage: itemsPerPage,
                    currentPage: $currentPage,
                    sortIndex: $sortIndex
                )
            }
        }.inspector(isPresented: $showingInspector) {
            ToolbarContentView(title: NSLocalizedString("game.version.title", comment: ""), showDivider: false) {
//                PlayerProfileView(player: playerService.selectedPlayer)
            } toolbarContent: {
                InspectorToolbar(showingInspector: $showingInspector)
            }
        }.frame(minWidth: 600)
        .onChange(of: selectedItem) { _, _ in
            // 重置所有状态
            sortIndex = "relevance"
            currentPage = 1
            totalItems = 0
            selectedVersions = []
            selectedLicenses = []
            selectedCategories = []
            selectedFeatures = []
            selectedResolutions = []
            searchQuery = ""
        }
    }
}

#Preview{
    ContentView()
}
