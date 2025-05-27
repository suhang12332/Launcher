import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameStorageManager: GameStorageManager
    
    @State private var selectedItem: SidebarSelection? = .resource(.mods)
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
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
            if let selection = selectedItem {
                switch selection {
                case .game(let gameId):
                    VStack {
                        Text("Selected Game ID: \(gameId)")
                        // TODO: Integrate your actual Game Detail View here
                    }
                    .navigationTitle(NSLocalizedString("game.details", comment: ""))
                case .resource(let item):
                    ToolbarContentView(title: NSLocalizedString("game.version.title", comment: ""), showDivider: false) {
                        ModrinthDetailView(
                            query: item.name,
                            currentPage: $currentPage,
                            totalItems: $totalItems,
                            itemsPerPage: $itemsPerPage,
                            sortIndex: $sortIndex,
                            selectedVersions: $selectedVersions,
                            selectedCategories: $selectedCategories,
                            selectedFeatures: $selectedFeatures,
                            selectedResolutions: $selectedResolutions,
                            selectedPerformanceImpact: $selectedPerformanceImpact
                        )
                    } toolbarContent: {
                        DetailToolbar(
                            totalItems: totalItems,
                            itemsPerPage: itemsPerPage,
                            currentPage: $currentPage,
                            sortIndex: $sortIndex
                        )
                    }
                    .navigationTitle(item.localizedName)
                }
            } else {
                Text("Select an item from the sidebar")
            }
        } detail: {
            if case .resource(let item) = selectedItem {
                ToolbarContentView(title: NSLocalizedString("sidebar.resources", comment: "")) {
                    ModrinthContentView(
                        selectedVersion: $selectedVersions,
                        selectedLicense: $selectedLicenses,
                        selectedItem: item,
                        selectedCategories: $selectedCategories,
                        selectedFeatures: $selectedFeatures,
                        selectedResolutions: $selectedResolutions,
                        selectedPerformanceImpact: $selectedPerformanceImpact
                    )
                } toolbarContent: {
                    ContentToolbar(showingAddPlayer: $showingAddPlayer)
                }.navigationSplitViewColumnWidth(min: 0, ideal: 260, max: 260)
            } else {
                Text("Select a resource item or a game for details")
            }
        }
        .onChange(of: selectedItem) { _, newValue in
            if case .resource(_) = newValue {
                sortIndex = "relevance"
                currentPage = 1
                totalItems = 0
                selectedVersions = []
                selectedLicenses = []
                selectedCategories = []
                selectedFeatures = []
                selectedResolutions = []
                selectedPerformanceImpact = []
                searchQuery = ""
            }
        }
    }
}

#Preview{
    ContentView()
}
