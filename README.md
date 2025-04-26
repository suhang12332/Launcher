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
├── Core/           # 核心功能模块
│   ├── Config/     # 配置相关
│   ├── Services/   # 服务层
│   ├── Utils/      # 工具类
│   └── Views/      # 核心视图组件
├── Views/          # 界面视图
│   ├── Components/ # 可复用组件
│   ├── Player/     # 玩家相关视图
│   └── Settings/   # 设置相关视图
└── Resources/      # 资源文件
    ├── en.lproj/   # 英文本地化
    ├── zh-Hans.lproj/ # 简体中文本地化
    └── zh-Hant.lproj/ # 繁体中文本地化
```

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
