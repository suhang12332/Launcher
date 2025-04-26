import SwiftUI

struct PlayerSelector: View {
    @StateObject private var playerService = PlayerService.shared
    
    var body: some View {
        Menu {
            if playerService.players.isEmpty {
                ProgressView()
                    .controlSize(.small)
            } else {
                ForEach(Array(playerService.players.enumerated()), id: \.element.id) { _, player in
                    Button {
                        Task {
                            try? await playerService.selectPlayer(player)
                        }
                    } label: {
                        HStack {
                            AsyncImage(url: URLConfig.Resources.Minecraft.playerAvatar(name: player.name)) { image in
                                image
                                    .resizable()
                                    .interpolation(.none)
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            } placeholder: {
                                ProgressView()
                                    .controlSize(.small)
                            }
                            Text(player.name)
                        }
                    }
                }
            }
        } label: {
            if let selectedPlayer = playerService.selectedPlayer {
                HStack(spacing: 6) {
                    AsyncImage(url: URLConfig.Resources.Minecraft.playerAvatar(name: selectedPlayer.name)) { image in
                        image
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    } placeholder: {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Text(selectedPlayer.name)
                        .foregroundStyle(.secondary)
                        .font(.system(size: 13))
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .foregroundStyle(.secondary)
                    .imageScale(.small)
            }
        }
    }
} 