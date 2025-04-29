import SwiftUI

struct DetailToolbar: View {
    let totalItems: Int
    let itemsPerPage: Int
    @Binding var currentPage: Int

    var totalPages: Int {
        max(1, Int(ceil(Double(totalItems) / Double(itemsPerPage))))
    }

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Button(action: { if currentPage > 1 { currentPage -= 1 } }) {
                    Image(systemName: "chevron.left")
                }
                .disabled(currentPage == 1)
                HStack(spacing: 8) {
                    Text("第 \(currentPage) 页")
                    Divider()
                        .frame(height: 16)
                    Text("共 \(totalPages) 页")
                }
                .font(.subheadline)
                Button(action: { if currentPage < totalPages { currentPage += 1 } }) {
                    Image(systemName: "chevron.right")
                }
                .disabled(currentPage == totalPages)
            }
            .padding(.horizontal, 8)
            // 设置按钮
            Button(action: {}) {
                Image(systemName: "gear")
            }
            .help(NSLocalizedString("game.version.settings", comment: ""))
        }
    }
} 
