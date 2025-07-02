import SwiftUI
import SwiftData

struct AddArmorView: View {
    @Bindable var player: Player
    @Query private var allArmor: [Armor]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List(allArmor) { armor in
                Button(action: {
                    // --- POPRAWIONA LOGIKA ---
                    
                    // Sprawdzamy, czy ekwipunek (tablica) już istnieje.
                    if player.armorInventory != nil {
                        // Jeśli tak, po prostu dodajemy nowy element.
                        player.armorInventory?.append(armor)
                    } else {
                        // Jeśli nie (jest nil), tworzymy nową tablicę z tym jednym elementem.
                        player.armorInventory = [armor]
                    }
                    
                    dismiss()
                }) {
                    HStack {
                        Text(armor.nazwa)
                        Spacer()
                        Text(armor.typ).font(.caption).foregroundStyle(.secondary)
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Dodaj Pancerz")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") { dismiss() }
                }
            }
        }
    }
}
