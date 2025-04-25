import SwiftUI

struct MinecraftVersionsView: View {
    let versions: [MinecraftVersion]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 8)
                ], spacing: 8) {
                    ForEach(versions) { version in
                        VersionTag(version: version)
                    }
                }
                .padding(8)
            }
        }
        .frame(width: 230, height: 100)
    }
}

struct VersionTag: View {
    let version: MinecraftVersion
    
    var body: some View {
        Text(version.id)
            .font(.system(size: 14))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    MinecraftVersionsView(versions: [
        MinecraftVersion(id: "1.20.1", type: "release", url: "", time: "", releaseTime: ""),
        MinecraftVersion(id: "1.19.4", type: "release", url: "", time: "", releaseTime: ""),
        MinecraftVersion(id: "1.18.2", type: "release", url: "", time: "", releaseTime: "")
    ])
}
