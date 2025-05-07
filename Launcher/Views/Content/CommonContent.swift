//
//  CommonContent.swift
//  Launcher
//
//  Created by su on 2025/5/6.
//

import SwiftUI

struct CommonContent: View {
    @Binding var selectedVersion: String
    @State private var isExpanded = false
    @State private var versions: [MinecraftVersion] = []
    @State private var selectedType: String = "release"
    
    var filteredVersions: [MinecraftVersion] {
        if selectedType.isEmpty {
            return versions
        }
        return versions.filter { $0.type == selectedType }
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text(NSLocalizedString("filter.version", comment: ""))
                    .font(.headline)
                
                Spacer()
                
                Picker("", selection: $selectedType) {
                    Text(NSLocalizedString("version.type.release", comment: "")).tag("release")
                    Text(NSLocalizedString("version.type.snapshot", comment: "")).tag("snapshot")
                    Text(NSLocalizedString("version.type.old_alpha", comment: "")).tag("old_alpha")
                    Text(NSLocalizedString("version.type.old_beta", comment: "")).tag("old_beta")
                }
//                .pickerStyle(.menu)
                .fixedSize()
            }
            Divider()
            ScrollView {
                FlowLayout {
                    ForEach(filteredVersions) { version in
                        FilterChip(
                            title: version.id,
                            isSelected: selectedVersion == version.id,
                            action: { selectedVersion = version.id }
                        )
                    }
                }
            }
            .padding(.vertical, 4)
          
        }.padding(18)
        .frame(minWidth: 230, idealWidth: 230, maxWidth: 350,maxHeight: 230)
        .task {
            do {
                let versionList = try await MinecraftService.fetchVersionList()
                versions = versionList.versions
            } catch {
                print("Error fetching versions: \(error)")
            }
        }
    }
}

#Preview {
    CommonContent(
        selectedVersion: .constant("")
    )
}

// MARK: - Filter Chip
private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isSelected ? Color.accentColor : Color.clear)
                )
                .foregroundStyle(isSelected ? .white : .primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}





