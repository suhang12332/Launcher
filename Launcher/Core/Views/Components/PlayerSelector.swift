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
                if playerService.players.isEmpty {
                    ProgressView()
                        .controlSize(.small)
                        .padding()
                } else {
                    ForEach(playerService.players) { player in
                        HStack {
                            Button {
                                Task {
                                    try? await playerService.selectPlayer(player)
                                    showPopover = false
                                }
                            } label: {
                                PlayerAvatarView(player: player)
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
            }
            .frame(width: 200)
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text(NSLocalizedString("player.remove", comment: "")),
                message: Text(String(format: NSLocalizedString("player.remove.confirm", comment: "Are you sure you want to remove %@?"), playerToDelete?.name ?? "")),
                primaryButton: .destructive(Text(NSLocalizedString("player.remove", comment: ""))) {
                    if let player = playerToDelete {
                        playerService.removePlayer(player)
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
                PlayerAvatarView(player: selectedPlayer, size: 28)
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
    var size: CGFloat = 28
    var cornerRadius: CGFloat = 7
    @State private var hasLoggedLoad = false

    var body: some View {
        let uuid = player.id.uuidString
        if let avatarName = NameAvatarMapper.avatarName(for: uuid) {
            Image(avatarName)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .drawingGroup()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .onAppear {
                    if !hasLoggedLoad {
                        Logger.shared.debug("Trying to load player image: \(avatarName)")
                        hasLoggedLoad = true
                    }
                }
        } else {
            Image(systemName: "person.circle.fill")
                .foregroundStyle(.secondary)
                .imageScale(.small)
                .frame(width: size, height: size)
                .onAppear {
                    if !hasLoggedLoad {
                        Logger.shared.warning("Failed to map player UUID to avatar name: \(uuid)")
                        hasLoggedLoad = true
                    }
                }
        }
    }
} 
