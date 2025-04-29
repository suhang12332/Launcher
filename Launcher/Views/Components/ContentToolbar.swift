import SwiftUI

struct ContentToolbar: View {
    @Binding var showingAddPlayer: Bool
    @StateObject private var playerService = PlayerService.shared
    
    @State private var playerName = ""
    @State private var isPlayerNameValid = false
    @State private var playerNameError: String?
    @State private var showError = false
    
    var body: some View {
        // 有玩家 显示添加玩家的头像
        if !playerService.players.isEmpty {
            PlayerSelector()
            Spacer()
        }
        Button(action: {
            showingAddPlayer = true
        }) {
            Label("player.add",systemImage: "person.badge.plus")
        }
        .help(NSLocalizedString("player.add", comment: ""))
        .alert(NSLocalizedString("player.add.title", comment: ""), isPresented: $showingAddPlayer) {
            TextField(NSLocalizedString("player.add", comment: ""), text: $playerName)
                .onChange(of: playerName) { oldValue, newValue in
                    checkPlayerName(newValue)
                }
            
            Button(NSLocalizedString("player.add.cancel", comment: ""), role: .cancel) {
                resetState()
            }
            
            Button(NSLocalizedString("player.add.confirm", comment: "")) {
                if !playerService.players.contains(where: { $0.name == playerName }) {
                    let newPlayer = Player(name: playerName)
                    playerService.addPlayer(newPlayer)
                    resetState()
                } else {
                    playerNameError = NSLocalizedString("player.add.error.exists", comment: "")
                }
            }
            .disabled(!isPlayerNameValid)
        } message: {
            VStack {
                Text(NSLocalizedString("player.add.message", comment: ""))
            }
        }
    }
    
    private func resetState() {
        playerName = ""
        isPlayerNameValid = false
        playerNameError = nil
        showingAddPlayer = false
    }
    
    private func checkPlayerName(_ name: String) {
        if name.isEmpty {
            isPlayerNameValid = false
            playerNameError = nil
        } else if playerService.players.contains(where: { $0.name == name }) {
            isPlayerNameValid = false
            playerNameError = NSLocalizedString("player.add.error.exists", comment: "")
        } else {
            isPlayerNameValid = true
            playerNameError = nil
        }
    }
} 
