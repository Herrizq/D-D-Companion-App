//
//  SavingThrowRowView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct SavingThrowRowView: View {
    let statystyka: BasicStatistics
    @Bindable var player: Player
    @Binding var ostatniRzut: RollResult?
    
    @State private var pokazOpcjeRzutuObronnego = false

    var body: some View {
        HStack {
            Button(action: toggleProficiency) {
                Image(systemName: player.savingThrowsProficiency.contains(statystyka) ? "largecircle.fill.circle" : "circle")
            }
            
            Text(statystyka.rawValue)
            Spacer()
            Text(modifierText).fontWeight(.bold)
        }
        .foregroundColor(.primary)
        .contentShape(Rectangle())
        .onTapGesture {
            if player.inspiracja {
                pokazOpcjeRzutuObronnego = true
            } else {
                performSavingThrow(withAdvantage: false)
            }
        }
        .confirmationDialog("Rzut Obronny: \(statystyka.rawValue)", isPresented: $pokazOpcjeRzutuObronnego, titleVisibility: .visible) {
            Button("Normalny rzut") { performSavingThrow(withAdvantage: false) }
            Button("Użyj Inspiracji (Przewaga)") { performSavingThrow(withAdvantage: true) }
            Button("Anuluj", role: .cancel) {}
        }
    }
    
    private var modifierText: String {
        let modifier = player.savingThrowModifier(for: statystyka)
        return modifier >= 0 ? "+\(modifier)" : "\(modifier)"
    }

    private func toggleProficiency() {
        if let index = player.savingThrowsProficiency.firstIndex(of: statystyka) {
            player.savingThrowsProficiency.remove(at: index)
        } else {
            player.savingThrowsProficiency.append(statystyka)
        }
    }
    
    private func performSavingThrow(withAdvantage: Bool) {
        if withAdvantage && player.inspiracja {
            player.inspiracja = false
        }
        
        let hasDisadvantage = player.aktywneStany.contains(.Otruty) || player.aktywneStany.contains(.Przestraszony)
        let modifier = player.savingThrowModifier(for: statystyka)
        var diceRoll = Int.random(in: 1...20)
        var rollTitle = "Rzut obronny: \(statystyka.rawValue)"
        
        if withAdvantage && !hasDisadvantage {
            diceRoll = max(diceRoll, Int.random(in: 1...20))
            rollTitle = "Rzut obronny (Przewaga): \(statystyka.rawValue)"
        } else if hasDisadvantage && !withAdvantage {
            diceRoll = min(diceRoll, Int.random(in: 1...20))
            rollTitle = "Rzut obronny (Utrudnienie): \(statystyka.rawValue)"
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
