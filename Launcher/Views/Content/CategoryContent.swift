//  CategoryContent.swift
//  Launcher
//
//  Created by su on 2025/5/8.
//

import SwiftUI

// MARK: - Constants
private enum Constants {
    static let maxHeight: CGFloat = 235
    static let verticalPadding: CGFloat = 4
    static let topPadding: CGFloat = 4
    static let cacheTimeout: TimeInterval = 300
    static let placeholderCount: Int = 5
    static let headerBottomPadding: CGFloat = 4
}

private enum ProjectType {
    static let modpack = "modpack"
    static let mod = "mod"
    static let datapack = "datapack"
    static let resourcepack = "resourcepack"
    static let shader = "shader"
}

private enum CategoryHeader {
    static let categories = "categories"
    static let features = "features"
    static let resolutions = "resolutions"
    static let performanceImpact = "performance impact"
    static let environment = "environment"
}

private enum FilterTitle {
    static let category = "filter.category"
    static let environment = "filter.environment"
    static let behavior = "filter.behavior"
    static let resolutions = "filter.resolutions"
    static let performance = "filter.performance"
    static let version = "filter.version"
}

// MARK: - ViewModel
@MainActor
final class CategoryContentViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var categories: [Category] = []
    @Published private(set) var features: [Category] = []
    @Published private(set) var resolutions: [Category] = []
    @Published private(set) var performanceImpacts: [Category] = []
    @Published private(set) var versions: [GameVersion] = []
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var error: Error?
    
    // MARK: - Private Properties
    private var lastFetchTime: Date?
    private let project: String
    private var loadTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(project: String) {
        self.project = project
    }
    
    deinit {
        loadTask?.cancel()
    }
    
    // MARK: - Public Methods
    func loadData() async {
        guard shouldFetchData else { return }
        
        loadTask = Task {
            await fetchData()
        }
    }
    
    func clearCache() {
        loadTask?.cancel()
        lastFetchTime = nil
        resetData()
    }
    
    // MARK: - Private Helpers
    private var shouldFetchData: Bool {
        guard let lastFetch = lastFetchTime else { return true }
        return Date().timeIntervalSince(lastFetch) >= Constants.cacheTimeout || categories.isEmpty
    }
    
    private func fetchData() async {
        isLoading = true
        error = nil
        
        do {
            async let categoriesTask = ModrinthService.fetchCategories()
            async let versionsTask = ModrinthService.fetchGameVersions()
            
            let (categoriesResult, versionsResult) = try await (categoriesTask, versionsTask)
            await processFetchedData(categories: categoriesResult, versions: versionsResult)
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    private func processFetchedData(categories: [Category], versions: [GameVersion]) async {
        let filteredVersions = versions.filter { $0.version_type == "release" }
        let projectType = project == ProjectType.datapack ? ProjectType.mod : project
        let filteredCategories = categories.filter { $0.project_type == projectType }
        
        await MainActor.run {
            self.versions = filteredVersions
            self.categories = filteredCategories.filter { $0.header == CategoryHeader.categories }
            self.features = filteredCategories.filter { $0.header == CategoryHeader.features }
            self.resolutions = filteredCategories.filter { $0.header == CategoryHeader.resolutions }
            self.performanceImpacts = filteredCategories.filter { $0.header == CategoryHeader.performanceImpact }
            self.lastFetchTime = Date()
        }
    }
    
    private func handleError(_ error: Error) {
        Logger.shared.error("加载数据错误: \(error)")
        Task { @MainActor in
            self.error = error
        }
    }
    
    private func resetData() {
        categories.removeAll()
        features.removeAll()
        resolutions.removeAll()
        performanceImpacts.removeAll()
        versions.removeAll()
    }
}

// MARK: - CategoryContent
struct CategoryContent: View {
    // MARK: - Properties
    let project: String
    @StateObject private var viewModel: CategoryContentViewModel
    
    @Binding var selectedCategories: [String]
    @Binding var selectedFeatures: [String]
    @Binding var selectedResolutions: [String]
    @Binding var selectedPerformanceImpact: [String]
    @Binding var selectedVersions: [String]
    
    // MARK: - Initialization
    init(
        project: String,
        selectedCategories: Binding<[String]>,
        selectedFeatures: Binding<[String]>,
        selectedResolutions: Binding<[String]>,
        selectedPerformanceImpact: Binding<[String]>,
        selectedVersions: Binding<[String]>
    ) {
        self.project = project
        self._selectedCategories = selectedCategories
        self._selectedFeatures = selectedFeatures
        self._selectedResolutions = selectedResolutions
        self._selectedPerformanceImpact = selectedPerformanceImpact
        self._selectedVersions = selectedVersions
        self._viewModel = StateObject(wrappedValue: CategoryContentViewModel(project: project))
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            gameVersionSection
            categorySection
            projectSpecificSections
        }
        .padding(.top, Constants.topPadding)
        .task {
            await viewModel.loadData()
        }
    }
    
    // MARK: - Subviews
    private var gameVersionSection: some View {
        CategorySectionView(
            title: FilterTitle.version,
            items: viewModel.versions.map { FilterItem(id: $0.id, name: $0.id) },
            selectedItems: $selectedVersions,
            isLoading: viewModel.isLoading
        )
    }
    
    private var categorySection: some View {
        CategorySectionView(
            title: FilterTitle.category,
            items: viewModel.categories.map { FilterItem(id: $0.name, name: $0.name) },
            selectedItems: $selectedCategories,
            isLoading: viewModel.isLoading
        )
    }
    
    private var projectSpecificSections: some View {
        Group {
            switch project {
            case ProjectType.modpack, ProjectType.mod:
                environmentSection
            case ProjectType.resourcepack:
                resourcePackSections
            case ProjectType.shader:
                shaderSections
            default:
                EmptyView()
            }
        }
    }
    
    private var environmentSection: some View {
        CategorySectionView(
            title: FilterTitle.environment,
            items: environmentItems,
            selectedItems: $selectedFeatures,
            isLoading: viewModel.isLoading
        )
    }
    
    private var resourcePackSections: some View {
        Group {
            CategorySectionView(
                title: FilterTitle.behavior,
                items: viewModel.features.map { FilterItem(id: $0.name, name: $0.name) },
                selectedItems: $selectedFeatures,
                isLoading: viewModel.isLoading
            )
            CategorySectionView(
                title: FilterTitle.resolutions,
                items: viewModel.resolutions.map { FilterItem(id: $0.name, name: $0.name) },
                selectedItems: $selectedResolutions,
                isLoading: viewModel.isLoading
            )
        }
    }
    
    private var shaderSections: some View {
        Group {
            CategorySectionView(
                title: FilterTitle.behavior,
                items: viewModel.features.map { FilterItem(id: $0.name, name: $0.name) },
                selectedItems: $selectedFeatures,
                isLoading: viewModel.isLoading
            )
            CategorySectionView(
                title: FilterTitle.performance,
                items: viewModel.performanceImpacts.map { FilterItem(id: $0.name, name: $0.name) },
                selectedItems: $selectedPerformanceImpact,
                isLoading: viewModel.isLoading
            )
        }
    }
    
    // MARK: - Computed Properties
    private var environmentItems: [FilterItem] {
        [
            FilterItem(id: "client", name: NSLocalizedString("environment.client", comment: "")),
            FilterItem(id: "server", name: NSLocalizedString("environment.server", comment: "")),
        ]
    }
}

