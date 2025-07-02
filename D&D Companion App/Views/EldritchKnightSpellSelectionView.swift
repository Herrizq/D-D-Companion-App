import SwiftUI
import SwiftData

struct EldritchKnightSpellSelectionView: View {
    @Bindable var player: Player
    @Query private var allSpells: [Spells]
    @Environment(\.dismiss) var dismiss
    
    // Filtrujemy czary, których może się nauczyć Mistyczny Rycerz
    private var availableSpells: [Spells] {
        // Zgodnie z zasadami, większość czarów musi być ze szkoły Odrzucania lub Wywoływania
        let allowedSchools = ["Odrzucanie", "Wywoływanie"]
        
        // Filtrujemy czary z listy maga, które są z dozwolonych szkół
        return allSpells.filter { spell in
            let isWizardSpell = spell.dostepnyDlaKlas.contains("Mag")
            let isAllowedSchool = allowedSchools.contains(spell.szkolaMagii)
            // Maksymalny poziom czaru, jaki może rzucić
            let maxSpellLevel = Int(ceil(Double(player.poziom) / 3.0)) > 4 ? 4 : Int(ceil(Double(player.poziom) / 3.0))

            return isWizardSpell && isAllowedSchool && spell.poziom > 0 && spell.poziom <= maxSpellLevel
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Wybierz znane czary")) {
                    Text("Możesz znać \(player.eldritchKnightKnownSpells?.count ?? 0) / \(player.maxEldritchKnightKnownSpells) czarów.")
                        .foregroundColor(player.eldritchKnightKnownSpells?.count ?? 0 > player.maxEldritchKnightKnownSpells ? .red : .primary)
                    
                    ForEach(availableSpells.sorted(by: { $0.poziom < $1.poziom || $0.nazwa < $1.nazwa })) { spell in
                        Button(action: { toggleSpell(spell) }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(spell.nazwa)
                                    Text("Poziom \(spell.poziom), \(spell.szkolaMagii)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if player.eldritchKnightKnownSpells?.contains(spell) ?? false {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                        .disabled(
                            !(player.eldritchKnightKnownSpells?.contains(spell) ?? false) &&
                            (player.eldritchKnightKnownSpells?.count ?? 0) >= player.maxEldritchKnightKnownSpells
                        )
                    }
                }
            }
            .navigationTitle("Nauka Czarów")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gotowe") { dismiss() }
                }
            }
        }
    }
    
    private func toggleSpell(_ spell: Spells) {
         if player.eldritchKnightKnownSpells == nil { player.eldritchKnightKnownSpells = [] }
         
         if let index = player.eldritchKnightKnownSpells?.firstIndex(of: spell) {
             player.eldritchKnightKnownSpells?.remove(at: index)
         } else {
             if (player.eldritchKnightKnownSpells?.count ?? 0) < player.maxEldritchKnightKnownSpells {
                 player.eldritchKnightKnownSpells?.append(spell)
             }
         }
     }
 }
