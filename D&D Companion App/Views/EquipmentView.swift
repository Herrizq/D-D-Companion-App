import SwiftUI

struct EquipmentView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @State private var pokazDodawanieBroni = false

    var body: some View {
        List {
            Section(header: Text("Posiadane Bronie")) {
                if viewModel.postac.carriedWeapons.isEmpty {
                    Text("Brak broni w ekwipunku.")
                        .foregroundStyle(.secondary)
                } else {
                    // Używamy ForEach do wygenerowania wierszy
                    ForEach(viewModel.postac.carriedWeapons) { bron in
                        // Każdy wiersz jest przyciskiem, który wykonuje akcję
                        Button(action: {
                            // AKCJA: Wywołujemy funkcję z ViewModelu, która wykonuje rzut
                            viewModel.wykonajRzutNaTrafienie(bronia: bron)
                        }) {
                            // WYGLĄD: Obliczamy i wyświetlamy bonusy
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(bron.nazwa).font(.headline)
                                    
                                    // POPRAWKA: Używamy funkcji z modelu do pobrania danych
                                    let bonusy = viewModel.postac.CalculateToHitBonuses(dlaBroni: bron)
                                    
                                    Text("Trafienie: +\(bonusy.trafienie) | Obrażenia: \(bonusy.obrazenia)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "dice")
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: usunBron)
                }
            }
        }
        .navigationTitle("Ekwipunek")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { pokazDodawanieBroni = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $pokazDodawanieBroni) {
            AddWeaponView()
        }
    }
    
    private func usunBron(at offsets: IndexSet) {
        viewModel.postac.carriedWeapons.remove(atOffsets: offsets)
    }
}
