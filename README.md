# Minecraft Launcher

一个现代化的 Minecraft 启动器，使用 SwiftUI 构建，专为 macOS 设计。该启动器提供流畅的用户体验，支持多语言、多玩家配置、Mod 管理、资源包和光影管理等功能，让玩家轻松管理和启动 Minecraft。

## 主要特点

- **现代化界面**：采用 SwiftUI 构建，提供流畅、直观的用户界面，符合 macOS 设计规范。
- **多语言支持**：支持英文、简体中文和繁体中文，满足不同地区玩家的需求。
- **多玩家配置**：支持多个玩家配置，轻松切换不同玩家的游戏设置和皮肤。
- **Mod 管理**：集成 Modrinth，支持 Mod 的安装、更新和版本兼容性检查。
- **资源管理**：支持资源包和光影的管理，让玩家轻松定制游戏体验。
- **自动更新**：支持 Minecraft 版本和启动器的自动更新，确保玩家始终使用最新版本。
- **原生体验**：专为 macOS 设计，充分利用 macOS 的特性，提供最佳的用户体验。

## 功能特性

- 🎮 管理多个 Minecraft 版本
- 👥 支持多玩家配置
- 🔄 自动更新和版本管理
- 🎨 支持 Mod、资源包和光影
- 🌐 多语言支持（英文、简体中文、繁体中文）
- 🎯 原生 macOS 体验

## 系统要求

- macOS 13.0 或更高版本
- Apple Silicon 或 Intel 处理器

## 开发环境

- Xcode 15.0 或更高版本
- Swift 5.9 或更高版本

## 安装说明

1. 克隆仓库：
```bash
git clone https://github.com/suhang12332/Launcher.git
```

2. 打开项目：
```bash
cd Launcher
open Launcher.xcodeproj
```

3. 在 Xcode 中构建和运行项目

## 功能模块

### 版本管理
- 支持所有官方版本
- 自动下载和安装
- 版本隔离

### 玩家管理
- 多账户支持
- 皮肤预览
- 账户切换

### Mod 管理
- 支持 Modrinth
- 自动依赖处理
- 版本兼容性检查

### 资源管理
- 资源包管理
- 光影包管理
- 数据包管理

## Project Structure

The project follows a standard Swift/SwiftUI layout:

```
Launcher/
├── LauncherApp.swift
├── Models/
├── Views/
├── Services/
├── Utils/
├── Config/
├── Features/
├── Repositories/
├── Resources/
│   ├── en.lproj/
│   ├── zh-Hans.lproj/
│   ├── zh-Hant.lproj/
│   └── ...
├── Assets.xcassets/
└── Launcher.entitlements
```

- **Models/**: Data structures and entity models.
- **Views/**: SwiftUI views, organized by screens and components.
- **Services/**: Network, data, and API services.
- **Utils/**: Utility classes, helper functions, and global managers.
- **Config/**: Configuration files and settings.
- **Features/**: Feature-specific modules and components.
- **Repositories/**: Data access and storage implementations.
- **Resources/**: Localization files and other resources.
- **Assets.xcassets/**: Images, icons, and other assets.

## 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 开源协议

本项目采用 MIT 协议 - 查看 [LICENSE](LICENSE) 文件了解更多详情。

<!-- ## 致谢

- [Modrinth](https://modrinth.com/) - Mod 平台支持
- [Mojang](https://www.mojang.com/) - Minecraft 官方支持 -->
