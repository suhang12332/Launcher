import SwiftUI
import UniformTypeIdentifiers
import OSLog

// MARK: - Constants
private enum Constants {
    static let formSpacing: CGFloat = 16
    static let iconSize: CGFloat = 64
    static let cornerRadius: CGFloat = 8
    
    static let gameVersions = ["1.20.1", "1.19.4", "1.18.2"]
    static let modLoaders = ["Forge", "Fabric", "Quilt"]
    
    static let defaultIcon = "default_game_icon"
}

// MARK: - GameFormView
struct GameFormView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State private var gameName: String = ""
    @State private var gameIcon: String = Constants.defaultIcon
    @State private var iconImage: Image? = nil
    @State private var showImagePicker = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    @State private var selectedGameVersion: String
    @State private var selectedModLoader: String
    
    // MARK: - Initialization
    init() {
        _selectedGameVersion = State(initialValue: Constants.gameVersions.first ?? "")
        _selectedModLoader = State(initialValue: Constants.modLoaders.first ?? "")
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            formContentView
            Divider()
            footerView
        }
        .fileImporter(
            isPresented: $showImagePicker,
            allowedContentTypes: [.png, .jpeg, .gif],
            allowsMultipleSelection: false
        ) { result in
            handleImagePickerResult(result)
        }
        .alert("错误", isPresented: $showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - View Components
    private var headerView: some View {
            HStack {
                Text(NSLocalizedString("game.form.title", comment: "添加游戏"))
                    .font(.headline)
                .padding(Constants.formSpacing)
                Spacer()
            }
    }
    
    private var formContentView: some View {
        VStack(spacing: Constants.formSpacing) {
            gameIconAndVersionSection
            gameNameSection
        }
        .padding(Constants.formSpacing)
    }
    
    private var gameIconAndVersionSection: some View {
                FormSection {
            HStack(alignment: .top, spacing: Constants.formSpacing) {
                gameIconView
                gameVersionAndLoaderView
            }
        }
    }
    
    private var gameIconView: some View {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("game.form.icon", comment: "游戏图标"))
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            ZStack {
                if let iconImage = iconImage {
                    iconImage
                        .resizable()
                        .interpolation(.none)
                        .scaledToFill()
                        .frame(width: Constants.iconSize, height: Constants.iconSize)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                        .contentShape(Rectangle())
                } else {
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                                    .background(Color.gray.opacity(0.08))
                            }
            }
            .frame(width: Constants.iconSize, height: Constants.iconSize)
            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                            .onTapGesture {
                                showImagePicker = true
                            }
                            .onDrop(of: [UTType.image.identifier], isTargeted: nil) { providers in
                handleImageDrop(providers)
                            }
                            
                            Text(NSLocalizedString("game.form.icon.description", comment: "为游戏选择图标"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
    }
    
    private var gameVersionAndLoaderView: some View {
        VStack(alignment: .leading, spacing: Constants.formSpacing) {
            versionPicker
            modLoaderPicker
        }
    }
    
    private var versionPicker: some View {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(NSLocalizedString("game.form.version", comment: "游戏版本"))
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Picker("", selection: $selectedGameVersion) {
                ForEach(Constants.gameVersions, id: \.self) { version in
                                        Text(version).tag(version)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
    }
    
    private var modLoaderPicker: some View {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(NSLocalizedString("game.form.modloader", comment: "mod加载器"))
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Picker("", selection: $selectedModLoader) {
                ForEach(Constants.modLoaders, id: \.self) { loader in
                                        Text(loader).tag(loader)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                    }
                }
                
    private var gameNameSection: some View {
                FormSection {
                    FormInputField(
                        title: NSLocalizedString("game.form.name", comment: "游戏名称"),
                        placeholder: NSLocalizedString("game.form.name.placeholder", comment: "请输入游戏名称"),
                        text: $gameName
                    )
                }
            }
            
    private var footerView: some View {
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
        .padding(.trailing, Constants.formSpacing)
        }
    
    // MARK: - Helper Methods
    private var isFormValid: Bool {
        !gameName.isEmpty
    }
    
    private func handleImagePickerResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                showError(message: "未选择文件")
                return
            }
            
            // 开始访问文件
            guard url.startAccessingSecurityScopedResource() else {
                showError(message: "无法访问所选文件")
                return
            }
            
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            do {
                let data = try Data(contentsOf: url)
                setIconImage(from: data)
            } catch {
                showError(message: "无法读取图片文件: \(error.localizedDescription)")
            }
            
        case .failure(let error):
            showError(message: "选择图片失败: \(error.localizedDescription)")
        }
    }
    
    private func handleImageDrop(_ providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
                if let error = error {
                    DispatchQueue.main.async {
                        showError(message: "加载图片失败: \(error.localizedDescription)")
                    }
                    return
                }
                
                if let data = data {
                    DispatchQueue.main.async {
                    setIconImage(from: data)
                }
                }
            }
            return true
            }
        return false
    }
    
    private func setIconImage(from data: Data) {
        guard let nsImage = NSImage(data: data) else {
            showError(message: "无法创建图片")
            return
        }
        
        // 验证图片数据
        guard !data.isEmpty else {
            showError(message: "图片数据为空")
            return
        }
        
        // 验证图片尺寸
        let maxSize: CGFloat = 1024
        let imageSize = nsImage.size
        if imageSize.width > maxSize || imageSize.height > maxSize {
            showError(message: "图片尺寸过大，请选择小于 1024x1024 的图片")
            return
        }
        
        // 创建图片
        iconImage = Image(nsImage: nsImage)
        gameIcon = "data:image/png;base64," + data.base64EncodedString()
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    private func saveGame() {
        let gameInfo = GameVersionInfo(
            gameName: gameName,
            gameIcon: gameIcon,
            gameVersion: selectedGameVersion,
            modLoader: selectedModLoader,
            isUserAdded: true
        )
        
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
                .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .fill(Color(NSColor.quaternarySystemFill))
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
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
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Preview
struct GameFormView_Previews: PreviewProvider {
    static var previews: some View {
        GameFormView()
    }
}


