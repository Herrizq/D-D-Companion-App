//
//  SkillsRowView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct UmiejetnoscRowView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @State private var pokazOpcjeRzutu = false
    
    let umiejetnosc: Skills
    @Binding var postacBinding: Player
    
    var body: some View {
        HStack {
            Button {
                toggleBieglosc()
            } label: {
                Image(systemName: postacBinding.skillsProficiencyList.contains(umiejetnosc) ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(postacBinding.skillsProficiencyList.contains(umiejetnosc) ? .green : .secondary)
            }
            .buttonStyle(.plain)

            Button {
                if viewModel.postac.inspiracja {
                    pokazOpcjeRzutu = true
                } else {
                    viewModel.SkillRoll(umiejetnosc: umiejetnosc, zPrzewaga: false)
                }
            } label: {
                HStack {
                    Text(umiejetnosc.rawValue)
                    Text("(\(umiejetnosc.powiązanaStatystyka.rawValue.prefix(3)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(modyfikatorTekst)
                        .fontWeight(.bold)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .confirmationDialog("Wykonaj test umiejętności", isPresented: $pokazOpcjeRzutu, titleVisibility: .visible) {
            Button("Normalny rzut") {
                viewModel.SkillRoll(umiejetnosc: umiejetnosc, zPrzewaga: false)
            }
            
            if viewModel.postac.inspiracja {
                Button("Użyj Inspiracji (Przewaga)") {
                    viewModel.SkillRoll(umiejetnosc: umiejetnosc, zPrzewaga: true)
                }
            }
            
            Button("Anuluj", role: .cancel) {}
        }
    }
    
    private func toggleBieglosc() {
        if postacBinding.skillsProficiencyList.contains(umiejetnosc) {
            postacBinding.skillsProficiencyList.remove(umiejetnosc)
        } else {
            postacBinding.skillsProficiencyList.insert(umiejetnosc)
        }
    }
    
    private var modyfikatorTekst: String {
        let modyfikator = postacBinding.SkillsModifier(for: umiejetnosc)
        return modyfikator >= 0 ? "+\(modyfikator)" : "\(modyfikator)"
    }
}
