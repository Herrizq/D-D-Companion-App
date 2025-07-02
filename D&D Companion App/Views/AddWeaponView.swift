//
//  AddWeaponView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI
import SwiftData

struct AddWeaponView: View {
    @Bindable var player: Player
    @Environment(\.dismiss) var dismiss
    
    // Pobieramy wszystkie bronie z bazy SwiftData
    @Query private var allWeapons: [Weapon]
    
    @State private var searchText = ""
    
    var searchResults: [Weapon] {
        if searchText.isEmpty {
            return allWeapons
        } else {
            return allWeapons.filter { $0.nazwa.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            List(searchResults) { bron in
                Button(action: {
                    // Dodajemy broń bezpośrednio do kolekcji postaci.
                    // SwiftData automatycznie zapisze tę zmianę.
                    player.carriedWeapons!.append(bron)
                    dismiss()
                }) {
                    VStack(alignment: .leading) {
                        Text(bron.nazwa).font(.headline)
                        
                        let wlasciwosciOpis = bron.wlasciwosci.isEmpty ? "Brak" : bron.wlasciwosci.joined(separator: ", ")
                        
                        Text("Obrażenia: \(bron.iloscKosciObrazen)k\(bron.koscObrazen), Właściwości: \(wlasciwosciOpis)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundColor(.primary)
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
