//
//  LicenseContent.swift
//  Launcher
//
//  Created by su on 2025/5/8.
//

import SwiftUI

struct LicenseContent: View {
    @Binding var selectedLicense: [String]
    @State private var licenses: [License] = []
    @State private var isLoading = true
    @State private var error: Error?

    var body: some View {
        HStack {
            if isLoading {
                ProgressView {
                    Text(
                        String(
                            format: NSLocalizedString(
                                "game.version.loading",
                                comment: "正在加载 %@ 版本"
                            ),
                            NSLocalizedString("filter.version", comment: "版本筛选")
                        )
                    )
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
            } else {
                ScrollView {
                    FlowLayout(spacing: 8) {
                        ForEach(licenses) { license in
                            FilterChip(
                                title: license.short,
                                isSelected: selectedLicense.contains(
                                    license.short
                                ),
                                action: {
                                    if selectedLicense.contains(license.short) {
                                        selectedLicense.removeAll {
                                            $0 == license.short
                                        }
                                    } else {
                                        selectedLicense.append(license.short)
                                    }
                                }
                            )
                        }
                    }
                }
                .frame(height: 120)
                .padding(.vertical, 4)
            }
        }
        .frame(minWidth: 230, idealWidth: 230, maxWidth: 350, maxHeight: 150)
        .task {
            do {
                isLoading = true
                licenses = try await ModrinthService.fetchLicenses()
                isLoading = false
            } catch {
                print("Error fetching versions: \(error)")
                isLoading = false
                self.error = error
            }
        }
    }
}
