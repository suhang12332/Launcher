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
            return NSLocalizedString("sidebar.mods", comment: "")
        case .dataPacks:
            return NSLocalizedString("sidebar.dataPacks", comment: "")
        case .shaders:
            return NSLocalizedString("sidebar.shaders", comment: "")
        case .resourcePacks:
            return NSLocalizedString("sidebar.resourcePacks", comment: "")
        case .modPacks:
            return NSLocalizedString("sidebar.modPacks", comment: "")
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