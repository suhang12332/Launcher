import SwiftUI

// MARK: - Constants
private enum Constants {
    static let pageSize: Int = 20
    static let iconSize: CGFloat = 56
    static let cornerRadius: CGFloat = 10
    static let tagCornerRadius: CGFloat = 8
    static let verticalPadding: CGFloat = 4
    static let tagHorizontalPadding: CGFloat = 4
    static let tagVerticalPadding: CGFloat = 2
    static let spacing: CGFloat = 4
    static let descriptionLineLimit: Int = 2
}

// MARK: - ViewModel
@MainActor
final class ModrinthSearchViewModel: ObservableObject {
    @Published private(set) var results: [ModrinthProject] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var totalHits: Int = 0
    
    let pageSize: Int = Constants.pageSize

    func search(projectType: String, page: Int = 1, sortIndex: String) async {
        isLoading = true
        error = nil
        
        do {
            let offset = (page - 1) * pageSize
            let result = try await ModrinthService.searchProjects(
                facets: [["project_type:\(projectType)"]],
                index: sortIndex,
                offset: offset,
                limit: pageSize
            )
            results = result.hits
            totalHits = result.totalHits
        } catch {
            Logger.shared.error("Modrinth search error: \(error)")
            self.error = error
        }
        
        isLoading = false
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
        .onChange(of: viewModel.pageSize) { _, newValue in
            itemsPerPage = newValue
        }
        .refreshable {
            await performSearch()
        }
    }
    
    // MARK: - Private Methods
    private func performSearch() async {
            await viewModel.search(projectType: query, page: currentPage, sortIndex: sortIndex)
        }
    
    // MARK: - View Components
    private var loadingView: some View {
        ProgressView(String(format: NSLocalizedString("game.version.loading", comment: ""), NSLocalizedString(query, comment: "")))
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
            }
        }
    }
}

// MARK: - Project Card View
struct ModrinthProjectCardView: View {
    // MARK: - Properties
    let mod: ModrinthProject

    // MARK: - Body
    var body: some View {
        HStack {
            iconView
            VStack(alignment: .leading, spacing: Constants.spacing) {
                titleView
                descriptionView
                tagsView
            }
            Spacer()
            infoView
        }
    }

    // MARK: - View Components
    private var iconView: some View {
        Group {
            if let iconUrl = mod.iconUrl, let url = URL(string: iconUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: Constants.iconSize, height: Constants.iconSize)
                .cornerRadius(Constants.cornerRadius)
            } else {
                Color.gray.opacity(0.2)
                    .frame(width: Constants.iconSize - 2, height: Constants.iconSize - 2)
                    .cornerRadius(Constants.cornerRadius)
            }
        }
    }

    private var titleView: some View {
        HStack {
            Text(mod.title).font(.headline)
            Text("by \(mod.author)").font(.subheadline).foregroundColor(.secondary)
        }
    }
    
    private var descriptionView: some View {
        Text(mod.description)
            .font(.subheadline)
            .lineLimit(Constants.descriptionLineLimit)
            .foregroundColor(.secondary)
    }

    private var tagsView: some View {
        HStack {
            ForEach(mod.displayCategories, id: \.self) { tag in
                Text(tag)
                    .font(.caption)
                    .padding(.horizontal, Constants.tagHorizontalPadding)
                    .padding(.vertical, Constants.tagVerticalPadding)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(Constants.tagCornerRadius)
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
                Text("\(Self.formatNumber(mod.downloads)) downloads")
            }
            .font(.caption)
    }
    
    private var followerInfoView: some View {
            HStack(spacing: 2) {
                Image(systemName: "heart")
                Text("\(Self.formatNumber(mod.follows)) followers")
            }
            .font(.caption)
    }
    
    private var addButton: some View {
            Button("+ Add to an instance") {
            // TODO: Implement add to instance functionality
            }
            .buttonStyle(.borderedProminent)
            .font(.caption)
    }

    // MARK: - Helper Methods
    static func formatNumber(_ num: Int) -> String {
        if num >= 1_000_000 {
            return String(format: "%.2fM", Double(num) / 1_000_000)
        } else if num >= 1_000 {
            return String(format: "%.1fk", Double(num) / 1_000)
        } else {
            return "\(num)"
        }
    }
}
