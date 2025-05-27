//
//  Content.swift
//  Launcher
//
//  Created by su on 2025/5/7.
//

import SwiftUI

struct ModrinthContentView: View {
    @Binding var selectedVersion: [String]
    @Binding var selectedLicense: [String]
    let selectedItem: SidebarItem
    @Binding var selectedCategories: [String]
    @Binding var selectedFeatures: [String]
    @Binding var selectedResolutions: [String]
    @Binding var selectedPerformanceImpact: [String]
    @State private var refreshID = UUID()
    
    var body: some View {
                List {
                    Section {
                        CategoryContent(
                            project: selectedItem.name,
                            selectedCategories: $selectedCategories,
                            selectedFeatures: $selectedFeatures,
                            selectedResolutions: $selectedResolutions,
                            selectedPerformanceImpact: $selectedPerformanceImpact,
                            selectedVersions: $selectedVersion
                        )
                    }
                    .id(refreshID)
        }
        .onChange(of: selectedItem) { _, _ in
            refreshID = UUID()
        }
    }
}

