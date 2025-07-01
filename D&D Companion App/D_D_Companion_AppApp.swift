//
//  D_D_Companion_AppApp.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

@main
struct DnD_CompanionApp: App {
    @StateObject private var viewModel = PlayerViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
