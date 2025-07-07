//
//  SkillsRowView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct UmiejetnoscRowView: View {
    let umiejetnosc: Skills
    @Bindable var player: Player
    @Binding var ostatniRzut: RollResult?
    
    @State private var pokazOpcjeRzutu = false
    
    var body: some View {
        HStack {
            Button {
                toggleBieglosc()
            } label: {
                Image(systemName: player.skillsProficiencyList.contains(umiejetnosc) ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(player.skillsProficiencyList.contains(umiejetnosc) ? .green : .secondary)
            }
            .buttonStyle(.plain)

            Button {
                if player.inspiracja {
                    pokazOpcjeRzutu = true
                } else {
                    performSkillCheck(withAdvantage: false)
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
            Button("Normalny rzut") { performSkillCheck(withAdvantage: false) }
            if player.inspiracja {
                Button("Użyj Inspiracji (Przewaga)") { performSkillCheck(withAdvantage: true) }
            }
            Button("Anuluj", role: .cancel) {}
        }
    }
    
    private func toggleBieglosc() {
        if let index = player.skillsProficiencyList.firstIndex(of: umiejetnosc) {
            player.skillsProficiencyList.remove(at: index)
        } else {
            player.skillsProficiencyList.append(umiejetnosc)
        }
    }
    
    private var modyfikatorTekst: String {
        let modyfikator = player.skillsModifier(for: umiejetnosc)
        return modyfikator >= 0 ? "+\(modyfikator)" : "\(modyfikator)"
    }

    private func performSkillCheck(withAdvantage: Bool) {
        if withAdvantage && player.inspiracja {
            player.inspiracja = false
        }
        
        let hasDisadvantage = player.aktywneStany.contains(.Otruty) || player.aktywneStany.contains(.Przestraszony)
        let modifier = player.skillsModifier(for: umiejetnosc)
        var diceRoll = Int.random(in: 1...20)
        var rollTitle = "Test: \(umiejetnosc.rawValue)"
        
        if withAdvantage && !hasDisadvantage {
            diceRoll = max(diceRoll, Int.random(in: 1...20))
            rollTitle = "Test (Przewaga): \(umiejetnosc.rawValue)"
        } else if hasDisadvantage && !withAdvantage {
            diceRoll = min(diceRoll, Int.random(in: 1...20))
            rollTitle = "Test (Utrudnienie): \(umiejetnosc.rawValue)"
        }
        
        let rollResult = RollResult(
            tytul: rollTitle,
            wynikOstateczny: diceRoll + modifier,
            rzutKosci: diceRoll,
            modyfikator: modifier
        )
        ostatniRzut = rollResult
    }
}
