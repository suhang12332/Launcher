# Minecraft Launcher

一个现代化的 Minecraft 启动器，使用 SwiftUI 构建，专为 macOS 设计。

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

## 项目结构

```
Launcher/
├── LauncherApp.swift          # 应用程序入口点
├── Launcher.entitlements      # 应用程序权限配置
│
├── Core/                      # 核心功能模块
│   ├── Config/               # 配置管理
│   │   ├── AppConfig.swift   # 应用程序配置
│   │   └── UserConfig.swift  # 用户配置
│   │
│   ├── Services/             # 服务层
│   │   ├── AuthService.swift # 认证服务
│   │   ├── GameService.swift # 游戏服务
│   │   └── UpdateService.swift # 更新服务
│   │
│   ├── Utils/                # 工具类
│   │   ├── FileManager.swift # 文件管理
│   │   └── Logger.swift      # 日志工具
│   │
│   └── Views/                # 核心视图组件
│       ├── AddPlayerAlertView.swift # 添加玩家弹窗
│       └── ContentTool.swift # 内容工具视图
│
├── Views/                     # 界面视图
│   ├── Components/           # 可复用组件
│   │   ├── PlayerMenuView.swift    # 玩家菜单
│   │   ├── PlayerComponents.swift  # 玩家相关组件
│   │   └── PlayerSelector.swift    # 玩家选择器
│   │
│   ├── Player/               # 玩家相关视图
│   │   └── PlayerProfileView.swift # 玩家资料视图
│   │
│   └── Settings/             # 设置相关视图
│
├── Features/                  # 功能模块
│   ├── VersionManager/       # 版本管理
│   ├── ModManager/           # Mod 管理
│   └── ResourceManager/      # 资源管理
│
├── Resources/                # 资源文件
│   ├── en.lproj/            # 英文本地化
│   ├── zh-Hans.lproj/       # 简体中文本地化
│   └── zh-Hant.lproj/       # 繁体中文本地化
│
└── Assets.xcassets/         # 资源文件
    ├── AppIcon.appiconset/  # 应用图标
    └── Colors.colorset/     # 颜色资源
```

### 主要目录说明

#### Core/
- **Config/**: 管理应用程序和用户的配置信息
  - `AppConfig.swift`: 处理应用程序级别的配置
  - `UserConfig.swift`: 管理用户特定的设置和偏好

- **Services/**: 提供核心业务逻辑服务
  - `AuthService.swift`: 处理用户认证和授权
  - `GameService.swift`: 管理游戏启动和运行
  - `UpdateService.swift`: 处理应用程序和游戏更新

- **Utils/**: 提供通用工具类
  - `FileManager.swift`: 处理文件操作
  - `Logger.swift`: 提供日志记录功能

- **Views/**: 包含核心视图组件
  - `AddPlayerAlertView.swift`: 添加新玩家的界面
  - `ContentTool.swift`: 内容管理工具界面

#### Views/
- **Components/**: 可复用的UI组件
  - `PlayerMenuView.swift`: 玩家菜单组件
  - `PlayerComponents.swift`: 玩家相关UI组件
  - `PlayerSelector.swift`: 玩家选择器组件

- **Player/**: 玩家相关视图
  - `PlayerProfileView.swift`: 玩家资料展示界面

- **Settings/**: 应用程序设置界面

#### Features/
- **VersionManager/**: 管理 Minecraft 版本
- **ModManager/**: 处理 Mod 的安装和管理
- **ResourceManager/**: 管理资源包和光影

#### Resources/
- 包含多语言本地化文件
  - `en.lproj/`: 英文资源
  - `zh-Hans.lproj/`: 简体中文资源
  - `zh-Hant.lproj/`: 繁体中文资源

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
