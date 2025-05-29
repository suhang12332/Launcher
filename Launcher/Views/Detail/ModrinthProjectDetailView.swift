import SwiftUI
import MarkdownUI

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
    
    private func errorView(_ error: Error) -> some View {
        ContentUnavailableView {
            Label("Error", systemImage: "exclamationmark.triangle")
        } description: {
            Text(error.localizedDescription)
        }
    }
    
    private func projectDetailView(_ project: ModrinthProjectDetail) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 12) {
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
                        .frame(width: 75, height: 75)
                        .cornerRadius(8)
                        .clipped()
                    }

                    // Text content and statistics
                    VStack(alignment: .leading, spacing: 4) {
                        Text(project.title)
                            .font(.title2.bold())

                        Text(project.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(2).padding(.leading,2)

                        // Statistics and Categories
                        HStack(spacing: 12) {
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
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)

            // Content based on selection
            VStack(alignment: .leading, spacing: 12) {
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
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
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
        if let gallery = project.gallery {
            AnyView(
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    ForEach(gallery, id: \.url) { image in
                        AsyncImage(url: URL(string: image.url)) { phase in
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
                        .frame(height: 160)
                        .cornerRadius(8)
                        .clipped()
                    }
                }
            )
        } else {
            AnyView(
                Text("No gallery images available")
                    .foregroundColor(.secondary)
            )
        }
    }
    
    private func loadProjectDetails() async {
        isLoading = true
        error = nil
        projectDetail = nil
        
        Logger.shared.info("Loading project details for ID: \(projectId)")
        
        do {
            let fetchedProject = try await ModrinthService.fetchProjectDetails(id: projectId)
            projectDetail = fetchedProject
            Logger.shared.info("Successfully loaded project details for ID: \(projectId)")
        } catch {
            Logger.shared.error("Failed to load project details for ID: \(projectId), error: \(error)")
            self.error = error
        }
        
        isLoading = false
    }
}

#Preview {
    ModrinthProjectDetailView(projectId: "P7dR8mSH", selectedTab: .constant(0), projectDetail: .constant(nil))
}
 
 