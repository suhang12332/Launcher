import Foundation
import Combine

// Class to manage saving and loading GameVersionInfo using UserDefaults
class GameStorageManager: ObservableObject {
    // Published array of games that views can subscribe to
    @Published var games: [GameVersionInfo] = []
    
    private let gamesKey = "savedGames" // Key for UserDefaults
    
    init() {
        loadGames()
    }
    
    // Load games from UserDefaults
    private func loadGames() {
        if let savedGamesData = UserDefaults.standard.data(forKey: gamesKey) {
            let decoder = JSONDecoder()
            if let loadedGames = try? decoder.decode([GameVersionInfo].self, from: savedGamesData) {
                games = loadedGames
            }
        }
    }
    
    // Save games to UserDefaults
    private func saveGames() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(games) {
            UserDefaults.standard.set(encodedData, forKey: gamesKey)
        }
    }
    
    // Add a new game
    func addGame(_ game: GameVersionInfo) {
        games.append(game)
        saveGames() // Save after adding
    }
    
    // Delete a game by ID
    func deleteGame(id: String) {
        games.removeAll { $0.id == id }
        saveGames() // Save after deleting
    }
    
    // Update a game (if needed later)
    // func updateGame(_ updatedGame: GameVersionInfo) {
    //     if let index = games.firstIndex(where: { $0.id == updatedGame.id }) {
    //         games[index] = updatedGame
    //         saveGames()
    //     }
    // }
} 