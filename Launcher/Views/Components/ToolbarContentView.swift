import SwiftUI

struct ToolbarContentView<Content: View, ToolbarContent: View>: View {
    let title: String
    let showDivider: Bool
    let content: Content
    let toolbarContent: ToolbarContent

    init(
        title: String,
        showDivider: Bool = true,
        @ViewBuilder content: () -> Content,
        @ViewBuilder toolbarContent: () -> ToolbarContent = { EmptyView() }
    ) {
        self.title = title
        self.showDivider = showDivider
        self.content = content()
        self.toolbarContent = toolbarContent()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .toolbar {
            ToolbarItemGroup {
                toolbarContent
            }
        }
    }
}
