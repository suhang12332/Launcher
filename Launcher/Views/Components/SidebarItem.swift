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
            return NSLocalizedString("mod", comment: "")
        case .dataPacks:
            return NSLocalizedString("datapack", comment: "")
        case .shaders:
            return NSLocalizedString("shader", comment: "")
        case .resourcePacks:
            return NSLocalizedString("resourcepack", comment: "")
        case .modPacks:
            return NSLocalizedString("modpack", comment: "")
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
    
    public var name: String {
        switch self {
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
