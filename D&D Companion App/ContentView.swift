import SwiftUI
import SwiftData

// MARK: - Typy Pomocnicze
enum SekcjaNawigacji: Hashable {
    case kartaPostaci, ekwipunek, ksiegaCzarow, roleplay, walka
}

enum SheetItem: Identifiable {
    case weapon(Weapon)
    case spell(Spells)
    case action(CombatAction)
    
    var id: String {
        switch self {
        case .weapon(let w): return "w_\(w.id)"
        case .spell(let s): return "s_\(s.id)"
        case .action(let a): return "a_\(a.id)"
        }
    }
}

// MARK: - Główny Widok Aplikacji (Menedżer Postaci)
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Player.imie) private var players: [Player]
    
    @State private var activePlayer: Player?
    
    @State private var selection: SekcjaNawigacji? = .kartaPostaci
    @State private var ostatniRzut: RollResult?
    
    // Stany do zarządzania okienkami dla całej aplikacji
    @State private var itemToShow: SheetItem?
    @State private var actionToRoll: CombatAction?
    @State private var showingSpellLevelDialog = false
    
    // POPRAWKA 2: Stan do zarządzania widocznością panelu bocznego
    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly

    var body: some View {
        if let player = activePlayer {
            ZStack(alignment: .bottom) {
                // POPRAWKA 2: Dodajemy parametr `columnVisibility`
                NavigationSplitView(columnVisibility: $columnVisibility) {
                    // POPRAWKA 1: Porządkujemy listę i przenosimy przycisk na dół
                    List(selection: $selection) {
                        Section {
                            Label("Karta Postaci", systemImage: "person.text.rectangle").tag(SekcjaNawigacji.kartaPostaci)
                            Label("Walka", systemImage: "bolt.shield.fill").tag(SekcjaNawigacji.walka)
                            Label("Ekwipunek", systemImage: "backpack").tag(SekcjaNawigacji.ekwipunek)
                            Label("Księga Czarów", systemImage: "book.closed").tag(SekcjaNawigacji.ksiegaCzarow)
                            Label("Osobowość", systemImage: "theatermasks").tag(SekcjaNawigacji.roleplay)
                        }
                        
                        Section {
                            Button(action: { activePlayer = nil }) {
                                Label("Zmień Postać", systemImage: "person.2.fill")
                            }
                            .foregroundStyle(Color.accentColor)
                        }
                    }
                    .navigationTitle(player.imie.isEmpty ? "Nowa Postać" : player.imie)
                    
                } detail: {
                    switch selection {
                    case .kartaPostaci:
                        CharacterSheetView(player: player, ostatniRzut: $ostatniRzut)
                    case .walka:
                        CombatView(player: player, ostatniRzut: $ostatniRzut, actionToRoll: $actionToRoll) { item in
                            self.itemToShow = item
                        }
                    case .ekwipunek:
                        EquipmentView(player: player, ostatniRzut: $ostatniRzut)
                    case .ksiegaCzarow:
                        SpellbookView(player: player, ostatniRzut: $ostatniRzut)
                    case .roleplay:
                        Text("Kiedyś uzupełnię").font(.largeTitle)
                    case .none:
                        Text("Wybierz sekcję z menu").font(.largeTitle)
                    }
                }
                
                HStack(alignment: .bottom, spacing: 10) {
                    if let wynikRzutu = ostatniRzut {
                        RollNotificationView(wynik: wynikRzutu, player: player, ostatniRzut: $ostatniRzut)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    Spacer()
                    FloatingDiceRoller(player: player, ostatniRzut: $ostatniRzut)
                }
                .padding()
                .animation(.default, value: ostatniRzut)
            }
            .sheet(item: $itemToShow) { item in
                switch item {
                case .weapon(let weapon):
                    WeaponDetailView(weapon: weapon)
                case .spell(let spell):
                    SpellDetailView(czar: spell)
                case .action(let action):
                    ActionDetailView(action: action)
                }
            }
            .confirmationDialog("Rzuć czar na poziomie...", isPresented: $showingSpellLevelDialog, titleVisibility: .visible) {
                if let action = actionToRoll, case .spell(let spell) = action.rollable {
                    let spellSlots = player.isEldritchKnight ? player.eldritchKnightCurrentSpellSlots : player.currentSpellSlots
                    ForEach(spell.poziom..<10) { level in
                        let index = level - 1
                        if index < spellSlots.count, spellSlots[index] > 0 {
                            Button("Poziom \(level) (\(spellSlots[index]) slotów)") {
                                performAction(action, for: player, at: level)
                                actionToRoll = nil
                            }
                        }
                    }
                }
                Button("Anuluj", role: .cancel) {
                    actionToRoll = nil
                }
            }
            .onChange(of: ostatniRzut) { oldValue, newValue in
                guard newValue != nil else { return }
                Task {
                    try? await Task.sleep(for: .seconds(4))
                    if ostatniRzut == newValue {
                        withAnimation(.easeOut) {
                            ostatniRzut = nil
                        }
                    }
                }
            }
            .onChange(of: actionToRoll) { oldValue, newValue in
                guard let action = newValue else { return }
                
                if case .spell(let spell) = action.rollable, spell.poziom > 0 {
                    showingSpellLevelDialog = true
                } else {
                    performAction(action, for: player, at: nil)
                    actionToRoll = nil
                }
            }
            
        } else {
            CharacterSelectionView(
                players: players,
                onSelect: { player in activePlayer = player },
                onCreate: { createNewCharacter() },
                onDelete: { offsets in deleteCharacter(at: offsets) }
            )
            .onAppear(perform: loadGameDataIfNeeded)
        }
    }

    private func performAction(_ action: CombatAction, for player: Player, at spellLevel: Int?) {
        switch action.rollable {
        case .weapon(let weapon):
            ostatniRzut = player.performWeaponAttack(with: weapon)
            
        case .spell(let spell):
            let level = spellLevel ?? spell.poziom
            player.useSpellSlot(atLevel: level)
            
            if spell.wymagaAtaku == true {
                ostatniRzut = player.performSpellAttack(spell: spell, atLevel: level)
            }
        case .none:
            break
        }
    }
    
    private func createNewCharacter() {
        let newPlayer = Player()
        modelContext.insert(newPlayer)
        try? modelContext.save()
        activePlayer = newPlayer
    }

    private func deleteCharacter(at offsets: IndexSet) {
        for index in offsets {
            let playerToDelete = players[index]
            modelContext.delete(playerToDelete)
        }
    }
    
    private func loadGameDataIfNeeded() {
        if (try? modelContext.fetchCount(FetchDescriptor<Weapon>())) == 0 {
            loadAndMapJson(filename: "weapons", jsonType: [WeaponJSON].self) { items in
                items.forEach { modelContext.insert(Weapon(from: $0)) }
            }
        }
        if (try? modelContext.fetchCount(FetchDescriptor<Spells>())) == 0 {
            loadAndMapJson(filename: "spells", jsonType: [SpellsJSON].self) { items in
                items.forEach { modelContext.insert(Spells(from: $0)) }
            }
        }
        if (try? modelContext.fetchCount(FetchDescriptor<Maneuver>())) == 0 {
            loadAndMapJson(filename: "maneuvers", jsonType: [ManeuverJSON].self) { items in
                items.forEach { modelContext.insert(Maneuver(from: $0)) }
            }
        }
        if (try? modelContext.fetchCount(FetchDescriptor<Armor>())) == 0 {
            loadAndMapJson(filename: "armor", jsonType: [ArmorJSON].self) { items in
                items.forEach { modelContext.insert(Armor(from: $0)) }
            }
        }
        if (try? modelContext.fetchCount(FetchDescriptor<Feat>())) == 0 {
            loadAndMapJson(filename: "feats", jsonType: [FeatJSON].self) { items in
                items.forEach { modelContext.insert(Feat(from: $0)) }
            }
        }
    }
    
    private func loadAndMapJson<T: Decodable>(filename: String, jsonType: T.Type, mapper: (T) -> Void) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            fatalError("Nie znaleziono pliku \(filename).json")
        }
        do {
            let data = try Data(contentsOf: url)
            let items = try JSONDecoder().decode(T.self, from: data)
            mapper(items)
            try modelContext.save()
        } catch {
            fatalError("Błąd wczytywania \(filename).json: \(error)")
        }
    }
}

struct CharacterSelectionView: View {
    let players: [Player]
    var onSelect: (Player) -> Void
    var onCreate: () -> Void
    var onDelete: (IndexSet) -> Void

    var body: some View {
        NavigationStack {
            List {
                if players.isEmpty {
                    ContentUnavailableView(
                        "Brak Postaci",
                        systemImage: "person.3.sequence.fill",
                        description: Text("Stwórz swoją pierwszą postać, aby rozpocząć przygodę.")
                    )
                } else {
                    ForEach(players) { player in
                        Button(action: { onSelect(player) }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(player.imie.isEmpty ? "Nowa Postać" : player.imie).font(.headline)
                                    Text("\(player.rasa.rawValue) \(player.klasa.rawValue), Poziom \(player.poziom)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        .foregroundColor(.primary)
                    }
                    .onDelete(perform: onDelete)
                }
            }
            .navigationTitle("Wybierz Postać")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Dodaj nową", systemImage: "plus", action: onCreate)
                }
            }
        }
    }
}
