//
//  AddWeaponView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct AddWeaponView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @Environment(\.dismiss) var dismiss
    
    private let wszystkieBronie = DataManager.shared.bronie
    @State private var searchText = ""
    
    var wynikiWyszukiwania: [Weapon] {
        if searchText.isEmpty {
            return wszystkieBronie
        } else {
            return wszystkieBronie.filter { $0.nazwa.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            // ZMIANA: Używamy teraz List jako kontenera, a ForEach do generowania wierszy.
            List {
                ForEach(wynikiWyszukiwania) { bron in
                    Button(action: {
                        viewModel.AddWeapon(bron)
                        dismiss()
                    }) {
                        VStack(alignment: .leading) {
                            Text(bron.nazwa).font(.headline)
                            
                            // Tworzymy opis właściwości, aby był czytelny
                            let wlasciwosciOpis = bron.wlasciwosci.isEmpty ? "Brak" : bron.wlasciwosci.joined(separator: ", ")
                            
                            Text("Obrażenia: \(bron.iloscKosciObrazen)k\(bron.koscObrazen), Właściwości: \(wlasciwosciOpis)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .searchable(text: $searchText, prompt: "Szukaj broni...")
            .navigationTitle("Dodaj Broń")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") { dismiss() }
                }
            }
        }
    }
}
