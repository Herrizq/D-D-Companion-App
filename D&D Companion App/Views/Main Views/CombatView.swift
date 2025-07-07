import SwiftUI
import SwiftData

// MARK: - Struktury Pomocnicze

struct CombatAction: Identifiable, Hashable {
    let id: String // Używamy stabilnego ID
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

// MARK: - Główny Widok Walki

struct CombatView: View {
    @Bindable var player: Player
    
    @Query private var allSpells: [Spells]
    
    // Bindingi do stanu zarządzanego przez ContentView
    @Binding var ostatniRzut: RollResult?
    @Binding var actionToRoll: CombatAction?
    
    // Nowe closure do komunikacji z ContentView
    var onShowDetails: (SheetItem) -> Void

    private var combatActions: [CombatAction] {
        var actions: [CombatAction] = []

        // Dodawanie akcji dla broni
        for weapon in player.carriedWeapons ?? [] {
            actions.append(weapon.asCombatAction(for: player))
        }
        
        // Dodawanie akcji dla Kanału Mocy Kleryka
        if player.klasa == .kleryk, let domain = player.clericDomain, player.poziom >= 2 {
            var turnUndeadDescription = "Jako akcję, prezentujesz swój święty symbol, a nieumarli w promieniu 30 stóp muszą wykonać rzut obronny na Mądrość (ST \(player.spellSaveDC))."
            if player.destroyUndeadCR > 0 {
                turnUndeadDescription += "\n\nNieumarli, którym się nie powiedzie i których stopień wyzwania to \(player.destroyUndeadCR) lub mniej, zostają zniszczeni."
            }
            actions.append(CombatAction(id: "cleric_turn_undead", name: "Odpędzenie Nieumarłych", description: turnUndeadDescription, source: "Kanał Mocy", range: "30 stóp", hitBonus: "-", damage: "-", damageType: "Efekt", rollable: .none))
            
            if let domainAction = domain.channelDivinityAction(player: player) {
                actions.append(domainAction)
            }
        }

        // Dodawanie akcji dla czarów
        let allPossibleSpells = player.spellsToDisplay(allSpells: allSpells) + player.cantrips(allSpells: allSpells)
        var seenSpellIDs = Set<String>()
        for spell in allPossibleSpells {
            if !seenSpellIDs.contains(spell.id) {
                if spell.typObrazen != "Leczenie" && (spell.wymagaAtaku == true || (spell.iloscKosciObrazen ?? 0) > 0) {
                    actions.append(spell.asCombatAction(for: player))
                }
                seenSpellIDs.insert(spell.id)
            }
        }
        
        return actions.sorted(by: { $0.name < $1.name })
    }

    var body: some View {
        Form {
            Section {
                Text("AKCJE • Ataki na akcję: \(player.extraAttacks)")
                    .font(.caption.weight(.bold)).foregroundStyle(.secondary)
                
                ForEach(combatActions) { action in
                    ActionRowView(
                        action: action,
                        onRoll: {
                            self.actionToRoll = action
                        },
                        onShowDetails: {
                            // Mapujemy CombatAction na odpowiedni SheetItem
                            switch action.rollable {
                            case .weapon(let weapon):
                                onShowDetails(.weapon(weapon))
                            case .spell(let spell):
                                onShowDetails(.spell(spell))
                            case .none:
                                onShowDetails(.action(action))
                            }
                        }
                    )
                }
            }
            
            CombatResourcesSection(player: player) {
                useSecondWind()
            }
            
            StandardActionsSection()
        }
        .navigationTitle("Walka")
    }
    
    private func useSecondWind() {
        let roll = Int.random(in: 1...10)
        let healingAmount = roll + player.poziom
        player.currentHitPoints = min(player.hitPointsMaximum, player.currentHitPoints + healingAmount)
        player.hasUsedSecondWind = true
        ostatniRzut = RollResult(tytul: "Drugi Oddech", wynikOstateczny: healingAmount, rzutKosci: roll, modyfikator: player.poziom, formula: "1k10 + \(player.poziom)")
    }
}


// MARK: - Komponenty Widoku (Wydzielone Sekcje)

private struct CombatResourcesSection: View {
    @Bindable var player: Player
    var onUseSecondWind: () -> Void
    
    var body: some View {
        Section(header: Text("Zasoby Bojowe")) {
            if player.klasa == .wojownik {
                Button(action: onUseSecondWind) {
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
    }
}

private struct StandardActionsSection: View {
    var body: some View {
        Section(header: Text("Akcje w walce")) {
            Text("Atak, Unik, Pęd, Odwrót, Pomoc, Ukrycie, Przygotowanie, Improwizacja, Użycie przedmiotu")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