// MARK: - Supporting Types
struct FilterItem: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    
    static func == (lhs: FilterItem, rhs: FilterItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Category Section View
private struct CategorySectionView: View {
    // MARK: - Properties
    let title: String
    let items: [FilterItem]
    @Binding var selectedItems: [String]
    let isLoading: Bool
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            if isLoading {
                loadingPlaceholder
            } else {
                contentView
            }
        }
    }
    
    // MARK: - Subviews
    private var headerView: some View {
        HStack(alignment: .center) {
            headerTitle
            Spacer()
            clearButton
        }
        .padding(.bottom, Constants.headerBottomPadding)
    }
    
    private var headerTitle: some View {
        HStack(spacing: 4) {
            Text(NSLocalizedString(title, comment: ""))
                .font(.headline)
            if !selectedItems.isEmpty {
                Text("(\(selectedItems.count))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var clearButton: some View {
        if !selectedItems.isEmpty {
            Button(action: clearSelection) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help(NSLocalizedString("filter.clear", comment: ""))
        }
    }
    
    private var loadingPlaceholder: some View {
        ScrollView {
            FlowLayout {
                ForEach(0..<Constants.placeholderCount, id: \.self) { _ in
                    FilterChip(title: "Loading...", isSelected: false, action: {})
                        .redacted(reason: .placeholder)
                }
            }
        }
        .frame(maxHeight: Constants.maxHeight)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical, Constants.verticalPadding)
    }
    
    private var contentView: some View {
        ScrollView {
            FlowLayout {
                ForEach(items) { item in
                    FilterChip(
                        title: item.name,
                        isSelected: selectedItems.contains(item.id),
                        action: { toggleSelection(for: item.id) }
                    )
                }
            }
        }
        .frame(maxHeight: Constants.maxHeight)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical, Constants.verticalPadding)
    }
    
    // MARK: - Actions
    private func clearSelection() {
        selectedItems.removeAll()
    }
    
    private func toggleSelection(for id: String) {
        if selectedItems.contains(id) {
            selectedItems.removeAll { $0 == id }
        } else {
            selectedItems.append(id)
        }
    }
}
