import SwiftUI
import UniformTypeIdentifiers
import UserNotifications

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

    func updateProgress(
        fileName: String,
        completed: Int,
        total: Int,
        type: MinecraftFileManager.DownloadType
    ) {
        switch type {
        case .core:
            self.currentCoreFile = fileName
            self.coreCompletedFiles = completed
            self.coreTotalFiles = total
            // Clamp progress value to 0.0...1.0
            if total > 0 {
                self.coreProgress = max(0.0, min(1.0, Double(completed) / Double(total)))
            } else {
                self.coreProgress = 0.0 // Avoid division by zero
            }
        case .resources:
            self.currentResourceFile = fileName
            self.resourcesCompletedFiles = completed
            self.resourcesTotalFiles = total
            // Clamp progress value to 0.0...1.0
            if total > 0 {
                self.resourcesProgress = max(0.0, min(1.0, Double(completed) / Double(total)))
            } else {
                 self.resourcesProgress = 0.0 // Avoid division by zero
            }
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
    @EnvironmentObject var gameRepository: GameRepository
    @Environment(\.dismiss) private var dismiss

    // MARK: - State
    @StateObject private var downloadState = DownloadState()
    @State private var gameName = ""
    @State private var gameIcon = AppConstants.defaultGameIcon
    @State private var iconImage: Image?
    @State private var showImagePicker = false
    @State private var selectedGameVersion = ""
    @State private var selectedModLoader = AppConstants.modLoaders.first ?? ""
    @State private var mojangVersions: [MojangVersionInfo] = []
    @State private var isLoadingVersions = true
    
    // Store the download task reference
    @State private var downloadTask: Task<Void, Error>? = nil

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
        .task {
            // Request notification authorization and load versions
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
                if granted {
                    Logger.shared.info("通知权限已授予")
                } else {
                    Logger.shared.warning("用户拒绝了通知权限")
                }
                
                // Load versions after handling notifications, within the same catch block
                await loadVersions()
                
            } catch {
                Logger.shared.error("初始设置过程中出错（通知或加载版本）：\(error.localizedDescription)")
                // Depending on the severity of the error (e.g., versions failed to load),
                // you might want to set a state variable here to show a persistent error message to the user.
            }
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
                        .frame(
                            width: Constants.iconSize,
                            height: Constants.iconSize
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: Constants.cornerRadius
                            )
                        )
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
            .onDrop(of: [UTType.image.identifier], isTargeted: nil) {
                providers in
                handleImageDrop(providers)
                            }
                            
            Text(
                NSLocalizedString(
                    "game.form.icon.description",
                    comment: "为游戏选择图标"
                )
            )
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
            Text(NSLocalizedString("game.form.modloader", comment: "模组加载器"))
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
                placeholder: NSLocalizedString(
                    "game.form.name.placeholder",
                    comment: "请输入游戏名称"
                ),
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
                        Text(
                            NSLocalizedString(
                                "download.core.title",
                                comment: "核心文件"
                            )
                        )
                        .font(.headline)
                        Spacer()
                        Text(
                            String(
                                format: NSLocalizedString(
                                    "download.progress",
                                    comment: "进度：%d%%"
                                ),
                                Int(downloadState.coreProgress * 100)
                            )
                        )
                        .font(.headline)
                        .foregroundColor(.secondary)
                    }

                    ProgressView(value: downloadState.coreProgress)

                    HStack {
                        Text(
                            String(
                                format: NSLocalizedString(
                                    "download.current.file",
                                    comment: "当前文件：%@"
                                ),
                                downloadState.currentCoreFile
                            )
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                        Spacer()
                        Text(
                            String(
                                format: NSLocalizedString(
                                    "download.files",
                                    comment: "文件：%d/%d"
                                ),
                                downloadState.coreCompletedFiles,
                                downloadState.coreTotalFiles
                            )
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
            }

            // Resources download progress
                FormSection {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(
                            NSLocalizedString(
                                "download.resources.title",
                                comment: "资源文件"
                            )
                        )
                        .font(.headline)
                        Spacer()
                        Text(
                            String(
                                format: NSLocalizedString(
                                    "download.progress",
                                    comment: "进度：%d%%"
                                ),
                                Int(downloadState.resourcesProgress * 100)
                            )
                        )
                        .font(.headline)
                        .foregroundColor(.secondary)
                    }

                    ProgressView(value: downloadState.resourcesProgress)

                    HStack {
                        Text(
                            String(
                                format: NSLocalizedString(
                                    "download.current.file",
                                    comment: "当前文件：%@"
                                ),
                                downloadState.currentResourceFile
                            )
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                        Spacer()
                        Text(
                            String(
                                format: NSLocalizedString(
                                    "download.files",
                                    comment: "文件：%d/%d"
                                ),
                                downloadState.resourcesCompletedFiles,
                                downloadState.resourcesTotalFiles
                            )
                        )
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
                // Cancel download task if it exists, otherwise dismiss
                if downloadState.isDownloading, let task = downloadTask {
                    task.cancel()
                    // No UI immediate feedback other than button state
                } else {
                    // If not downloading, just dismiss the form
                    dismiss()
                }
                }
                .keyboardShortcut(.cancelAction)
                
            Button {
                // Assign the task to the state property
                downloadTask = Task {
                    await saveGame()
                }
            } label: {
                HStack {
                    Text(NSLocalizedString("common.confirm", comment: "确认"))
                    if downloadState.isDownloading {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
                }
                .keyboardShortcut(.defaultAction)
            .disabled(!isFormValid || downloadState.isDownloading)
            }
            .padding(.vertical, 20)
        .padding(.trailing, Constants.formSpacing)
        }

    // MARK: - Helper Methods
    private var isFormValid: Bool {
        !gameName.isEmpty
    }
    
    // Unified error handling for non-critical errors
    private func handleNonCriticalError(_ error: Error, message: String) {
        Logger.shared.error("\(message): \(error.localizedDescription)")
        // Optional: Add state variable here to show a non-blocking visual indicator if needed
    }

    private func loadVersions() async {
        isLoadingVersions = true
        do {
            let mojangManifest =
                try await MinecraftService.fetchVersionManifest()
            let releaseVersions = mojangManifest.versions.filter {
                $0.type == "release"
            }

            await MainActor.run {
                self.mojangVersions = releaseVersions
                if let firstVersion = releaseVersions.first {
                    self.selectedGameVersion = firstVersion.id
                }
                self.isLoadingVersions = false
            }
        } catch {
            await MainActor.run { // Ensure state updates are on MainActor
                self.isLoadingVersions = false
                handleNonCriticalError(error, message: "加载版本数据失败")
            }
        }
    }

    private func handleImagePickerResult(_ result: Result<[URL], Error>) {
            switch result {
        case .success(let urls):
            guard let url = urls.first else {
                handleNonCriticalError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "未选择文件"]), message: "图片选择失败")
                return
            }

            guard url.startAccessingSecurityScopedResource() else {
                handleNonCriticalError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "无法访问所选文件"]), message: "图片访问失败")
                return
            }

            defer { url.stopAccessingSecurityScopedResource() }
            
            // Use asynchronous file reading
            Task { @MainActor in
                do {
                    let data = try Data(contentsOf: url)
                    setIconImage(from: data)
                } catch {
                    handleNonCriticalError(error, message: "无法读取图片文件")
                }
            }
            
        case .failure(let error):
            handleNonCriticalError(error, message: "选择图片失败")
            }
        }

    private func handleImageDrop(_ providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else {
             // Log error for empty provider
            Logger.shared.error("图片拖放失败：没有提供者")
            return false
        }

        if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
                if let error = error {
                    DispatchQueue.main.async {
                        handleNonCriticalError(error, message: "加载拖拽图片失败")
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
         // Log error for unsupported type
        Logger.shared.warning("图片拖放失败：不支持的类型")
        return false
    }

    private func setIconImage(from data: Data) {
        guard let nsImage = NSImage(data: data) else {
            handleNonCriticalError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "无法创建图片"]), message: NSLocalizedString("error.image.create.failed", comment: "无法创建图片"))
            return
        }

        guard !data.isEmpty else {
            handleNonCriticalError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "图片数据为空"]), message: NSLocalizedString("error.image.data.empty", comment: "图片数据为空"))
            return
        }

        let imageSize = nsImage.size
        if imageSize.width > Constants.maxImageSize
            || imageSize.height > Constants.maxImageSize
        {
            handleNonCriticalError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("error.image.size.large", comment: "图片尺寸过大，请选择小于 \(Int(Constants.maxImageSize))x\(Int(Constants.maxImageSize)) 的图片")]), message: NSLocalizedString("error.image.size", comment: "图片尺寸错误"))
            return
        }

        iconImage = Image(nsImage: nsImage)
        gameIcon = "data:image/png;base64," + data.base64EncodedString()
    }
    
    // Main function to save game and initiate download
    private func saveGame() async {
        await MainActor.run { // Ensure state updates are on MainActor
            downloadState.reset()
        }
        
        let gameInfo = GameVersionInfo(
            gameName: gameName,
            gameIcon: gameIcon,
            gameVersion: selectedGameVersion,
            modLoader: selectedModLoader,
            isUserAdded: true,
            createdAt: Date(),
            lastPlayed: Date(),
            isRunning: false
        )
        
        Logger.shared.info("保存游戏信息：\(gameInfo.gameName) (版本: \(gameInfo.gameVersion))")

        guard
            let mojangVersion = mojangVersions.first(where: { $0.id == selectedGameVersion })
        else {
            Logger.shared.warning("找不到所选版本的 Mojang 版本信息：\(selectedGameVersion)")
            // This is a non-critical error in terms of app stability, but indicates a data issue.
            handleNonCriticalError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("error.version.info.missing", comment: "找不到对应版本的下载信息")]), message: NSLocalizedString("error.version.info.fetch", comment: "获取版本信息失败"))
            // Consider if you want to keep the form open or dismiss here
            return
        }
        
        do {
            let downloadedManifest = try await fetchMojangManifest(from: mojangVersion.url)
            let fileManager = try await setupFileManager(manifest: downloadedManifest, modLoader: gameInfo.modLoader)
            
            await startDownloadProcess(fileManager: fileManager, manifest: downloadedManifest)
            
            // Add the game to storage only if download completed without cancellation
            try Task.checkCancellation() // Check cancellation one last time before saving
            gameRepository.addGame(gameInfo)
            
            // Send success notification
            sendNotification(title: NSLocalizedString("notification.download.complete.title", comment: "下载完成"), body: String(format: NSLocalizedString("notification.download.complete.body", comment: "%%@ (版本: %%@, 加载器: %%@) 已成功下载。"), gameInfo.gameName, gameInfo.gameVersion, gameInfo.modLoader))
            
            await handleDownloadSuccess()
            
        } catch is CancellationError { // Handle explicit cancellation
            await handleDownloadCancellation()
        } catch { // Handle other errors (download or file operations)
             await handleDownloadFailure(gameInfo: gameInfo, error: error)
        }
        
        // Clear the task reference after completion or cancellation
        await MainActor.run { // Ensure state updates are on MainActor
            downloadTask = nil
        }
    }
    
    // Helper method to fetch Mojang Manifest
    private func fetchMojangManifest(from url: URL) async throws -> MinecraftVersionManifest {
        Logger.shared.info("正在从以下地址获取 Mojang 版本清单：\(url.absoluteString)")
        let (manifestData, _) = try await URLSession.shared.data(from: url)
        let downloadedManifest = try JSONDecoder().decode(MinecraftVersionManifest.self, from: manifestData)
        Logger.shared.info("成功获取版本清单：\(downloadedManifest.id)")
        return downloadedManifest
    }
    
    // Helper method to set up MinecraftFileManager and directories
    private func setupFileManager(manifest: MinecraftVersionManifest, modLoader: String) async throws -> MinecraftFileManager {
        guard let applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            Logger.shared.error("无法找到应用程序支持目录")
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("error.app.support.missing", comment: "无法找到应用程序支持目录")])
        }

        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? Constants.defaultAppName
        let launcherSupportDirectory = applicationSupportDirectory.appendingPathComponent(appName)
        let metaDirectory = launcherSupportDirectory.appendingPathComponent("meta")
        let profileDirectoryName = "\(manifest.id)-\(modLoader)"
        let profileDirectory = launcherSupportDirectory.appendingPathComponent("profiles").appendingPathComponent(profileDirectoryName)

        return MinecraftFileManager(metaDirectory: metaDirectory, profileDirectory: profileDirectory)
    }
    
    // Helper method to initiate the download process
    private func startDownloadProcess(fileManager: MinecraftFileManager, manifest: MinecraftVersionManifest) async {
         // Start download with combined progress tracking
        await MainActor.run { // Ensure state updates are on MainActor
            downloadState.startDownload(
                coreTotalFiles: 1 + manifest.libraries.count + 1, // Client JAR + Libraries + Asset Index
                resourcesTotalFiles: 0  // Will be updated when asset index is parsed
            )
        }

        fileManager.onProgressUpdate = { fileName, completed, total, type in
            // Progress update closure - check for cancellation here too as a fallback
            Task { @MainActor in // Ensure state updates are on MainActor
                if Task.isCancelled { // Check task cancellation
                    // The primary cancellation signal comes from task.cancel() on the main downloadTask.
                    // Just update state and let the main task handle the CancellationError.
                }
                downloadState.updateProgress(fileName: fileName, completed: completed, total: total, type: type)
            }
        }
        
        // Download all files (core files and assets) concurrently
        // The TaskGroup and URLSession tasks within downloadVersionFiles
        // should respond to cancellation of the parent Task.
        // This call is now in the main do block and its errors are caught there.
    }
    
    // Helper method to handle successful download completion
    private func handleDownloadSuccess() async {
        Logger.shared.info("下载和保存成功")
        await MainActor.run { // Ensure dismiss is on MainActor
        dismiss()
    }
    }
    
    // Helper method to handle download cancellation
    private func handleDownloadCancellation() async {
        Logger.shared.info("游戏下载任务已取消")
        // No notification or alert on cancellation, just reset state and dismiss
        await MainActor.run { // Ensure state updates are on MainActor
            downloadState.reset()
            dismiss() // Dismiss the view on cancellation
        }
    }
    
    // Helper method to handle download failure (non-cancellation errors)
    private func handleDownloadFailure(gameInfo: GameVersionInfo, error: Error) async {
        Logger.shared.error("保存游戏或下载文件时出错：\(error)")
        // Send error notification
        sendNotification(title: NSLocalizedString("notification.download.failed.title", comment: "下载失败"), body: String(format: NSLocalizedString("notification.download.failed.body", comment: "%%@ (版本: %%@, 加载器: %%@) 下载失败: %%@"), gameInfo.gameName, gameInfo.gameVersion, gameInfo.modLoader, error.localizedDescription))
        
        await MainActor.run { // Ensure state updates are on MainActor
            downloadState.reset()
            // Keep the form open to show the error if dismissal is removed from here
            // If we want to dismiss on failure too, add dismiss() here
        }
    }
    
    // Helper function to send a local notification
    private func sendNotification(title: String, body: String) {
        Logger.shared.info("准备发送通知：\(title) - \(body)")
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.shared.error("添加通知请求时出错：\(error.localizedDescription)")
            } else {
                Logger.shared.info("成功添加通知请求：\(request.identifier)")
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
