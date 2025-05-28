//import SwiftUI
//
//struct InspectorToolbar: View {
//    @Binding var showingInspector: Bool
//
//    var body: some View {
//
//        Button(action: {
//            withAnimation {
//                showingInspector.toggle()
//            }
//        }) {
//            Image(systemName: showingInspector ? "sidebar.right" : "sidebar.left")
//        }
//        .help(showingInspector ?
//            NSLocalizedString("game.version.inspector.hide", comment: "") :
//            NSLocalizedString("game.version.inspector.show", comment: ""))
//    }
//}
