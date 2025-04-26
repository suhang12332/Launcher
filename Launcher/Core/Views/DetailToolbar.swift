import SwiftUI

struct DetailToolbar: View {
    var body: some View {
        Text(NSLocalizedString("game.version.title", comment: ""))
            .font(.headline)
        Spacer()
        Button(action: {}) {
            Image(systemName: "gear")
        }
        .help(NSLocalizedString("game.version.settings", comment: ""))
    }
} 