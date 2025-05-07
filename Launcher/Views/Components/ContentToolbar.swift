import SwiftUI

struct ContentToolbar: View {
    // MARK: - Properties
    @Binding var showingAddPlayer: Bool
    @StateObject private var playerService = PlayerService.shared
    
    // MARK: - State
    @State private var playerName = ""
    @State private var isPlayerNameValid = false
    @State private var playerNameError: String?
    
    // MARK: - Body
    var body: some View {
        if !playerService.players.isEmpty {
            PlayerSelector()
            
        }
        Spacer()
        addPlayerButton.alert(NSLocalizedString("player.add.title", comment: ""), isPresented: $showingAddPlayer) {
            addPlayerAlertContent
        } message: {
            Text(NSLocalizedString("player.add.message", comment: ""))
        }

        
    }
    
    // MARK: - UI Components
    
    private var addPlayerButton: some View {
        Button(action: { showingAddPlayer = true }) {
            Label(NSLocalizedString("player.add", comment: ""), systemImage: "person.badge.plus")
        }
        .help(NSLocalizedString("player.add", comment: ""))
    }
    
    private var addPlayerAlertContent: some View {
        Group {
            TextField(NSLocalizedString("player.add", comment: ""), text: $playerName)
                .onChange(of: playerName) { _, newValue in
                    checkPlayerName(newValue)
                }
            
            Button(NSLocalizedString("player.add.cancel", comment: ""), role: .cancel) {
                resetState()
            }
            
            Button(NSLocalizedString("player.add.confirm", comment: "")) {
                addNewPlayer()
            }
            .disabled(!isPlayerNameValid)
        }
    }
    
    // MARK: - Private Methods
    
    private func addNewPlayer() {
        do {
            try validateAndAddPlayer()
            resetState()
        } catch {
            playerNameError = error.localizedDescription
        }
    }
    
    private func validateAndAddPlayer() throws {
        guard !playerName.isEmpty else {
            throw PlayerError.invalidUsername
        }
        
        // Check if player name already exists
        if playerService.getAllPlayers().contains(where: { $0.name == playerName }) {
            throw PlayerError.custom(NSLocalizedString("player.add.error.exists", comment: ""))
        }
        
        // Create new player
        let player = try Player(name: playerName)
        playerService.addPlayer(player)
        showingAddPlayer = false
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

// MARK: - Player Error Extension

extension PlayerError {
    static var playerNameExists: PlayerError {
        .init(localizedDescription: NSLocalizedString("player.add.error.exists", comment: ""))
    }
} 
