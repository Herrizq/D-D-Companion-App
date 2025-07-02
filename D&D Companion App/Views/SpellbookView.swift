import SwiftUI
import SwiftData

struct SpellbookView: View {
    @Bindable var player: Player
    @Binding var ostatniRzut: RollResult?
    @Query private var allSpells: [Spells]
    
    @State private var showingSpellManagementSheet = false
    @State private var spellToShow: Spells?

    private var isEldritchKnight: Bool {
        player.fighterArchetype == .eldritchKnight
    }

    private var isPreparedCaster: Bool {
        player.klasa.spellcastingType == .prepared
    }

    // Używamy nowej, scentralizowanej funkcji z modelu Player
    private var spellsToDisplay: [Spells] {
        let allPossibleSpells = player.spellsToDisplay(allSpells: allSpells)
        
        // --- LOGIKA USUWANIA DUPLIKATÓW ---
        var uniqueSpells: [Spells] = []
        var seenSpellIDs = Set<String>()
        
        for spell in allPossibleSpells {
            if !seenSpellIDs.contains(spell.id) {
                uniqueSpells.append(spell)
                seenSpellIDs.insert(spell.id)
            }
        }
        return uniqueSpells
    }
    
    private var cantripsToDisplay: [Spells] {
        let allPossibleCantrips = player.cantrips(allSpells: allSpells)
        
        // --- LOGIKA USUWANIA DUPLIKATÓW (RÓWNIEŻ DLA SZTUCZEK) ---
        var uniqueCantrips: [Spells] = []
        var seenCantripIDs = Set<String>()

        for cantrip in allPossibleCantrips {
            if !seenCantripIDs.contains(cantrip.id) {
                uniqueCantrips.append(cantrip)
                seenCantripIDs.insert(cantrip.id)
            }
        }
        return uniqueCantrips
    }

    private var czaryPogrupowane: [Int: [Spells]] {
        Dictionary(grouping: spellsToDisplay, by: { $0.poziom })
    }

    var body: some View {
        Form {
            if player.canCastSpells {
                
                Section(header: Text("Zarządzanie Magią")) {
                    if isPreparedCaster {
                        Button("Zarządzaj przygotowanymi czarami (\(player.preparedSpells.count)/\(player.maxPreparedSpells))") {
                            showingSpellManagementSheet = true
                        }
                    } else if isEldritchKnight {
                        Button("Zarządzaj znanymi czarami (\(player.eldritchKnightKnownSpells?.count ?? 0)/\(player.maxEldritchKnightKnownSpells))") {
                            showingSpellManagementSheet = true
                        }
                    }
                }
                
                Section(header: Text("Zdolności Magiczne")) {
                    HStack {
                        Text("Cecha Bazowa")
                        Spacer()
                        Text(isEldritchKnight ? "Inteligencja" : (player.klasa.spellcastingAbility?.rawValue ?? "-"))
                            .fontWeight(.bold)
                    }
                    HStack {
                        Text("ST Rzutu Obronnego")
                        Spacer()
                        Text("\(player.spellSaveDC)").fontWeight(.bold)
                    }
                    HStack {
                        Text("Premia do Ataku")
                        Spacer()
                        Text("+\(player.spellAttackModifier)").fontWeight(.bold)
                    }
                }
                
                Section(header: Text("Komórki Czarów")) {
                    let spellSlots = isEldritchKnight ? player.eldritchKnightSpellSlots : player.currentSpellSlots
                    let maxSlots = isEldritchKnight ? player.eldritchKnightSpellSlots : player.maxSpellSlots
                    
                    if spellSlots.allSatisfy({ $0 == 0 }) {
                        Text("Brak dostępnych komórek czarów.")
                    } else {
                        ForEach(0..<maxSlots.count, id: \.self) { index in
                            if maxSlots[index] > 0 {
                                HStack {
                                    Text("Poziom \(index + 1)")
                                    Spacer()
                                    let current = index < spellSlots.count ? spellSlots[index] : 0
                                    Text("\(current) / \(maxSlots[index])")
                                        .font(.system(.body, design: .monospaced))
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                }
                
                if !cantripsToDisplay.isEmpty {
                    Section(header: Text("Sztuczki (Cantrips)")) {
                        ForEach(cantripsToDisplay) { czar in
                            SpellRowView(czar: czar, player: player, onRowTapped: { spellToShow = czar }, ostatniRzut: $ostatniRzut)
                        }
                    }
                }

                ForEach(czaryPogrupowane.keys.sorted(), id: \.self) { poziom in
                    if let czaryNaPoziomie = czaryPogrupowane[poziom], !czaryNaPoziomie.isEmpty {
                        Section(header: Text("Poziom \(poziom)")) {
                            ForEach(czaryNaPoziomie) { czar in
                                SpellRowView(czar: czar, player: player, onRowTapped: { spellToShow = czar }, ostatniRzut: $ostatniRzut)
                            }
                        }
                    }
                }
                
            } else {
                ContentUnavailableView("Brak Zdolności Magicznych", systemImage: "sparkles.slash", description: Text("Twoja postać nie potrafi rzucać czarów."))
            }
        }
        .navigationTitle("Księga Czarów")
        .sheet(isPresented: $showingSpellManagementSheet) {
            if isEldritchKnight {
                EldritchKnightSpellSelectionView(player: player)
            } else if isPreparedCaster {
                SpellPreparationView(player: player, domainSpellIDs: [])
            }
        }
        .sheet(item: $spellToShow) { spell in
            SpellDetailView(czar: spell)
        }
    }
}
