import SwiftUI
import SwiftData

struct SpellPreparationView: View {
    @Bindable var player: Player
    @Query private var allSpells: [Spells]
    @Environment(\.dismiss) var dismiss
    
    // Otrzymujemy ID zaklęć domeny, aby je wykluczyć
    let domainSpellIDs: [String]
    
    private var availableSpells: [Spells] {
        // 1. Pobierz wszystkie czary dostępne dla klasy gracza
        let allPossibleSpells = allSpells.filter { spell in
            let maxSpellLevel = (player.poziom + 1) / 2
            return spell.dostepnyDlaKlas.contains(player.klasa.rawValue) &&
                   spell.poziom > 0 &&
                   spell.poziom <= maxSpellLevel
        }
        
        // 2. Odrzuć czary, które gracz już zna jako czary domenowe
        let spellsToChooseFrom = allPossibleSpells.filter { !domainSpellIDs.contains($0.id) }
        
        // 3. Usuń ewentualne duplikaty, które mogły pozostać
        var uniqueSpells: [Spells] = []
        var seenSpellIDs = Set<String>()
        
        for spell in spellsToChooseFrom {
            if !seenSpellIDs.contains(spell.id) {
                uniqueSpells.append(spell)
                seenSpellIDs.insert(spell.id)
            }
        }
        
        return uniqueSpells
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Wybierz czary do przygotowania")) {
                    Text("Możesz przygotować \(player.preparedSpells.count) / \(player.maxPreparedSpells) czarów.")
                        .foregroundColor(player.preparedSpells.count > player.maxPreparedSpells ? .red : .primary)
                    
                    ForEach(availableSpells.sorted(by: { $0.poziom < $1.poziom || ($0.poziom == $1.poziom && $0.nazwa < $1.nazwa)})) { spell in
                        Button(action: { togglePreparation(for: spell) }) {
                            HStack {
                                VStack(alignment: .leading) {
                                   Text(spell.nazwa)
                                   Text("Poziom \(spell.poziom), \(spell.szkolaMagii)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if player.preparedSpells.contains(spell.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                        .disabled(
                            !player.preparedSpells.contains(spell.id) &&
                            player.preparedSpells.count >= player.maxPreparedSpells
                        )
                    }
                }
            }
            .navigationTitle("Przygotuj Czary")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gotowe") { dismiss() }
                }
            }
        }
    }
    
    private func togglePreparation(for spell: Spells) {
        if let index = player.preparedSpells.firstIndex(of: spell.id) {
            player.preparedSpells.remove(at: index)
        } else {
            if player.preparedSpells.count < player.maxPreparedSpells {
                player.preparedSpells.append(spell.id)
            }
        }
    }
}
