import SwiftUI
import SwiftData

// Struktura pomocnicza do ujednolicenia wszystkich akcji w walce
struct CombatAction: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let source: String
    let range: String
    let hitBonus: String
    let damage: String
    let damageType: String
    let rollable: RollableAction

    enum RollableAction: Hashable {
        case weapon(Weapon)
        case spell(Spells)
        case none
    }
}

struct CombatView: View {
    @Bindable var player: Player
    @Binding var ostatniRzut: RollResult?
    
    @Query private var allSpells: [Spells]
    
    @State private var actionToShow: CombatAction?
    
    // Zmieniamy stan na prosty Boolean, który kontroluje widoczność okna
    @State private var showingSpellLevelDialog = false
    // Przechowujemy akcję, dla której chcemy rzucić czar
    @State private var actionToRoll: CombatAction?

    // Właściwość `combatActions` bez zmian
    private var combatActions: [CombatAction] {
        var actions: [CombatAction] = []

        // 1. Dodaj ataki bronią
        for weapon in player.carriedWeapons ?? [] {
            let bonuses = player.calculateToHitBonuses(dlaBroni: weapon)
            actions.append(CombatAction(
                name: weapon.nazwa,
                description: "Szczegółowy opis broni.",
                source: weapon.kategoria.rawValue,
                range: weapon.isRanged ? "Dystansowa" : "5 ft.",
                hitBonus: "+\(bonuses.trafienie)",
                damage: bonuses.obrazenia,
                damageType: "\(weapon.typObrazen)",
                rollable: .weapon(weapon)
            ))
        }

        // 2. Zbierz wszystkie czary z różnych źródeł
        let allPossibleSpells = player.spellsToDisplay(allSpells: allSpells) + player.cantrips(allSpells: allSpells)
                
        // 3. Usuń duplikaty na podstawie ID czaru
        var uniqueSpells: [Spells] = []
        var seenSpellIDs = Set<String>()
        for spell in allPossibleSpells {
            if !seenSpellIDs.contains(spell.id) {
                uniqueSpells.append(spell)
                seenSpellIDs.insert(spell.id)
            }
        }
                
                // 4. Dodaj unikalne czary ofensywne do listy akcji
        for spell in uniqueSpells where spell.typObrazen != "Leczenie" && (spell.wymagaAtaku == true || (spell.iloscKosciObrazen ?? 0) > 0) {
            let hit = player.spellAttackModifier
            actions.append(CombatAction(
                name: spell.nazwa,
                description: spell.opis,
                source: spell.poziom == 0 ? "Sztuczka" : "Czar poz. \(spell.poziom)",
                range: spell.zasieg,
                hitBonus: spell.wymagaAtaku == true ? "+\(hit)" : "-",
                damage: "\(spell.iloscKosciObrazen ?? 0)k\(spell.koscObrazen ?? 0)",
                damageType: "\(spell.typObrazen ?? "")",
                rollable: .spell(spell)
            ))
        }
        
        return actions
    }

    var body: some View {
        Form {
            // --- SEKCJA GŁÓWNYCH AKCJI ---
            Section {
                Text("AKCJE • Ataki na akcję: \(player.extraAttacks)")
                    .font(.caption.weight(.bold)).foregroundStyle(.secondary)
                
                ForEach(combatActions) { action in
                    ActionRowView(
                        action: action,
                        onRoll: {
                            if case .spell(let spell) = action.rollable, spell.poziom > 0 {
                                // Zapisujemy akcję i pokazujemy okno dialogowe
                                self.actionToRoll = action
                                self.showingSpellLevelDialog = true
                            } else {
                                performAction(action, at: nil)
                            }
                        },
                        onShowDetails: {
                            actionToShow = action
                        }
                    )
                }
            }
            
            // --- SEKCJA ZASOBÓW BOJOWYCH ---
            Section(header: Text("Zasoby Bojowe")) {
                if player.klasa == .wojownik {
                    Button(action: useSecondWind) {
                        HStack {
                            Text("Drugi Oddech")
                            Spacer()
                            Text(player.hasUsedSecondWind ? "Zużyto" : "1k10 + \(player.poziom)")
                                .foregroundStyle(player.hasUsedSecondWind ? .secondary : Color.accentColor)
                        }
                    }
                    .disabled(player.hasUsedSecondWind)
                    .foregroundColor(.primary)
                    
                    if player.maxIndomitableUses > 0 {
                        Stepper("Niezłomność: \(player.maxIndomitableUses - player.indomitableUses) / \(player.maxIndomitableUses)",
                                value: $player.indomitableUses,
                                in: 0...player.maxIndomitableUses)
                    }
                }
            }
            
            // --- SEKCJA STANDARDOWYCH AKCJI ---
            Section(header: Text("Akcje w walce")) {
                Text("Atak, Unik, Pęd, Odwrót, Pomoc, Ukrycie, Przygotowanie, Improwizacja, Użycie przedmiotu")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Walka")
        .sheet(item: $actionToShow) { action in
            ActionDetailView(action: action)
        }
        // --- ZAKTUALIZOWANY MODYFIKATOR ---
        .confirmationDialog("Rzuć czar na poziomie...", isPresented: $showingSpellLevelDialog, titleVisibility: .visible) {
            // Sprawdzamy, czy mamy zapisaną akcję do wykonania
            if let action = actionToRoll, case .spell(let spell) = action.rollable {
                ForEach(spell.poziom..<10) { level in
                    // Sprawdzamy, czy postać ma sloty na danym poziomie
                    if player.currentSpellSlots.count > (level - 1), player.currentSpellSlots[level - 1] > 0 {
                        Button("Poziom \(level) (\(player.currentSpellSlots[level - 1]) slotów)") {
                            performAction(action, at: level)
                        }
                    }
                }
            }
        }
    }
    
    private func performAction(_ action: CombatAction, at spellLevel: Int?) {
        switch action.rollable {
        case .weapon(let weapon):
            let bonuses = player.calculateToHitBonuses(dlaBroni: weapon)
            let roll = Int.random(in: 1...20)
            ostatniRzut = RollResult(tytul: "Atak: \(weapon.nazwa)", wynikOstateczny: roll + bonuses.trafienie, rzutKosci: roll, modyfikator: bonuses.trafienie, bronDoAtaku: weapon)
            
        case .spell(let spell):
            let level = spellLevel ?? spell.poziom
            if level > 0 { player.currentSpellSlots[level - 1] -= 1 }
            if spell.wymagaAtaku == true {
                let roll = Int.random(in: 1...20)
                let modifier = player.spellAttackModifier
                ostatniRzut = RollResult(tytul: "Atak Czarem: \(spell.nazwa)", wynikOstateczny: roll + modifier, rzutKosci: roll, modyfikator: modifier, czarDoAtaku: spell)
            }
        case .none:
            break
        }
    }
    
    private func useSecondWind() {
        let roll = Int.random(in: 1...10)
        let healingAmount = roll + player.poziom
        player.currentHitPoints = min(player.hitPointsMaximum, player.currentHitPoints + healingAmount)
        player.hasUsedSecondWind = true
        ostatniRzut = RollResult(tytul: "Drugi Oddech", wynikOstateczny: healingAmount, rzutKosci: roll, modyfikator: player.poziom, formula: "1k10 + \(player.poziom)")
    }
}
