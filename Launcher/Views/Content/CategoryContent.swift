//
//  CategoryContent.swift
//  Launcher
//
//  Created by su on 2025/5/8.
//

import SwiftUI

// MARK: - Constants
private enum Constants {
    static let maxHeight: CGFloat = 250
    static let verticalPadding: CGFloat = 4
    static let topPadding: CGFloat = 4
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
}

// MARK: - CategoryContent
struct CategoryContent: View {
    // MARK: - Properties
    let project: String
    @State private var categories: [Category] = []
    @State private var features: [Category] = []
    @State private var resolutions: [Category] = []
    @State private var performanceImpacts: [Category] = []
    @State private var versions: [GameVersion] = []
    @State private var isLoading: Bool = true
    
    @Binding var selectedCategories: [String]
    @Binding var selectedFeatures: [String]
    @Binding var selectedResolutions: [String]
    @Binding var selectedPerformanceImpact: [String]
    @Binding var selectedVersions: [String]
    
    // MARK: - Body
    var body: some View {
        Section {
            gameVersionSection
            categorySection
            projectSpecificSections
        }
        .padding(.top, Constants.topPadding)
        .task {
            await loadData()
        }
    }
    
    // MARK: - Subviews
    private var gameVersionSection: some View {
        VStack {
            versionHeaderView
            Divider()
            if isLoading {
                loadingPlaceholder
            } else {
                versionContentView
            }
        }
        .frame(maxHeight: Constants.maxHeight)
    }
    
    private var loadingPlaceholder: some View {
        ScrollView {
            FlowLayout {
                ForEach(0..<5) { _ in
                    FilterChip(
                        title: "Loading...",
                        isSelected: false,
                        action: {}
                    )
                    .redacted(reason: .placeholder)
                }
            }
        }
        .padding(.vertical, Constants.verticalPadding)
    }
    
    private var versionHeaderView: some View {
        HStack(alignment: .center) {
            Text(NSLocalizedString("filter.version", comment: ""))
                .font(.headline)
            Spacer()
        }
    }
    
    private var versionContentView: some View {
        ScrollView {
            FlowLayout {
                ForEach(versions) { version in
                    FilterChip(
                        title: version.id,
                        isSelected: selectedVersions.contains(version.id),
                        action: { toggleVersionSelection(version.id) }
                    )
                }
            }
        }
        .padding(.vertical, Constants.verticalPadding)
    }
    
    private var categorySection: some View {
        CategorySection(
            title: FilterTitle.category,
            items: categories,
            selectedItems: $selectedCategories,
            isLoading: isLoading
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
        CategorySection(
            title: FilterTitle.environment,
            items: getEnvironmentItems(),
            selectedItems: $selectedFeatures,
            isLoading: isLoading
        )
    }
    
    private var resourcePackSections: some View {
        Group {
            CategorySection(
                title: FilterTitle.behavior,
                items: features,
                selectedItems: $selectedFeatures,
                isLoading: isLoading
            )
            CategorySection(
                title: FilterTitle.resolutions,
                items: resolutions,
                selectedItems: $selectedResolutions,
                isLoading: isLoading
            )
        }
    }
    
    private var shaderSections: some View {
        Group {
            CategorySection(
                title: FilterTitle.behavior,
                items: features,
                selectedItems: $selectedFeatures,
                isLoading: isLoading
            )
            CategorySection(
                title: FilterTitle.performance,
                items: performanceImpacts,
                selectedItems: $selectedPerformanceImpact,
                isLoading: isLoading
            )
        }
    }
    
    // MARK: - Methods
    private func loadData() async {
        isLoading = true
        do {
            async let categoriesTask = ModrinthService.fetchCategories()
            async let versionsTask = ModrinthService.fetchGameVersions()
            
            let (categoriesResult, versionsResult) = try await (categoriesTask, versionsTask)
            
            versions = versionsResult
            let projectType = project == ProjectType.datapack ? ProjectType.mod : project
            let filteredCategories = categoriesResult.filter { $0.project_type == projectType }
            
            categories = filteredCategories.filter { $0.header == CategoryHeader.categories }
            features = filteredCategories.filter { $0.header == CategoryHeader.features }
            resolutions = filteredCategories.filter { $0.header == CategoryHeader.resolutions }
            performanceImpacts = filteredCategories.filter { $0.header == CategoryHeader.performanceImpact }
        } catch {
            Logger.shared.error("加载数据错误: \(error)")
        }
        isLoading = false
    }
    
    private func getEnvironmentItems() -> [Category] {
        [
            Category(name: "client", icon: "", project_type: project, header: CategoryHeader.environment),
            Category(name: "server", icon: "", project_type: project, header: CategoryHeader.environment)
        ]
    }
    
    private func toggleVersionSelection(_ versionId: String) {
        if selectedVersions.contains(versionId) {
            selectedVersions.removeAll { $0 == versionId }
        } else {
            selectedVersions.append(versionId)
        }
    }
}

// MARK: - Category Section View
private struct CategorySection: View {
    // MARK: - Properties
    let title: String
    let items: [Category]
    @Binding var selectedItems: [String]
    let isLoading: Bool
    
    // MARK: - Body
    var body: some View {
        VStack {
            headerView
            Divider()
            if isLoading {
                loadingPlaceholder
            } else {
                contentView
            }
        }
        .frame(maxHeight: Constants.maxHeight)
    }
    
    // MARK: - Subviews
    private var headerView: some View {
        HStack(alignment: .center) {
            Text(NSLocalizedString(title, comment: ""))
                .font(.headline)
            Spacer()
        }
    }
    
    private var loadingPlaceholder: some View {
        ScrollView {
            FlowLayout {
                ForEach(0..<5) { _ in
                    FilterChip(
                        title: "Loading...",
                        isSelected: false,
                        action: {}
                    )
                    .redacted(reason: .placeholder)
                }
            }
        }
        .padding(.vertical, Constants.verticalPadding)
    }
    
    private var contentView: some View {
        ScrollView {
            FlowLayout {
                ForEach(items) { item in
                    FilterChip(
                        title: getLocalizedName(for: item.name),
                        isSelected: selectedItems.contains(item.name),
                        action: { toggleSelection(item.name) }
                    )
                }
            }
        }
        .padding(.vertical, Constants.verticalPadding)
    }
    
    // MARK: - Methods
    private func toggleSelection(_ name: String) {
        if selectedItems.contains(name) {
            selectedItems.removeAll { $0 == name }
        } else {
            selectedItems.append(name)
        }
    }
    
    private func getLocalizedName(for name: String) -> String {
        if title == FilterTitle.environment {
            switch name {
            case "client":
                return NSLocalizedString("environment.client", comment: "")
            case "server":
                return NSLocalizedString("environment.server", comment: "")
            default:
                return name
            }
        }
        return name
    }
}
