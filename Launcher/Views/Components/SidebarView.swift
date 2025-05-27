import SwiftUI

// Define a new enum to handle both resource types and game selections
public enum SidebarSelection: Identifiable, Hashable {
    case resource(SidebarItem)
    case game(String) // Use game ID as the identifier
    
    public var id: String {
        switch self {
        case .resource(let item):
            return "resource-\(item.id)"
        case .game(let id):
            return "game-\(id)"
        }
    }
}

public struct SidebarView: View {
    // Access GameStorageManager as an environment object
    @EnvironmentObject var gameStorageManager: GameStorageManager
    
    // Update the binding to the new selection type
    @Binding var selection: SidebarSelection?
    
    // State to control the showing of the sheet
    @State private var showingGameForm = false
    
    // Update initializer to use the new selection type
    public init(selection: Binding<SidebarSelection?>) {
        self._selection = selection
        // Load games data here or ensure it's provided externally
    }
    
    public var body: some View {
        List(selection: $selection) {
            
            
            // Resources Section
            Section(NSLocalizedString("resource", comment: "")) { // Localized resource section title
                ForEach(SidebarItem.allCases.filter { $0 != .games }) { item in // Filter out the games case
                    Label(item.localizedName, systemImage: item.icon)
                        .tag(SidebarSelection.resource(item)) // Tag with resource item
                }
            }
            // Games Section
            Section(NSLocalizedString("games", comment: "")) { // Localized games section title
                // Iterate over the games from GameStorageManager
                ForEach(gameStorageManager.games) { game in
                    HStack(spacing: 6) {
                        if game.gameIcon.hasPrefix("data:image") {
                            // Extract base64 data from the data URL
                            if let base64String = game.gameIcon.split(separator: ",").last,
                               let imageData = Data(base64Encoded: String(base64String)),
                               let nsImage = NSImage(data: imageData) {
                                Image(nsImage: nsImage)
                                    .resizable()
                                    .interpolation(.none)
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            } else {
                                Image(systemName: "gamecontroller")
                                    .frame(width: 16, height: 16)
                            }
                        } else {
                            Image(systemName: "gamecontroller")
                                .frame(width: 16, height: 16)
                        }
                        Text(game.gameName)
                            .lineLimit(1)
                    }
                    .padding(.leading, 2.5)
                    .tag(SidebarSelection.game(game.id)) // Tag with game ID
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                showingGameForm.toggle()
            }, label: {
                Label(NSLocalizedString("addgame", comment: ""), systemImage: "gamecontroller")
            })
            .buttonStyle(.borderless)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .listStyle(.sidebar)
        // The sheet to present the form
        .sheet(isPresented: $showingGameForm) {
            // Pass the EnvironmentObject to GameFormView
            GameFormView().environmentObject(gameStorageManager)
                .presentationDetents([.medium, .large])
                .presentationBackgroundInteraction(.automatic)
        }
    }
}

