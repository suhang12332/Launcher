import SwiftUI

// MARK: - Constants
private enum Constants {
    static let pageSize: Int = 20
    static let iconSize: CGFloat = 48
    static let cornerRadius: CGFloat = 8
    static let tagCornerRadius: CGFloat = 6
    static let verticalPadding: CGFloat = 3
    static let tagHorizontalPadding: CGFloat = 3
    static let tagVerticalPadding: CGFloat = 1
    static let spacing: CGFloat = 3
    static let descriptionLineLimit: Int = 2
    static let maxTags: Int = 3
}

private enum FacetType {
    static let projectType = "project_type"
    static let versions = "versions"
    static let categories = "categories"
    static let clientSide = "client_side"
    static let serverSide = "server_side"
    static let resolutions = "resolutions"
    static let performanceImpact = "performance_impact"
}

private enum FacetValue {
    static let required = "required"
    static let optional = "optional"
    static let unsupported = "unsupported"
}

// MARK: - ViewModel
@MainActor
final class ModrinthSearchViewModel: ObservableObject {
    @Published private(set) var results: [ModrinthProject] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var totalHits: Int = 0
    
    let pageSize: Int = Constants.pageSize
    private var searchTask: Task<Void, Never>?

    func search(projectType: String, page: Int = 1, sortIndex: String,
                versions: [String] = [], categories: [String] = [],
                features: [String] = [], resolutions: [String] = [],
                performanceImpact: [String] = []) async {
        // Cancel any existing search task
        searchTask?.cancel()
        
        searchTask = Task {
        isLoading = true
        error = nil
            
        do {
            let offset = (page - 1) * pageSize
                let facets = buildFacets(
                    projectType: projectType,
                    versions: versions,
                    categories: categories,
                    features: features,
                    resolutions: resolutions,
                    performanceImpact: performanceImpact
                )
                
            let result = try await ModrinthService.searchProjects(
                    facets: facets,
                index: sortIndex,
                offset: offset,
                limit: pageSize
            )
                
                if !Task.isCancelled {
            results = result.hits
            totalHits = result.totalHits
                }
        } catch {
                if !Task.isCancelled {
            Logger.shared.error("Modrinth search error: \(error)")
            self.error = error
        }
            }
            
            if !Task.isCancelled {
        isLoading = false
    }
}
    }
    
    private func buildFacets(
        projectType: String,
        versions: [String],
        categories: [String],
        features: [String],
        resolutions: [String],
        performanceImpact: [String]
    ) -> [[String]] {
        var facets: [[String]] = []
        
        // Project type is always required
        facets.append(["\(FacetType.projectType):\(projectType)"])
        
        // Add versions if any
        if !versions.isEmpty {
            facets.append(versions.map { "\(FacetType.versions):\($0)" })
        }
        
        // Add categories if any
        if !categories.isEmpty {
            facets.append(categories.map { "\(FacetType.categories):\($0)" })
        }
        
        // Handle client_side and server_side based on features selection
        let (clientFacets, serverFacets) = buildEnvironmentFacets(features: features)
        if !clientFacets.isEmpty {
            facets.append(clientFacets)
        }
        if !serverFacets.isEmpty {
            facets.append(serverFacets)
        }
        
        // Add resolutions if any
        if !resolutions.isEmpty {
            facets.append(resolutions.map { "\(FacetType.resolutions):\($0)" })
        }
        
        // Add performance impact if any
        if !performanceImpact.isEmpty {
            facets.append(performanceImpact.map { "\(FacetType.performanceImpact):\($0)" })
        }
        
        return facets
    }
    
    private func buildEnvironmentFacets(features: [String]) -> (clientFacets: [String], serverFacets: [String]) {
        let hasClient = features.contains("client")
        let hasServer = features.contains("server")
        
        let clientFacets: [String]
        let serverFacets: [String]
        
        if hasClient && hasServer {
            clientFacets = ["\(FacetType.clientSide):\(FacetValue.required)"]
            serverFacets = ["\(FacetType.serverSide):\(FacetValue.required)"]
        } else if hasClient {
            clientFacets = [
                "\(FacetType.clientSide):\(FacetValue.optional)",
                "\(FacetType.clientSide):\(FacetValue.required)"
            ]
            serverFacets = [
                "\(FacetType.serverSide):\(FacetValue.optional)",
                "\(FacetType.serverSide):\(FacetValue.unsupported)"
            ]
        } else if hasServer {
            clientFacets = [
                "\(FacetType.clientSide):\(FacetValue.optional)",
                "\(FacetType.clientSide):\(FacetValue.unsupported)"
            ]
            serverFacets = [
                "\(FacetType.serverSide):\(FacetValue.optional)",
                "\(FacetType.serverSide):\(FacetValue.required)"
            ]
        } else {
            clientFacets = []
            serverFacets = []
        }
        
        return (clientFacets, serverFacets)
    }
    
