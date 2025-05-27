import SwiftUI
import UniformTypeIdentifiers

// MARK: - Download State
class DownloadState: ObservableObject {
    @Published var isDownloading = false
    @Published var coreProgress: Double = 0
    @Published var resourcesProgress: Double = 0
    @Published var currentCoreFile: String = ""
    @Published var currentResourceFile: String = ""
    @Published var coreTotalFiles: Int = 0
    @Published var resourcesTotalFiles: Int = 0
    @Published var coreCompletedFiles: Int = 0
    @Published var resourcesCompletedFiles: Int = 0
    @Published var isCancelled = false
    
    func reset() {
        isDownloading = false
        coreProgress = 0
        resourcesProgress = 0
        currentCoreFile = ""
        currentResourceFile = ""
        coreTotalFiles = 0
        resourcesTotalFiles = 0
        coreCompletedFiles = 0
        resourcesCompletedFiles = 0
        isCancelled = false
    }
    
    func startDownload(coreTotalFiles: Int, resourcesTotalFiles: Int) {
        self.coreTotalFiles = coreTotalFiles
        self.resourcesTotalFiles = resourcesTotalFiles
        self.isDownloading = true
        self.coreProgress = 0
        self.resourcesProgress = 0
        self.coreCompletedFiles = 0
        self.resourcesCompletedFiles = 0
        self.isCancelled = false
    }
    
    func cancel() {
        isCancelled = true
    }
    
    func updateProgress(fileName: String, completed: Int, total: Int, type: MinecraftFileManager.DownloadType) {
        switch type {
        case .core:
            self.currentCoreFile = fileName
            self.coreCompletedFiles = completed
            self.coreTotalFiles = total
            self.coreProgress = Double(completed) / Double(total)
        case .resources:
            self.currentResourceFile = fileName
            self.resourcesCompletedFiles = completed
            self.resourcesTotalFiles = total
            self.resourcesProgress = Double(completed) / Double(total)
        }
    }
}

// MARK: - Constants
private enum Constants {
    static let formSpacing: CGFloat = 16
    static let iconSize: CGFloat = 64
    static let cornerRadius: CGFloat = 8
    static let maxImageSize: CGFloat = 1024
    static let defaultAppName = "YourLauncherApp"
}

