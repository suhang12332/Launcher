import SwiftUI

struct PlayerSelector: View {
    @StateObject private var playerService = PlayerService.shared
    @State private var showPopover = false
    @State private var playerToDelete: Player? = nil
    @State private var showDeleteAlert = false

    var body: some View {
        Button(action: { showPopover.toggle() }) {
            PlayerSelectorLabel(selectedPlayer: playerService.selectedPlayer)
        }
        .buttonStyle(.borderless)
        .popover(isPresented: $showPopover, arrowEdge: .trailing) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(playerService.players) { player in
                    HStack {
                        Button {
                            playerService.selectPlayer(by: player.id)
                            showPopover = false
                        } label: {
                            PlayerAvatarView(player: player, size: 28,cornerRadius: 7)
                            Text(player.name)
                        }
                        .buttonStyle(.plain)

                        Spacer(minLength: 8)

                        Button {
                            playerToDelete = player
                            showDeleteAlert = true
                        } label: {
                            Image(systemName: "person.badge.minus")
                                .help(NSLocalizedString("player.remove", comment: ""))
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                }
            }
            .frame(width: 200)
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text(NSLocalizedString("player.remove", comment: "")),
                message: Text(String(format: NSLocalizedString("player.remove.confirm", comment: "Are you sure you want to remove %@?"), playerToDelete?.name ?? "")),
                primaryButton: .destructive(Text(NSLocalizedString("player.remove", comment: ""))) {
                    if let player = playerToDelete {
                        playerService.removePlayer(by: player.id)
                    }
                    playerToDelete = nil
                },
                secondaryButton: .cancel(Text(NSLocalizedString("player.add.cancel", comment: ""))) {
                    playerToDelete = nil
                }
            )
        }
    }
}

private struct PlayerSelectorLabel: View {
    let selectedPlayer: Player?

    var body: some View {
        if let selectedPlayer = selectedPlayer {
            HStack(spacing: 6) {
                PlayerAvatarView(player: selectedPlayer, size: 22,cornerRadius: 5)
                Text(selectedPlayer.name)
                    .foregroundColor(.primary)
                    .font(.system(size: 13))
            }
        } else {
            EmptyView()
        }
    }
}

private struct PlayerAvatarView: View {
    let player: Player
    var size: CGFloat
    var cornerRadius: CGFloat
    @State private var hasLoggedLoad = false

    var body: some View {
        Image(player.avatarName)
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .drawingGroup()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .onAppear {
                if !hasLoggedLoad {
                    Logger.shared.debug("Trying to load player image: \(player.avatarName)")
                    hasLoggedLoad = true
                }
            }
    }
} 
