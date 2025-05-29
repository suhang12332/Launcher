import SwiftUI

struct ProjectDetailTabPicker: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        Picker("视图模式", selection: $selectedTab) {
            Label("详情", systemImage: "doc.text").tag(0)
            Label("下载", systemImage: "arrow.down.square").tag(1)
            Label("画廊", systemImage: "photo.on.rectangle").tag(2)
        }
        .pickerStyle(.segmented)
        .background(.clear)
    }
}

#Preview {
    ProjectDetailTabPicker(selectedTab: .constant(0))
        .padding()
} 