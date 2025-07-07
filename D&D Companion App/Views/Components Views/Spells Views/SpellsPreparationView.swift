import SwiftUI
import SwiftData

struct SpellPreparationView: View {
    @Bindable var player: Player
    @Query private var allSpells: [Spells]
    @Environment(\.dismiss) var dismiss
    
    // Pobieramy ID czarów domenowych, aby je wykluczyć z listy wyboru
    private var domainSpellIDs: [String] {
        player.domainSpells(allSpells: allSpells).map { $0.id }
    }

    // Lista czarów, które Kleryk może przygotować
    private var availableSpells: [Spells] {
        // Maksymalny poziom czaru, jaki Kleryk może rzucić
        let maxSpellLevel = (player.poziom + 1) / 2
        
        return allSpells.filter { spell in
            // Czar musi być z listy kleryka i mieć odpowiedni poziom
            spell.dostepnyDlaKlas.contains(player.klasa.rawValue) &&
            spell.poziom > 0 &&
            spell.poziom <= maxSpellLevel &&
            // Czar nie może być czarem domenowym (te są przygotowane automatycznie)
            !domainSpellIDs.contains(spell.id)
        }
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Przygotowane Czary")) {
                    Text("Możesz przygotować \(player.preparedSpells.count) / \(player.maxPreparedSpells) czarów.")
                        .foregroundColor(player.preparedSpells.count > player.maxPreparedSpells ? .red : .primary)
                }
                
                Section(header: Text("Dostępne Czary Kleryka")) {
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
