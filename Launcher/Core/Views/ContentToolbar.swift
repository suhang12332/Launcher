import SwiftUI

struct ContentToolbar: View {
    @Binding var showingAddPlayer: Bool
    @StateObject private var playerService = PlayerService.shared
    
    @State private var playerName = ""
    @State private var isPlayerNameValid = false
    @State private var playerNameError: String?
    @State private var error: PlayerError?
    @State private var showError = false
    
    var body: some View {
        PlayerSelector()
        Spacer()
        Button(action: {
            showingAddPlayer = true
        }) {
            Image(systemName: "person.badge.plus")
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
                Task {
                    await addPlayer()
                }
            }
            .disabled(!isPlayerNameValid)
        } message: {
            VStack {
                Text(NSLocalizedString("player.add.message", comment: ""))
                if let error = playerNameError {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
        }
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
    
    private func addPlayer() async {
        do {
            try await playerService.addPlayer(name: playerName)
            resetState()
        } catch {
            self.error = (error as? PlayerError) ?? .unknown
            showError = true
        }
    }
    
    private func resetState() {
        playerName = ""
        isPlayerNameValid = false
        playerNameError = nil
        showingAddPlayer = false
    }
} 
