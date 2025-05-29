import SwiftUI

// MARK: - Constants
private enum Constants {
    static let iconSize: CGFloat = 24
    static let cornerRadius: CGFloat = 6
    static let spacing: CGFloat = 8
}

// MARK: - ProjectDetailHeaderView
struct ProjectDetailHeaderView: View {
    let project: ModrinthProjectDetail
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: Constants.spacing) {
            projectIcon
            Text(project.title)
                .font(.headline)
        }
        
        Spacer()
        
        ProjectDetailTabPicker(selectedTab: $selectedTab)
    }
    
    // MARK: - Project Icon
    private var projectIcon: some View {
        Group {
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
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: Constants.iconSize, height: Constants.iconSize)
                .cornerRadius(Constants.cornerRadius)
                .clipped()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .foregroundColor(.secondary)
            }
        }
    }
}

