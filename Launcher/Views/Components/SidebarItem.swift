import SwiftUI

public enum SidebarItem: String, CaseIterable, Identifiable {
    case mods
    case dataPacks
    case shaders
    case resourcePacks
    case modPacks
    
    public var id: String { rawValue }
    
    public var localizedName: String {
        switch self {
        case .mods:
            return "模组"
        case .dataPacks:
            return "数据包"
        case .shaders:
            return "光影"
        case .resourcePacks:
            return "资源包"
        case .modPacks:
            return "整合包"
        }
    }
    
    public var icon: String {
        switch self {
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
} 