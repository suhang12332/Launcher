//
//  ContentView.swift
//  Launcher
//
//  Created by su on 2025/4/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedItem: SidebarItem?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(selection: $selectedItem)
                .frame(width: 140)
                .navigationSplitViewColumnWidth(140)
        } content: {
            ToolbarContentView(title: "Content") {
                if let selectedItem {
                    switch selectedItem {
                    case .mods:
                        ModsContent()
                    case .dataPacks:
                        ModPacksContent()
                    case .shaders:
                        ShadersContent()
                    case .resourcePacks:
                        ResourcePacksContent()
                    case .modPacks:
                        ModPacksContent()
                    }
                }
            } toolbarContent: {
                HStack {
                    Menu {
                        Button("添加游戏") {}
                        Button("导入游戏") {}
                        Divider()
                        Button("设置") {}
                    } label: {
                        HStack {
                            Image(systemName: "gamecontroller")
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                        }
                    }
                    .menuStyle(.borderlessButton)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationSplitViewColumnWidth(230)
        } detail: {
            ToolbarContentView(title: "Detail", showDivider: false) {
                Text("Detail Content")
            } toolbarContent: {
                HStack {
                    Text("Detail")
                        .font(.headline)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
