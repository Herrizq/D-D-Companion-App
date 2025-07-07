import SwiftUI
import SwiftData

@main
struct D_D_Companion_AppApp: App {
    // Usunęliśmy @StateObject private var viewModel

    // Konfiguracja kontenera SwiftData
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Player.self,
            Weapon.self,
            Armor.self,
            Spells.self,
            Feat.self // Dodajemy Atuty do schematu
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Nie można utworzyć ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        // Usunęliśmy .environmentObject(viewModel)
    }
}
