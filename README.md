# Minecraft Launcher

一个使用 SwiftUI 开发的现代化 Minecraft 启动器，专为 macOS 设计。

## 功能特性

### 已实现功能
- 游戏版本管理
  - 从 Mojang API 获取所有发布版本
  - 以标签形式展示版本列表
  - 实时更新版本信息

### 计划功能
- 模组管理
- 资源包管理
- 光影包管理
- 数据包管理
- 整合包管理
- 多用户配置

## 技术栈

- **开发环境**
  - macOS Sonoma 14.3
  - Xcode 15
  - Swift 5.9
  - SwiftUI

- **系统要求**
  - macOS 13.0 或更高版本

- **主要框架和技术**
  - SwiftUI 用于用户界面
  - Combine 用于响应式编程
  - async/await 用于异步操作
  - URLSession 用于网络请求

## 项目结构

```
Launcher/
├── Core/
│   ├── Models/
│   │   ├── MinecraftVersion.swift  // 版本数据模型
│   │   └── GameState.swift         // 全局状态管理
│   ├── Services/
│   │   └── MinecraftVersionService.swift  // 版本服务
│   └── Views/
│       └── ContentView.swift       // 主视图
├── Features/
│   └── GameVersion/               // 游戏版本功能模块
│       ├── GameVersionView.swift
│       └── MinecraftVersionsView.swift
└── LauncherApp.swift              // 应用入口
```

## 开发说明

### 环境配置
1. 确保安装了最新版本的 Xcode
2. 克隆项目到本地
3. 使用 Xcode 打开 `Launcher.xcodeproj`

### 构建和运行
1. 选择目标设备为 macOS
2. 点击运行按钮或使用快捷键 `Cmd + R`

## API 参考

- 版本信息 API：
  - URL: `https://launchermeta.mojang.com/mc/game/version_manifest.json`
  - 用途：获取所有 Minecraft 版本信息

## 贡献指南

欢迎提交 Issue 和 Pull Request。在提交 PR 之前，请确保：

1. 代码符合项目的编码规范
2. 新功能有适当的测试覆盖
3. 所有测试都能通过
4. 更新了相关文档

## 许可证

[MIT License](LICENSE)
