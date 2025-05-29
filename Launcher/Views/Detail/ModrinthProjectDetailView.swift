import SwiftUI
import MarkdownUI

// MARK: - Constants
private enum Constants {
    static let iconSize: CGFloat = 75
    static let cornerRadius: CGFloat = 8
    static let spacing: CGFloat = 12
    static let padding: CGFloat = 16
    static let galleryImageHeight: CGFloat = 160
    static let galleryImageMinWidth: CGFloat = 160
    static let galleryImageMaxWidth: CGFloat = 200
}

// MARK: - ModrinthProjectDetailView
struct ModrinthProjectDetailView: View {
    let projectId: String
    @Binding var selectedTab: Int
    @Binding var projectDetail: ModrinthProjectDetail?
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        List {
            if let error = error {
                errorView(error)
            } else if let project = projectDetail {
                projectDetailView(project)
            }
        }
        .task(id: projectId) {
            await loadProjectDetails()
        }
    }
    
    
    // MARK: - Error View
    private func errorView(_ error: Error) -> some View {
        ContentUnavailableView {
            Label(NSLocalizedString("common.error", comment: "Error"), systemImage: "exclamationmark.triangle")
        } description: {
            Text(error.localizedDescription)
        } actions: {
            Button(NSLocalizedString("common.retry", comment: "Retry")) {
                Task {
                    await loadProjectDetails()
                }
            }
        }
    }
    
    // MARK: - Project Detail View
    private func projectDetailView(_ project: ModrinthProjectDetail) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            projectHeader(project)
            projectContent(project)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
    
    // MARK: - Project Header
    private func projectHeader(_ project: ModrinthProjectDetail) -> some View {
        VStack(alignment: .leading, spacing: Constants.spacing) {
            HStack(alignment: .top, spacing: Constants.spacing) {
                projectIcon(project)
                projectInfo(project)
            }
        }
        .padding(.horizontal, Constants.padding)
        .padding(.vertical, Constants.spacing)
    }
    
    private func projectIcon(_ project: ModrinthProjectDetail) -> some View {
        Group {
            if let iconUrl = project.iconUrl, let url = URL(string: iconUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: Constants.iconSize, height: Constants.iconSize)
                .cornerRadius(Constants.cornerRadius)
                .clipped()
            }
        }
    }
    
    private func projectInfo(_ project: ModrinthProjectDetail) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(project.title)
                .font(.title2.bold())
            
            Text(project.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            projectStats(project)
        }
    }
    
    private func projectStats(_ project: ModrinthProjectDetail) -> some View {
        HStack(spacing: Constants.spacing) {
            Label("\(project.downloads)", systemImage: "arrow.down.circle")
            Label("\(project.followers)", systemImage: "heart")
            
            FlowLayout(spacing: 6) {
                ForEach(project.categories, id: \.self) { category in
                    Text(category)
                        .font(.caption)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                }
            }
        }
        .font(.caption)
        .foregroundColor(.secondary)
    }
    
    // MARK: - Project Content
    private func projectContent(_ project: ModrinthProjectDetail) -> some View {
        VStack(alignment: .leading, spacing: Constants.spacing) {
            switch selectedTab {
            case 0:
                descriptionView(project)
            case 1:
                versionsView(project)
            case 2:
                galleryView(project)
            default:
                EmptyView()
            }
        }
        .padding(.horizontal, Constants.padding)
        .padding(.bottom, Constants.spacing)
    }
    
    private func descriptionView(_ project: ModrinthProjectDetail) -> some View {
        Markdown(project.body)
    }
    
    private func versionsView(_ project: ModrinthProjectDetail) -> some View {
        FlowLayout(spacing: 6) {
            ForEach(project.versions, id: \.self) { version in
                Text(version)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(4)
            }
        }
    }
    
    private func galleryView(_ project: ModrinthProjectDetail) -> some View {
        Group {
            if let gallery = project.gallery, !gallery.isEmpty {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(
                            minimum: Constants.galleryImageMinWidth,
                            maximum: Constants.galleryImageMaxWidth
                        ), spacing: Constants.spacing)
                    ],
                    spacing: Constants.spacing
                ) {
                    ForEach(gallery, id: \.url) { image in
                        galleryImage(image)
                    }
                }
            } else {
                ContentUnavailableView {
                    Label(NSLocalizedString("gallery.empty", comment: "No Gallery"), systemImage: "photo.on.rectangle")
                } description: {
                    Text(NSLocalizedString("gallery.empty.description", comment: "No gallery images available"))
                }
            }
        }
    }
    
    private func galleryImage(_ image: GalleryImage) -> some View {
        AsyncImage(url: URL(string: image.url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                Image(systemName: "photo")
                    .foregroundColor(.secondary)
            @unknown default:
                EmptyView()
            }
        }
        .frame(height: Constants.galleryImageHeight)
        .cornerRadius(Constants.cornerRadius)
        .clipped()
    }
    
    // MARK: - Data Loading
    private func loadProjectDetails() async {
        isLoading = true
        error = nil
        projectDetail = nil
        
        Logger.shared.info("Loading project details for ID: \(projectId)")
        
        do {
            let fetchedProject = try await ModrinthService.fetchProjectDetails(id: projectId)
            await MainActor.run {
                projectDetail = fetchedProject
                isLoading = false
            }
            Logger.shared.info("Successfully loaded project details for ID: \(projectId)")
        } catch {
            await MainActor.run {
                self.error = error
                isLoading = false
            }
            Logger.shared.error("Failed to load project details for ID: \(projectId), error: \(error)")
        }
    }
}

 

