import SwiftUI

// MARK: - Main View
struct ModrinthDetailView: View {
    // MARK: - Properties
    let query: String
    @Binding var currentPage: Int
    @Binding var totalItems: Int
    @Binding var itemsPerPage: Int
    @Binding var sortIndex: String
    @Binding var selectedVersions: [String]
    @Binding var selectedCategories: [String]
    @Binding var selectedFeatures: [String]
    @Binding var selectedResolutions: [String]
    @Binding var selectedPerformanceImpact: [String]
    @Binding var selectedProjectId: String?
    
    @StateObject private var viewModel = ModrinthSearchViewModel()
    @State private var hasLoaded = false
    
    // MARK: - Body
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.error {
                errorView(error)
            } else if viewModel.results.isEmpty {
                emptyView
            } else {
                resultList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            if !hasLoaded {
                hasLoaded = true
                await performSearch()
            }
        }
        .onChange(of: currentPage) { _, _ in
            Task { await performSearch() }
        }
        .onChange(of: query) { _, _ in
            currentPage = 1
            Task { await performSearch() }
        }
        .onChange(of: viewModel.totalHits) { _, newValue in
            totalItems = newValue
        }
        .onChange(of: sortIndex) { _, _ in
            Task { await performSearch() }
        }
        .onChange(of: selectedVersions) { _, _ in
            currentPage = 1
            Task { await performSearch() }
        }
        .onChange(of: selectedCategories) { _, _ in
            currentPage = 1
            Task { await performSearch() }
        }
        .onChange(of: selectedFeatures) { _, _ in
            currentPage = 1
            Task { await performSearch() }
        }
        .onChange(of: selectedResolutions) { _, _ in
            currentPage = 1
            Task { await performSearch() }
        }
        .onChange(of: selectedPerformanceImpact) { _, _ in
            currentPage = 1
            Task { await performSearch() }
        }
        .onChange(of: viewModel.pageSize) { _, newValue in
            itemsPerPage = newValue
        }
        .refreshable {
            await performSearch()
        }
    }
    
    // MARK: - Private Methods
    private func performSearch() async {
        await viewModel.search(
            projectType: query,
            page: currentPage,
            sortIndex: sortIndex,
            versions: selectedVersions,
            categories: selectedCategories,
            features: selectedFeatures,
            resolutions: selectedResolutions,
            performanceImpact: selectedPerformanceImpact
        )
    }
    
    // MARK: - View Components
    private var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
                .controlSize(.regular)
                .frame(width: 20, height: 20)
            Text(
                String(
                    format: NSLocalizedString(
                        "game.version.loading",
                        comment: "正在加载 %@ 版本"
                    ),
                    NSLocalizedString(query, comment: "游戏版本")
                )
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(_ error: Error) -> some View {
        ContentUnavailableView {
            Label(
                String(
                    format: NSLocalizedString(
                        "modrinth.search.error",
                        comment: "搜索 %@ 时出错"
                    ),
                    NSLocalizedString(query, comment: "游戏版本")
                ),
                systemImage: "xmark.icloud"
            )
        } description: {
            Text(localizedErrorMessage(error))
        }
    }
    
    private var emptyView: some View {
        ContentUnavailableView {
            Label(
                NSLocalizedString("common.error", comment: "错误"),
                systemImage: "tray"
            )
        } description: {
            Text(NSLocalizedString("No results found.", comment: "未找到结果"))
        }
    }
    
    private var resultList: some View {
        List {
            ForEach(viewModel.results, id: \.projectId) { mod in
                ModrinthProjectCardView(mod: mod)
                    .padding(.vertical, ModrinthConstants.UI.verticalPadding)
                    .listRowInsets(
                        EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
                    )
                    .onTapGesture {
                        selectedProjectId = mod.projectId
                    }
            }
        }
        .listStyle(.plain)
    }
}

