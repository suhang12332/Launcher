import SwiftUI
import UniformTypeIdentifiers

struct GameFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var gameName: String = ""
    @State private var gameVersion: String = ""
    @State private var modLoader: String = ""
    @State private var gameIcon: String = "default_game_icon"
    @State private var iconImage: Image? = nil
    @State private var showImagePicker = false
    
    private let formSpacing: CGFloat = 16
    private let inputFieldWidth: CGFloat = 250

    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题
            HStack {
                Text(NSLocalizedString("game.form.title", comment: "添加游戏"))
                    .font(.headline)
                    .padding(formSpacing)
                Spacer()
            }
            Divider()
            
            // 表单内容
            VStack(spacing: 8) {
                // 游戏图标选择
                FormSection {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(NSLocalizedString("game.form.icon", comment: "游戏图标"))
                            Text(NSLocalizedString("game.form.icon.description", comment: "为游戏选择图标"))
                            .foregroundColor(.secondary)
                    }
                        Spacer()
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                                    .frame(width: 64, height: 64)
                                    .background(Color.gray.opacity(0.08))
                                if let iconImage = iconImage {
                                    iconImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 56, height: 56)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                } else {
                                    Image(gameIcon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 56, height: 56)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                            }
                            .onTapGesture {
                                showImagePicker = true
                            }
                            .onDrop(of: [UTType.image.identifier], isTargeted: nil) { providers in
                                if let provider = providers.first {
                                    _ = provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                                        if let data = data, let nsImage = NSImage(data: data) {
                                            DispatchQueue.main.async {
                                                iconImage = Image(nsImage: nsImage)
                                                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".png")
                                                try? data.write(to: tempURL)
                                                gameIcon = tempURL.path
                                            }
                                        }
                                    }
                                    return true
                                }
                                return false
                            }
                        }
                    }
                }
                
                FormSection {
                    FormInputField(
                        title: NSLocalizedString("game.form.name", comment: "游戏名称"),
                        placeholder: NSLocalizedString("game.form.name.placeholder", comment: "请输入游戏名称"),
                        text: $gameName
                    )
                    Spacer(minLength: 8)
                    FormInputField(
                        title: NSLocalizedString("game.form.version", comment: "游戏版本"),
                        placeholder: NSLocalizedString("game.form.version.placeholder", comment: "请输入游戏版本"),
                        text: $gameVersion
                    )
                    Spacer(minLength: 8)
                    FormInputField(
                        title: NSLocalizedString("game.form.modloader", comment: "mod加载器"),
                        placeholder: NSLocalizedString("game.form.modloader.placeholder", comment: "请输入mod加载器"),
                        text: $modLoader
                    )
                }
            }
            .padding(8)
            Divider()
            
            // 底部按钮
            HStack(spacing: 12) {
                Spacer()
                Button(NSLocalizedString("common.cancel", comment: "取消")) {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button(NSLocalizedString("common.confirm", comment: "确认")) {
                    saveGame()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isFormValid)
            }
            .padding(.vertical, 20)
            .padding(.trailing, formSpacing)
        }
        .fileImporter(isPresented: $showImagePicker, allowedContentTypes: [.image]) { result in
            switch result {
            case .success(let url):
                if let data = try? Data(contentsOf: url), let nsImage = NSImage(data: data) {
                    iconImage = Image(nsImage: nsImage)
                    // 临时存储到本地目录
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".png")
                    try? data.write(to: tempURL)
                    gameIcon = tempURL.path
                }
            default:
                break
            }
        }
    }
    
    private var isFormValid: Bool {
        !gameName.isEmpty && !gameVersion.isEmpty
    }
    
    private func saveGame() {
        let gameInfo = GameVersionInfo(
            gameName: gameName,
            gameIcon: gameIcon,
            gameVersion: gameVersion,
            modLoader: modLoader,
            isUserAdded: true
        )
        
        // TODO: 实现游戏保存逻辑
        // 这里应该调用 GameVersionService 来保存游戏信息
        Logger.shared.info("保存游戏信息：\(gameInfo.gameName) (版本: \(gameInfo.gameVersion))")
        
        dismiss()
    }
}

// MARK: - Supporting Views
private struct FormSection<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
                .padding(8)
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.quinary.opacity(0.25))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.13), lineWidth: 0.7)
                )
        )
    }
}

private struct FormInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 250)
        }
    }
}

// MARK: - Preview
struct GameFormView_Previews: PreviewProvider {
    static var previews: some View {
        GameFormView()
    }
}


