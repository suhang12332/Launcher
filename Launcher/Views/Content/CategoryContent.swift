//  CategoryContent.swift
//  Launcher
//
//  Created by su on 2025/5/8.
//

import SwiftUI

// MARK: - CategoryContent
struct CategoryContent: View {
    // MARK: - Properties
    let project: String
    @StateObject private var viewModel: CategoryContentViewModel
    @Binding var selectedCategories: [String]
    @Binding var selectedFeatures: [String]
    @Binding var selectedResolutions: [String]
    @Binding var selectedPerformanceImpacts: [String]
    @Binding var selectedVersions: [String]
    
    // MARK: - Initialization
    init(
        project: String,
        selectedCategories: Binding<[String]>,
        selectedFeatures: Binding<[String]>,
        selectedResolutions: Binding<[String]>,
        selectedPerformanceImpacts: Binding<[String]>,
        selectedVersions: Binding<[String]>
    ) {
        self.project = project
        self._selectedCategories = selectedCategories
        self._selectedFeatures = selectedFeatures
        self._selectedResolutions = selectedResolutions
        self._selectedPerformanceImpacts = selectedPerformanceImpacts
        self._selectedVersions = selectedVersions
        self._viewModel = StateObject(wrappedValue: CategoryContentViewModel(project: project))
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack {
                versionSection
                categorySection
                projectSpecificSections
            }
            .padding(.top,4)
        }
        .task {
            await viewModel.loadData()
        }
    }
    
    // MARK: - Subviews
    private var categorySection: some View {
        CategorySectionView(
            title: "filter.category",
            items: viewModel.categories.map { FilterItem(id: $0.name, name: $0.name) },
            selectedItems: $selectedCategories,
            isLoading: viewModel.isLoading
        )
    }
    
    private var versionSection: some View {
        CategorySectionView(
            title: "filter.version",
            items: viewModel.versions.map { FilterItem(id: $0.id, name: $0.id) },
            selectedItems: $selectedVersions,
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
            title: "filter.environment",
            items: environmentItems,
            selectedItems: $selectedFeatures,
            isLoading: viewModel.isLoading
        )
    }
    
    private var resourcePackSections: some View {
        Group {
            CategorySectionView(
                title: "filter.behavior",
                items: viewModel.features.map { FilterItem(id: $0.name, name: $0.name) },
                selectedItems: $selectedFeatures,
                isLoading: viewModel.isLoading
            )
            CategorySectionView(
                title: "filter.resolutions",
                items: viewModel.resolutions.map { FilterItem(id: $0.name, name: $0.name) },
                selectedItems: $selectedResolutions,
                isLoading: viewModel.isLoading
            )
        }
    }
    
    private var shaderSections: some View {
        Group {
            CategorySectionView(
                title: "filter.behavior",
                items: viewModel.features.map { FilterItem(id: $0.name, name: $0.name) },
                selectedItems: $selectedFeatures,
                isLoading: viewModel.isLoading
            )
            CategorySectionView(
                title: "filter.performance",
                items: viewModel.performanceImpacts.map { FilterItem(id: $0.name, name: $0.name) },
                selectedItems: $selectedPerformanceImpacts,
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



