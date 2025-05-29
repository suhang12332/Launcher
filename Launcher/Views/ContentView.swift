import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameRepository: GameRepository

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
    @State private var selectedProjectId: String?
    @State private var selectedTab = 0

    // State variable to hold the loaded project detail
    @State private var loadedProjectDetail: ModrinthProjectDetail? = nil

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
                    .navigationTitle(
                        NSLocalizedString("game.details", comment: "游戏详情")
                    )
                case .resource(let item):
                    if let projectId = selectedProjectId {
                        ToolbarContentView(
                            title: NSLocalizedString(
                                "game.version.title",
                                comment: "游戏版本"
                            ),
                            showDivider: false
                        ) {
                            // Pass the bound loadedProjectDetail to ModrinthProjectDetailView
                            ModrinthProjectDetailView(
                                projectId: projectId,
                                selectedTab: $selectedTab,
                                projectDetail: $loadedProjectDetail // Pass the binding here
                            )
                        } toolbarContent: {
                            // Display project icon and title when loadedProjectDetail is not nil
                            
                            if let project = loadedProjectDetail {
                                HStack(spacing: 8) {
                                    if let iconUrl = project.iconUrl, let url = URL(string: iconUrl) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                Color.gray.opacity(0.2)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            case .failure:
                                                Color.gray.opacity(0.2)
                                            @unknown default:
                                                Color.gray.opacity(0.2)
                                            }
                                        }
                                        .frame(width: 24, height: 24) // Adjust size for toolbar
                                        .cornerRadius(4)
                                        .clipped()
                                    } else {
                                        Image(systemName: "photo") // Placeholder icon
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 24)
                                    }
                                    Text(project.title)
                                        .font(.headline) // Adjust font for toolbar
                                }
                            } else {
                                // Show a placeholder or loading indicator while loading
                                Text("Loading...")
                            }

                            Spacer()
                            Button(action: { selectedProjectId = nil }) {
                                Label(
                                    NSLocalizedString("回到主页", comment: "回到主页"),
                                    systemImage: "house"
                                )
                            }
                            .help(NSLocalizedString("back.home", comment: "回到主页"))
                            Picker("视图模式", selection: $selectedTab) {
                                Label("详情", systemImage: "doc.text").tag(0)
                                Label("下载", systemImage: "arrow.down.square").tag(1)
                                Label("画廊", systemImage: "photo.on.rectangle").tag(2)
                            }
                            .pickerStyle(.segmented)
                            .background(.clear)
                            Spacer()
                            Button(action: { showingAddPlayer = true }) {
                                Label(
                                    NSLocalizedString("回到主页", comment: "回到主页"),
                                    systemImage: "translate"
                                )
                            }
                            .help(NSLocalizedString("back.home", comment: "回到主页"))
                        }
                        .navigationTitle(
                            loadedProjectDetail?.title ?? NSLocalizedString("project.details", comment: "项目详情") // Use project title if available
                        )
                    } else {
                        ToolbarContentView(
                            title: NSLocalizedString(
                                "game.version.title",
                                comment: "游戏版本"
                            ),
                            showDivider: false
                        ) {
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
                                selectedPerformanceImpact: $selectedPerformanceImpact,
                                selectedProjectId: $selectedProjectId
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
                }
            } else {
                Text("Select an item from the sidebar")
            }
        } detail: {
            if case .resource(let item) = selectedItem {
                ToolbarContentView(
                    title: NSLocalizedString(
                        "sidebar.resources",
                        comment: "资源管理"
                    )
                ) {
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
                selectedProjectId = nil
                searchQuery = ""
                // Reset loaded project detail when selected item changes
                loadedProjectDetail = nil
            }
        }
        .onChange(of: selectedProjectId) { _, _ in
             // Reset loaded project detail when selected project changes
             loadedProjectDetail = nil
        }
    }
}

#Preview {
    ContentView()
}
