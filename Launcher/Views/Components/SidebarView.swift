import SwiftUI

public struct SidebarView: View {
    @Binding var selection: SidebarItem?
    
    // State to control the showing of the sheet
    @State private var showingGameForm = false
    
    public init(selection: Binding<SidebarItem?>) {
        self._selection = selection
    }
    
    public var body: some View {
        List(selection: $selection) {
            Section(NSLocalizedString("sidebar.resources", comment: "")) {
                ForEach(SidebarItem.allCases) { item in
                    Label(item.localizedName, systemImage: item.icon)
                        .tag(item)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                showingGameForm.toggle()
            }, label: {
                Label(NSLocalizedString("sidebar.addGame", comment: ""), systemImage: "gamecontroller")
            })
            .buttonStyle(.borderless)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .listStyle(.sidebar)
        // The sheet to present the form
        .sheet(isPresented: $showingGameForm) {
            GameFormView()
        }
    }
}

#Preview {
    SidebarView(selection: .constant(.mods))
}
