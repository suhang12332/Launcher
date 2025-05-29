import SwiftUI

struct ModrinthProjectCardView: View {
    // MARK: - Properties
    let mod: ModrinthProject
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: ModrinthConstants.UI.contentSpacing) {
            iconView
            VStack(alignment: .leading, spacing: ModrinthConstants.UI.spacing) {
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
                .frame(width: ModrinthConstants.UI.iconSize, height: ModrinthConstants.UI.iconSize)
                .cornerRadius(ModrinthConstants.UI.cornerRadius)
                .clipped()
                .id(url)
            } else {
                Color.gray.opacity(0.2)
                    .frame(
                        width: ModrinthConstants.UI.iconSize,
                        height: ModrinthConstants.UI.iconSize
                    )
                    .cornerRadius(ModrinthConstants.UI.cornerRadius)
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
            .lineLimit(ModrinthConstants.UI.descriptionLineLimit)
            .foregroundColor(.secondary)
    }
    
    private var tagsView: some View {
        HStack(spacing: ModrinthConstants.UI.spacing) {
            ForEach(
                Array(mod.displayCategories.prefix(ModrinthConstants.UI.maxTags)),
                id: \.self
            ) { tag in
                Text(tag)
                    .font(.caption2)
                    .padding(.horizontal, ModrinthConstants.UI.tagHorizontalPadding)
                    .padding(.vertical, ModrinthConstants.UI.tagVerticalPadding)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(ModrinthConstants.UI.tagCornerRadius)
            }
            if mod.displayCategories.count > ModrinthConstants.UI.maxTags {
                Text("+\(mod.displayCategories.count - ModrinthConstants.UI.maxTags)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var infoView: some View {
        VStack(alignment: .trailing, spacing: ModrinthConstants.UI.spacing) {
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