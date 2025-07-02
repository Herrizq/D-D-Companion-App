//
//  ContentView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI
import SwiftData

enum SekcjaNawigacji: Hashable {
    case kartaPostaci
    case ekwipunek
    case ksiegaCzarow
    case roleplay
    case walka
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Pobieramy postacie z bazy danych. Aplikacja zakłada jedną postać.
    @Query var players: [Player]
    
    @State private var selection: SekcjaNawigacji? = .kartaPostaci
    @State var ostatniRzut: RollResult? = nil
    
    var body: some View {
        // Sprawdzamy, czy postać istnieje. Jeśli nie, pokazujemy widok tworzenia.
        if let player = players.first {
            ZStack(alignment: .bottom) {
                NavigationSplitView {
                    List(selection: $selection) {
                        Label("Karta Postaci", systemImage: "person.text.rectangle")
                            .tag(SekcjaNawigacji.kartaPostaci)
                        
                        Label("Walka", systemImage: "bolt.shield.fill")
                            .tag(SekcjaNawigacji.walka)
                        
                        Label("Ekwipunek", systemImage: "backpack")
                            .tag(SekcjaNawigacji.ekwipunek)
                        
                        Label("Księga Czarów", systemImage: "book.closed")
                            .tag(SekcjaNawigacji.ksiegaCzarow)
                        
                        Label("Osobowość", systemImage: "theatermasks")
                            .tag(SekcjaNawigacji.roleplay)
                    }
                    .navigationTitle("Menu")
                    
                } detail: {
                    // Przekazujemy postać i powiadomienia do odpowiednich widoków
                    switch selection {
                    case .kartaPostaci:
                        CharacterSheetView(player: player, ostatniRzut: $ostatniRzut)
                    case .ekwipunek:
                        EquipmentView(player: player, ostatniRzut: $ostatniRzut)
                    case .ksiegaCzarow:
                        SpellbookView(player: player, ostatniRzut: $ostatniRzut)
                    case .walka:
                        CombatView(player: player, ostatniRzut: $ostatniRzut)
                    case .roleplay:
                        Text("Wybierz sekcję z menu").font(.largeTitle)
                    case .none:
                        Text("Wybierz sekcję z menu").font(.largeTitle)
                    }
                }
                
                HStack(alignment: .bottom, spacing: 10) {
                    if let wynikRzutu = ostatniRzut {
                        // Przekazujemy teraz tylko player i ostatniRzut
                        RollNotificationView(wynik: wynikRzutu, player: player, ostatniRzut: $ostatniRzut)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    Spacer()
                    FloatingDiceRoller(player: player, ostatniRzut: $ostatniRzut)
                }
                .padding()
                .animation(.default, value: ostatniRzut)
            }
            .onAppear {
                loadGameDataIfNeeded()
            }
            // --- NOWA, CENTRALNA LOGIKA ZNIKANIA POWIADOMIEŃ ---
            .onChange(of: ostatniRzut) { oldValue, newValue in
                // Jeśli pojawiło się nowe powiadomienie...
                guard newValue != nil else { return }
                
                // Uruchom zadanie, które je zamknie po 4 sekundach
                Task {
                    try? await Task.sleep(for: .seconds(4))
                    // Upewnij się, że zamykasz właściwe powiadomienie
                    if ostatniRzut == newValue {
                        withAnimation(.easeOut) {
                            ostatniRzut = nil
                        }
                    }
                }
            }
        } else {
            // Widok, który pojawi się, gdy nie ma żadnej postaci w bazie
            VStack(spacing: 20) {
                Text("Witaj w D&D Companion!")
                    .font(.largeTitle)
                Button("Stwórz swoją pierwszą postać") {
                    createNewCharacter()
                }
                .buttonStyle(.borderedProminent)
            }
            .onAppear {
                loadGameDataIfNeeded()
            }
        }
    }
    
    private func createNewCharacter() {
        let newPlayer = Player() // Tworzy postać z domyślnymi wartościami
        modelContext.insert(newPlayer)
        try? modelContext.save()
    }
    
    private func loadGameDataIfNeeded() {
        let weaponDescriptor = FetchDescriptor<Weapon>()
        if (try? modelContext.fetchCount(weaponDescriptor)) == 0 {
            loadAndMapJson(filename: "weapons", jsonType: [WeaponJSON].self) { items in
                for item in items {
                    modelContext.insert(Weapon(from: item))
                }
            }
        }
        
        let spellDescriptor = FetchDescriptor<Spells>()
        if (try? modelContext.fetchCount(spellDescriptor)) == 0 {
            loadAndMapJson(filename: "spells", jsonType: [SpellsJSON].self) { items in
                for item in items {
                    modelContext.insert(Spells(from: item))
                }
            }
        }
        let maneuverDescriptor = FetchDescriptor<Maneuver>()
        if (try? modelContext.fetchCount(maneuverDescriptor)) == 0 {
            loadAndMapJson(filename: "maneuvers", jsonType: [ManeuverJSON].self) { items in
                for item in items {
                    modelContext.insert(Maneuver(from: item))
                }
            }
        }
        let armorDescriptor = FetchDescriptor<Armor>()
        if (try? modelContext.fetchCount(armorDescriptor)) == 0 {
            loadAndMapJson(filename: "armor", jsonType: [ArmorJSON].self) { items in
                for item in items {
                    modelContext.insert(Armor(from: item))
                }
            }
        }
    }
    
    private func loadAndMapJson<T: Decodable>(filename: String, jsonType: T.Type, mapper: (T) -> Void) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            fatalError("Nie znaleziono pliku \(filename).json")
        }
        
        do {
            let data = try Data(contentsOf: url)
            // Nazwy kluczy w JSON są teraz mapowane automatycznie na te w strukturach JSON
            let items = try JSONDecoder().decode(T.self, from: data)
            mapper(items)
            try modelContext.save()
        } catch {
            // Ten błąd teraz precyzyjniej wskaże problem z dekodowaniem.
            fatalError("Błąd wczytywania \(filename).json: \(error)")
        }
    }
}
