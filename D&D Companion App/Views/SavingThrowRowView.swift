//
//  SavingThrowRowView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct SavingThrowRowView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    let statystyka: BasicStatistics
    @Binding var postacBinding: Player
    
    @State private var pokazOpcjeRzutuObronnego = false

    var body: some View {
        HStack {
            Button(action: toggleProficiency) {
                Image(systemName: postacBinding.savingThrowsProficiency.contains(statystyka) ? "largecircle.fill.circle" : "circle")
            }
            
            Text(statystyka.rawValue)
            Spacer()
            Text(modifierText).fontWeight(.bold)
        }
        .foregroundColor(.primary)
        .contentShape(Rectangle())
        .onTapGesture {
            if postacBinding.inspiracja {
                pokazOpcjeRzutuObronnego = true
            } else {
                viewModel.wykonajRzutObronny(statystyka: statystyka, zPrzewaga: false)
            }
        }
        .confirmationDialog("Rzut Obronny: \(statystyka.rawValue)", isPresented: $pokazOpcjeRzutuObronnego, titleVisibility: .visible) {
            Button("Normalny rzut") { viewModel.wykonajRzutObronny(statystyka: statystyka, zPrzewaga: false) }
            // Ten przycisk jest już wewnątrz warunku, więc nie trzeba go tu sprawdzać
            Button("Użyj Inspiracji (Przewaga)") { viewModel.wykonajRzutObronny(statystyka: statystyka, zPrzewaga: true) }
            Button("Anuluj", role: .cancel) {}
        }
        .buttonStyle(.plain) // Ważne, aby to zostawić!
    }
    private var modifierText: String {
        let modifier = postacBinding.SavingThromModifier(for: statystyka)
        return modifier >= 0 ? "+\(modifier)" : "\(modifier)"
    }

    private func toggleProficiency() {
        if postacBinding.savingThrowsProficiency.contains(statystyka) {
            postacBinding.savingThrowsProficiency.remove(statystyka)
        } else {
            postacBinding.savingThrowsProficiency.insert(statystyka)
        }
    }
    
    private func performSavingThrow() {
        viewModel.wykonajRzutObronny(statystyka: statystyka)
    }
}