// MARK: - GameFormView
struct GameFormView: View {
    @EnvironmentObject var gameStorageManager: GameStorageManager
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    @StateObject private var downloadState = DownloadState()
    @State private var gameName = ""
    @State private var gameIcon = AppConstants.defaultGameIcon
    @State private var iconImage: Image?
    @State private var showImagePicker = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var selectedGameVersion = ""
    @State private var selectedModLoader = AppConstants.modLoaders.first ?? ""
    @State private var mojangVersions: [MojangVersionInfo] = []
    @State private var isLoadingVersions = true
    
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
        .task {
            await loadVersions()
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
            if downloadState.isDownloading {
                downloadProgressSection
            }
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
            if isLoadingVersions {
                ProgressView()
                    .controlSize(.small)
            } else {
                Picker("", selection: $selectedGameVersion) {
                    ForEach(mojangVersions, id: \.id) {
                        Text($0.id).tag($0.id)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
    }
    
    private var modLoaderPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("game.form.modloader", comment: "mod加载器"))
                .font(.subheadline)
                .foregroundColor(.primary)
            Picker("", selection: $selectedModLoader) {
                ForEach(AppConstants.modLoaders, id: \.self) {
                    Text($0).tag($0)
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
    
    private var downloadProgressSection: some View {
        VStack(spacing: Constants.formSpacing) {
            // Core files download progress
            FormSection {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(NSLocalizedString("download.core.title", comment: "Core Files"))
                            .font(.headline)
                        Spacer()
                        Text(String(format: NSLocalizedString("download.progress", comment: "%d%%"), Int(downloadState.coreProgress * 100)))
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: downloadState.coreProgress)
                    
                    HStack {
                        Text(String(format: NSLocalizedString("download.current.file", comment: "Current File: %@"), downloadState.currentCoreFile))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: NSLocalizedString("download.files", comment: "%d/%d"), downloadState.coreCompletedFiles, downloadState.coreTotalFiles))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Resources download progress
            FormSection {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(NSLocalizedString("download.resources.title", comment: "Resource Files"))
                            .font(.headline)
                        Spacer()
                        Text(String(format: NSLocalizedString("download.progress", comment: "%d%%"), Int(downloadState.resourcesProgress * 100)))
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: downloadState.resourcesProgress)
                    
                    HStack {
                        Text(String(format: NSLocalizedString("download.current.file", comment: "Current File: %@"), downloadState.currentResourceFile))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: NSLocalizedString("download.files", comment: "%d/%d"), downloadState.resourcesCompletedFiles, downloadState.resourcesTotalFiles))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var footerView: some View {
        HStack(spacing: 12) {
            Spacer()
            Button(NSLocalizedString("common.cancel", comment: "取消")) {
                if downloadState.isDownloading {
                    downloadState.cancel()
                } else {
                    dismiss()
                }
            }
            .keyboardShortcut(.cancelAction)
            
            if downloadState.isDownloading {
                ProgressView()
                    .controlSize(.small)
                    .frame(width: 60)
            } else {
                Button(NSLocalizedString("common.confirm", comment: "确认")) {
                    Task {
                        await saveGame()
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isFormValid)
            }
        }
        .padding(.vertical, 20)
        .padding(.trailing, Constants.formSpacing)
    }
    
    // MARK: - Helper Methods
    private var isFormValid: Bool {
        !gameName.isEmpty
    }
    
    private func loadVersions() async {
        isLoadingVersions = true
        do {
            let mojangManifest = try await MinecraftService.fetchVersionManifest()
            let releaseVersions = mojangManifest.versions.filter { $0.type == "release" }
            
            await MainActor.run {
                self.mojangVersions = releaseVersions
                if let firstVersion = releaseVersions.first {
                    self.selectedGameVersion = firstVersion.id
                }
                self.isLoadingVersions = false
            }
        } catch {
            await MainActor.run {
                showError(message: "加载数据失败: \(error.localizedDescription)")
                self.isLoadingVersions = false
            }
        }
    }
    
    private func handleImagePickerResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                showError(message: "未选择文件")
                return
            }
            
            guard url.startAccessingSecurityScopedResource() else {
                showError(message: "无法访问所选文件")
                return
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            
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
        
        guard !data.isEmpty else {
            showError(message: "图片数据为空")
            return
        }
        
        let imageSize = nsImage.size
        if imageSize.width > Constants.maxImageSize || imageSize.height > Constants.maxImageSize {
            showError(message: "图片尺寸过大，请选择小于 1024x1024 的图片")
            return
        }
        
        iconImage = Image(nsImage: nsImage)
        gameIcon = "data:image/png;base64," + data.base64EncodedString()
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    private func saveGame() async {
        let gameInfo = GameVersionInfo(
            gameName: gameName,
            gameIcon: gameIcon,
            gameVersion: selectedGameVersion,
            modLoader: selectedModLoader,
            isUserAdded: true
        )
        
        Logger.shared.info("保存游戏信息：\(gameInfo.gameName) (版本: \(gameInfo.gameVersion))")
        
        guard let mojangVersion = mojangVersions.first(where: { $0.id == selectedGameVersion }) else {
            Logger.shared.warning("Could not find Mojang version info for selected version: \(selectedGameVersion)")
            await MainActor.run {
                showError(message: "找不到对应版本的下载信息")
            }
            return
        }
        
        do {
            let manifestData = try await URLSession.shared.data(from: mojangVersion.url).0
            let downloadedManifest = try JSONDecoder().decode(MinecraftVersionManifest.self, from: manifestData)
            
            guard let applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                Logger.shared.error("Could not find Application Support directory.")
                await MainActor.run {
                    showError(message: "无法找到应用程序支持目录")
                }
                return
            }
            
            let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? Constants.defaultAppName
            let launcherSupportDirectory = applicationSupportDirectory.appendingPathComponent(appName)
            let metaDirectory = launcherSupportDirectory.appendingPathComponent("meta")
            let profileDirectoryName = "\(downloadedManifest.id)-\(selectedModLoader)"
            let profileDirectory = launcherSupportDirectory.appendingPathComponent("profiles").appendingPathComponent(profileDirectoryName)
            
            let fileManager = MinecraftFileManager(metaDirectory: metaDirectory, profileDirectory: profileDirectory)
            
            // Start download with combined progress tracking
            await MainActor.run {
                downloadState.startDownload(
                    coreTotalFiles: 1 + downloadedManifest.libraries.count + 1,
                    resourcesTotalFiles: 0 // Will be updated when asset index is parsed
                )
            }
            
            fileManager.onProgressUpdate = { fileName, completed, total, type in
                Task { @MainActor in
                    if downloadState.isCancelled {
                        throw MinecraftFileManagerError.requestFailed(URLError(.cancelled))
                    }
                    downloadState.updateProgress(fileName: fileName, completed: completed, total: total, type: type)
                }
            }
            
            // Download all files (core files and assets) concurrently
            try await fileManager.downloadVersionFiles(manifest: downloadedManifest)
            
            // Add the game to storage
            gameStorageManager.addGame(gameInfo)
            
            // Dismiss the view
            await MainActor.run {
                dismiss()
            }
            
        } catch {
            Logger.shared.error("Error saving game or downloading files: \(error)")
            await MainActor.run {
                if downloadState.isCancelled {
                    showError(message: "下载已取消")
                } else {
                    showError(message: "保存游戏或下载文件失败: \(error.localizedDescription)")
                }
                downloadState.reset()
            }
        }
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


