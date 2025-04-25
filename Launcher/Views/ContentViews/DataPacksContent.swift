import SwiftUI

struct DataPacksContent: View {
    var body: some View {
        List {
            Text("已安装的数据包列表将显示在这里")
        }
    }
}

#Preview {
    DataPacksContent()
        .frame(width: 300, height: 200) // 预览尺寸参考图片比例
}
