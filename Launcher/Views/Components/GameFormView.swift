import SwiftUI

struct GameFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var gameName: String = ""
    @State private var selectedLoader: GameLoader = .vanilla
    @State private var gameVersion: String = ""
    @State private var gameIcon: NSImage?
    @State private var isIconPickerPresented = false
    
    enum GameLoader: String, CaseIterable, Identifiable {
        case vanilla = "Vanilla"
        case fabric = "Fabric"
        case forge = "Forge"
        case neoforge = "Neoforge"
        case quilt = "Quilt"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .vanilla: return "cube"
            case .fabric: return "square.stack.3d.up"
            case .forge: return "square.stack.3d.up"
            case .neoforge: return "square.stack.3d.up.arrow.down"
            case .quilt: return "square.stack.3d.up.arrow.up"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            ScrollView {
                VStack(spacing: 32) {
                    // Game Icon
                    VStack(spacing: 12) {
                        if let gameIcon = gameIcon {
                            Image(nsImage: gameIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 140, height: 140)
                                .background(.background)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        } else {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(NSColor.controlBackgroundColor))
                                .frame(width: 140, height: 140)
                                .overlay {
                                    Image(systemName: "photo")
                                        .font(.system(size: 30))
                                        .foregroundStyle(.secondary)
                                }
                        }
                        
                        Button(action: { isIconPickerPresented = true }) {
                            Text(NSLocalizedString("game.form.selectIcon", comment: ""))
                        }
                        .buttonStyle(.link)
                    }
                    .padding(.top, 32)
                    
                    // Form Fields
                    VStack(spacing: 24) {
                        // Game Name
                        VStack(alignment: .leading, spacing: 6) {
                            Text(NSLocalizedString("game.form.name", comment: ""))
                                .foregroundStyle(.secondary)
                            TextField("", text: $gameName)
                                .textFieldStyle(.plain)
                                .padding(.vertical, 4)
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundStyle(.separator)
                                }
                        }
                        
                        // Game Loader
                        VStack(alignment: .leading, spacing: 6) {
                            Text(NSLocalizedString("game.form.loader", comment: ""))
                                .foregroundStyle(.secondary)
                            Menu {
                                ForEach(GameLoader.allCases) { loader in
                                    Button {
                                        selectedLoader = loader
                                    } label: {
                                        Text(loader.rawValue)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedLoader.rawValue)
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                        .foregroundStyle(.secondary)
                                        .imageScale(.small)
                                }
                                .padding(.vertical, 4)
                            }
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundStyle(.separator)
                            }
                        }
                        
                        // Game Version
                        VStack(alignment: .leading, spacing: 6) {
                            Text(NSLocalizedString("game.form.version", comment: ""))
                                .foregroundStyle(.secondary)
                            TextField("", text: $gameVersion)
                                .textFieldStyle(.plain)
                                .padding(.vertical, 4)
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundStyle(.separator)
                                }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity)
            }
            
            Divider()
            
            // Footer
            HStack {
                Spacer()
                Button(NSLocalizedString("game.form.cancel", comment: "")) {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                
                Button(NSLocalizedString("game.form.confirm", comment: "")) {
                    // TODO: Save game configuration
                    dismiss()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
                .disabled(gameName.isEmpty || gameVersion.isEmpty)
            }
            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            .background(.background)
        }
        .frame(width: 380)
        .background(.background)
        .fileImporter(
            isPresented: $isIconPickerPresented,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first,
                   let image = NSImage(contentsOf: url) {
                    gameIcon = image
                }
            case .failure(let error):
                print("Error selecting image: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    GameFormView()
        .frame(height: 500)
} 
