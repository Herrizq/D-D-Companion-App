//
//  D_D_Companion_AppApp.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI
import SwiftData

@main
struct DnD_CompanionApp: App {

    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                Player.self,
                Weapon.self,
                Spells.self,
                Maneuver.self,
                Armor.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Nie można utworzyć ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
