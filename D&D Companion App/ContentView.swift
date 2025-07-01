//
//  ContentView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

enum SekcjaNawigacji: Hashable {
    case kartaPostaci
    case ekwipunek
    case ksiegaCzarow
    case roleplay
}

struct ContentView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
        
    @State private var selection: SekcjaNawigacji? = .kartaPostaci

    var body: some View {
        // ZStack pozwala nam nałożyć na siebie główną treść i nasze dolne UI
        ZStack(alignment: .bottom) {
            
            // Warstwa 1: Główna nawigacja i treść aplikacji
            NavigationSplitView {
                List(selection: $selection) {
                    Label("Karta Postaci", systemImage: "person.text.rectangle")
                        .tag(SekcjaNawigacji.kartaPostaci)
                    
                    Label("Ekwipunek", systemImage: "backpack")
                        .tag(SekcjaNawigacji.ekwipunek)
                    
                    Label("Księga Czarów", systemImage: "book.closed")
                        .tag(SekcjaNawigacji.ksiegaCzarow)
                    
                    Label("Osobowość", systemImage: "theatermasks")
                        .tag(SekcjaNawigacji.roleplay)
                }
                .navigationTitle("Menu")
                
            } detail: {
                // Detail View - tutaj wyświetlamy wybraną sekcję
                switch selection {
                case .kartaPostaci:
                    CharacterSheetView()
                case .ekwipunek:
                    EquipmentView()
                case .ksiegaCzarow:
                    Text("Księga Czarów - w budowie").font(.largeTitle)
                case .roleplay:
                    RoleplayView()
                case .none:
                    Text("Wybierz sekcję z menu").font(.largeTitle)
                }
            }
            
            // Warstwa 2: Dolny panel z powiadomieniem i przyciskiem
            HStack(alignment: .bottom, spacing: 10) {
                // Powiadomienie o wyniku rzutu, widoczne warunkowo
                if let wynikRzutu = viewModel.ostatniRzut {
                    RollNotificationView(wynik: wynikRzutu)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Spacer zajmuje całą wolną przestrzeń między powiadomieniem a przyciskiem
                Spacer()
                
                // Unoszący się przycisk do rzucania kośćmi jest teraz częścią tego samego kontenera
                FloatingDiceRoller()
            }
            .padding()
            // Ten modyfikator jest ważny, aby przyciski w dolnym panelu działały poprawnie
            .animation(.default, value: viewModel.ostatniRzut)
        }
        .environmentObject(viewModel) // Przekazujemy ViewModel do wszystkich widoków podrzędnych
    }
}
