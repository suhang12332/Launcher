import SwiftUI

public enum SidebarItem: String, CaseIterable, Identifiable {
    case games
    case mods
    case dataPacks
    case shaders
    case resourcePacks
    case modPacks

    public var id: String { rawValue }

    public var localizedName: String {
        switch self {
        case .games:
            return NSLocalizedString("games", comment: "游戏")
        case .mods:
            return NSLocalizedString("mod", comment: "模组")
        case .dataPacks:
            return NSLocalizedString("datapack", comment: "数据包")
        case .shaders:
            return NSLocalizedString("shader", comment: "光影")
        case .resourcePacks:
            return NSLocalizedString("resourcepack", comment: "资源包")
        case .modPacks:
            return NSLocalizedString("modpack", comment: "整合包")
        }
    }

    public var icon: String {
        switch self {
        case .games:
            return "gamecontroller.fill"
        case .mods:
            return "puzzlepiece.extension"
        case .dataPacks:
            return "externaldrive"
        case .shaders:
            return "sun.max"
        case .resourcePacks:
            return "photo.stack"
        case .modPacks:
            return "shippingbox"
        }
    }

    public var name: String {
        switch self {
        case .games:
            return "games"
        case .mods:
            return "mod"
        case .dataPacks:
            return "datapack"
        case .shaders:
            return "shader"
        case .resourcePacks:
            return "resourcepack"
        case .modPacks:
            return "modpack"
        }
    }
}