    deinit {
        searchTask?.cancel()
    }
}

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
            Text(String(format: NSLocalizedString("game.version.loading", comment: ""), NSLocalizedString(query, comment: "")))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ error: Error) -> some View {
        ContentUnavailableView {
            Label(String(format: NSLocalizedString("modrinth.search.error", comment: ""), NSLocalizedString(query, comment: "")), systemImage: "xmark.icloud")
        } description: {
            Text(localizedErrorMessage(error))
        }
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label(NSLocalizedString("common.error", comment: ""), systemImage: "tray")
        } description: {
            Text(NSLocalizedString("No results found.", comment: ""))
        }
    }

    private var resultList: some View {
        List {
            ForEach(viewModel.results, id: \.projectId) { mod in
                ModrinthProjectCardView(mod: mod)
                    .padding(.vertical, Constants.verticalPadding)
                    .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Project Card View
struct ModrinthProjectCardView: View {
    // MARK: - Properties
    let mod: ModrinthProject

    // MARK: - Body
    var body: some View {
        HStack(spacing: Constants.spacing) {
            iconView
            VStack(alignment: .leading, spacing: Constants.spacing) {
                titleView
                descriptionView
                tagsView
            }
            Spacer(minLength: 8)
            infoView
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - View Components
    private var iconView: some View {
        Group {
            if let iconUrl = mod.iconUrl, let url = URL(string: iconUrl) {
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
                .frame(width: Constants.iconSize, height: Constants.iconSize)
                .cornerRadius(Constants.cornerRadius)
                .clipped()
                .id(url)
            } else {
                Color.gray.opacity(0.2)
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .cornerRadius(Constants.cornerRadius)
            }
        }
    }

    private var titleView: some View {
        HStack(spacing: 4) {
            Text(mod.title)
                .font(.headline)
                .lineLimit(1)
            Text("by \(mod.author)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
    
    private var descriptionView: some View {
        Text(mod.description)
            .font(.subheadline)
            .lineLimit(Constants.descriptionLineLimit)
            .foregroundColor(.secondary)
    }

    private var tagsView: some View {
        HStack(spacing: Constants.spacing) {
            ForEach(Array(mod.displayCategories.prefix(Constants.maxTags)), id: \.self) { tag in
                Text(tag)
                    .font(.caption2)
                    .padding(.horizontal, Constants.tagHorizontalPadding)
                    .padding(.vertical, Constants.tagVerticalPadding)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(Constants.tagCornerRadius)
            }
            if mod.displayCategories.count > Constants.maxTags {
                Text("+\(mod.displayCategories.count - Constants.maxTags)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var infoView: some View {
        VStack(alignment: .trailing, spacing: Constants.spacing) {
            downloadInfoView
            followerInfoView
            addButton
        }
    }
    
    private var downloadInfoView: some View {
            HStack(spacing: 2) {
                Image(systemName: "arrow.down.circle")
                .imageScale(.small)
            Text("\(Self.formatNumber(mod.downloads))")
            }
        .font(.caption2)
        .foregroundColor(.secondary)
    }
    
    private var followerInfoView: some View {
            HStack(spacing: 2) {
                Image(systemName: "heart")
                .imageScale(.small)
            Text("\(Self.formatNumber(mod.follows))")
            }
        .font(.caption2)
        .foregroundColor(.secondary)
    }
    
    private var addButton: some View {
        Button("+ Add") {
            // TODO: Implement add to instance functionality
            }
            .buttonStyle(.borderedProminent)
        .font(.caption2)
        .controlSize(.small)
    }

    // MARK: - Helper Methods
    static func formatNumber(_ num: Int) -> String {
        if num >= 1_000_000 {
            return String(format: "%.1fM", Double(num) / 1_000_000)
        } else if num >= 1_000 {
            return String(format: "%.1fk", Double(num) / 1_000)
        } else {
            return "\(num)"
        }
    }
}
