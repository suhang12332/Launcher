import SwiftUI

@MainActor
class ModrinthSearchViewModel: ObservableObject {
    @Published var results: [ModrinthProject] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var totalHits: Int = 0
    let pageSize: Int = 20

    func searchMods(query: String, page: Int = 1,index: String) async {
        isLoading = true
        error = nil
        do {
            let offset = (page - 1) * pageSize
            let result = try await ModrinthService.searchProjects(
                facets: [["project_type:\(query)"]],
                index: index,
                offset: offset,
                limit: pageSize
            )
            results = result.hits
            totalHits = result.totalHits
        } catch {
            Logger.shared.error("searchMods error:", error)
            self.error = error
        }
        isLoading = false
    }
}

struct ModrinthDetailView: View {
    var query: String
    @Binding var currentPage: Int
    @Binding var totalItems: Int
    @Binding var itemsPerPage: Int
    @Binding var sortIndex: String

    @StateObject private var viewModel = ModrinthSearchViewModel()
    @State private var hasLoaded = false
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView(String(format: NSLocalizedString("game.version.loading", comment: ""),NSLocalizedString(query, comment: "")))
            } else if let error = viewModel.error {
                ContentUnavailableView {
                    Label(String(format: NSLocalizedString("modrinth.search.error", comment: ""), NSLocalizedString(query, comment: "")), systemImage: "xmark.icloud")
                } description: {
                    Text(localizedErrorMessage(error))
                }
            } else {
                VStack(spacing: 0) {
                    List {
                        ForEach(viewModel.results, id: \.projectId) { mod in
                            ModrinthProjectCardView(mod: mod)
                                .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            if !hasLoaded {
                hasLoaded = true
                Task { await viewModel.searchMods(query: query, page: currentPage,index: sortIndex) }
            }
        }
        .onChange(of: currentPage) { _, newPage in
            Task { await viewModel.searchMods(query: query, page: newPage,index: sortIndex) }
        }
        .onChange(of: query) { _, newQuery in
            currentPage = 1
            Task { await viewModel.searchMods(query: newQuery, page: 1,index: sortIndex) }
        }
        .onChange(of: viewModel.totalHits) { _, newValue in
            totalItems = newValue
        }
        .onChange(of: sortIndex){_,newValue in
            Task {
                await viewModel.searchMods(query: query, page: 1,index: sortIndex)
            }
        }
        .onChange(of: viewModel.pageSize) { _, newValue in
            itemsPerPage = newValue
        } .refreshable {
            await viewModel.searchMods(query: query, page: currentPage,index: sortIndex)
        }
    }
}

struct ModrinthProjectCardView: View {
    let mod: ModrinthProject
    
    var body: some View {
        HStack() {
            // 图标
            if let iconUrl = mod.iconUrl, let url = URL(string: iconUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 56, height: 56)
                .cornerRadius(10)
            } else {
                Color.gray.opacity(0.2)
                    .frame(width: 54, height: 54)
                    .cornerRadius(10)
            }
            // 中间内容
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(mod.title).font(.headline)
                    Text("by \(mod.author)").font(.subheadline).foregroundColor(.secondary)
                }
                Text(mod.description)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
                // 标签
                HStack {
                    ForEach(mod.displayCategories, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(8)
                    }
                }
            }
            Spacer()
            // 右侧信息
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 2) {
                    Image(systemName: "arrow.down.circle")
                    Text("\(formatNumber(mod.downloads)) downloads")
                }
                .font(.caption)
                HStack(spacing: 2) {
                    Image(systemName: "heart")
                    Text("\(formatNumber(mod.follows)) followers")
                }
                .font(.caption)
                Button("+ Add to an instance") {
                    // 操作
                }
                .buttonStyle(.borderedProminent)
                .font(.caption)
            }
        }
    }
    // 数字格式化
    func formatNumber(_ num: Int) -> String {
        if num >= 1_000_000 {
            return String(format: "%.2fM", Double(num) / 1_000_000)
        } else if num >= 1_000 {
            return String(format: "%.1fk", Double(num) / 1_000)
        } else {
            return "\(num)"
        }
    }
}


