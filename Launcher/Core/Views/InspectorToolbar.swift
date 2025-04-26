import SwiftUI

struct InspectorToolbar: View {
    @Binding var showingInspector: Bool
    
    var body: some View {
        Text(NSLocalizedString("game.version.title", comment: ""))
            .font(.headline)
        Spacer()
        Button(action: {}) {
            Image(systemName: "gear")
        }
        .help(NSLocalizedString("game.version.settings", comment: ""))
        Spacer()
        Button(action: {
            withAnimation {
                showingInspector.toggle()
            }
        }) {
            Image(systemName: showingInspector ? "sidebar.right" : "sidebar.left")
        }
        .help(showingInspector ? 
            NSLocalizedString("game.version.inspector.hide", comment: "") :
            NSLocalizedString("game.version.inspector.show", comment: ""))
    }
} 