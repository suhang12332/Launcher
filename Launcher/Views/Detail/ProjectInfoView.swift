import SwiftUI

struct ProjectInfoView: View {
    // 示例数据（实际应用中应从API获取）
    let project: ModrinthProjectDetail
    
    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 4) {
                
                // 兼容性信息
                compatibilitySection
                
                // 支持环境
                supportedEnvironmentsSection
                
                // 链接
                linksSection
                
                // 创建者
                creatorsSection
                
                // 详情
                detailsSection
            }
            .padding()
        }
//        .background(Color(.systemGroupedBackground))
        .navigationTitle(project.title)
    }
    
    
    
    private var compatibilitySection: some View {
        SectionView(title: "Compatibility") {
            VStack(alignment: .leading, spacing: 12) {
                // Minecraft版本
                HStack(alignment: .top) {
                    Text("Minecraft:").font(.headline)
                    Text("Java Edition")
                }
                
                // 游戏版本
                if !project.gameVersions.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Versions:").font(.headline)
                        FlowLayout(spacing: 6) {
                            ForEach(project.gameVersions.prefix(6), id: \.self) { version in
                                Text(version)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.15))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                
                // 平台/加载器
                if !project.loaders.isEmpty {
                    HStack(alignment: .top) {
                        Text("Platform:").font(.headline)
                        Text(project.loaders.joined(separator: ", "))
                    }
                }
            }
        }
    }
    
    private var supportedEnvironmentsSection: some View {
        SectionView(title: "Supported environments") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Client-side:").font(.headline)
                    Text(project.clientSide.capitalized)
                }
                
                HStack {
                    Text("Server-side:").font(.headline)
                    Text(project.serverSide.capitalized)
                }
            }
        }
    }
    
    private var linksSection: some View {
        SectionView(title: "Links") {
            VStack(alignment: .leading, spacing: 8) {
                if let url = project.issuesUrl {
                    LinkButton(icon: "exclamationmark.triangle", text: "Report issues", url: url)
                }
                
                if let url = project.sourceUrl {
                    LinkButton(icon: "chevron.left.slash.chevron.right", text: "View source", url: url)
                }
                
                if let url = project.wikiUrl {
                    LinkButton(icon: "book.closed", text: "Visit wiki", url: url)
                }
                
                if let url = project.discordUrl {
                    LinkButton(icon: "message", text: "Join Discord", url: url)
                }
                
                if let donationUrls = project.donationUrls, !donationUrls.isEmpty {
                    ForEach(donationUrls, id: \.id) { donation in
                        LinkButton(icon: "dollarsign.circle", text: "Donate", url: donation.url)
                    }
                }
            }
        }
    }
    
    private var creatorsSection: some View {
        SectionView(title: "Creators") {
            // 这里需要根据实际API返回的团队信息调整
            // 示例数据
            VStack(alignment: .leading, spacing: 8) {
                CreatorRow(name: "Kichura", role: "Community Moderator")
                CreatorRow(name: "osfanbuff63", role: "Community Moderator")
                CreatorRow(name: "TheBossMagnus", role: "Community Moderator")
                CreatorRow(name: "robotkoer", role: "Owner")
            }
        }
    }
    
    private var detailsSection: some View {
        SectionView(title: "Details") {
            VStack(alignment: .leading, spacing: 8) {
                if let license = project.license {
                    DetailRow(label: "Licensed", value: license.name)
                }
                
                DetailRow(label: "Published", value: project.published.formattedDate())
                DetailRow(label: "Updated", value: project.updated.formattedDate())
            }
        }
    }
}

// MARK: - 辅助视图

private struct SectionView<Content: View>: View {
    let title: String
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline.bold())
                .padding(.bottom, 4)
            
            content()
        }
    }
}

private struct LinkButton: View {
    let icon: String
    let text: String
    let url: String
    
    var body: some View {
        if let url = URL(string: url) {
            Link(destination: url) {
                HStack {
                    Image(systemName: icon)
                    Text(text)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .foregroundColor(.primary)
            }
        }
    }
}

private struct CreatorRow: View {
    let name: String
    let role: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.subheadline)
            Spacer()
            Text(role)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

private struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label).font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 数据模型扩展

extension ModrinthProjectDetail {
    static func mockData() -> ModrinthProjectDetail {
        return ModrinthProjectDetail(
            slug: "fabric-api",
            title: "Fabric API",
            description: "Core library for the Fabric toolchain.",
            categories: ["technology", "library"],
            clientSide: "required",
            serverSide: "optional",
            body: "Fabric API is the core library for the Fabric toolchain.",
            status: "approved",
            requestedStatus: nil,
            additionalCategories: nil,
            issuesUrl: "https://github.com/FabricMC/fabric/issues",
            sourceUrl: "https://github.com/FabricMC/fabric",
            wikiUrl: "https://fabricmc.net/wiki/start",
            discordUrl: "https://discord.gg/fabric",
            donationUrls: [DonationUrl(id: "1", platform: "Patreon", url: "https://patreon.com/fabric")],
            projectType: "mod",
            downloads: 10000000,
            iconUrl: "https://cdn.modrinth.com/data/P7dR8mSH/icon.png",
            color: 0x4a6fa5,
            threadId: nil,
            monetizationStatus: "monetized",
            id: "P7dR8mSH",
            team: "fabric",
            bodyUrl: nil,
            moderatorMessage: nil,
            published: Date(timeIntervalSince1970: 1609459200),
            updated: Date(timeIntervalSinceNow: -345600), // 4天前
            approved: Date(timeIntervalSince1970: 1609459200),
            queued: nil,
            followers: 50000,
            license: License(id: "BSD-3-Clause", name: "BSD 3-Clause", url: "https://opensource.org/licenses/BSD-3-Clause"),
            versions: ["1.0.0", "1.1.0"],
            gameVersions: ["1.21", "1.20.4", "1.19.4", "1.18.2", "1.17.1", "1.16.5"],
            loaders: ["Fabric"],
            gallery: nil
        )
    }
}

extension Date {
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}

// MARK: - 预览


