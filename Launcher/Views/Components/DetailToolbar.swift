import SwiftUI

struct DetailToolbar: View {
    // MARK: - Properties
    let totalItems: Int
    let itemsPerPage: Int
    @Binding var currentPage: Int
    @Binding var sortIndex: String

    // MARK: - Computed Properties
    var totalPages: Int {
        max(1, Int(ceil(Double(totalItems) / Double(itemsPerPage))))
    }

    private var currentSortTitle: String {
        NSLocalizedString("menu.sort.\(sortIndex)", comment: "排序方式：%@")
    }

    // MARK: - Private Methods
    private func handlePageChange(_ increment: Int) {
        let newPage = currentPage + increment
        if newPage >= 1 && newPage <= totalPages {
            currentPage = newPage
        }
    }

    // MARK: - Body
    var body: some View {
        sortMenu
        paginationControls
        Spacer()
        translateButton
    }

    // MARK: - Subviews
    private var sortMenu: some View {
        Menu {
            ForEach(
                ["relevance", "downloads", "follows", "newest", "updated"],
                id: \.self
            ) { sort in
                Button(
                    NSLocalizedString(
                        "menu.sort.\(sort)",
                        comment: "排序方式：\(sort)"
                    )
                ) {
                    sortIndex = sort
                }
            }
        } label: {
            Text(currentSortTitle)
        }
    }

    private var paginationControls: some View {
        HStack(spacing: 8) {
            // Previous Page Button
            Button(action: { handlePageChange(-1) }) {
                Image(systemName: "chevron.left")
            }
            .disabled(currentPage == 1)

            // Page Info
            HStack(spacing: 8) {
                Text("第 \(currentPage) 页")
                Divider()
                    .frame(height: 16)
                Text("共 \(totalPages) 页")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            // Next Page Button
            Button(action: { handlePageChange(1) }) {
                Image(systemName: "chevron.right")
            }
            .disabled(currentPage == totalPages)
        }
    }

    private var translateButton: some View {
        Button(action: {
            // TODO: Implement translation functionality
        }) {
            Label(
                NSLocalizedString("toolbar.translate", comment: "翻译"),
                systemImage: "translate"
            )
        }
    }
}
