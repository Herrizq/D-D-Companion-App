//
//  SpellRowView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 02/07/2025.
//

import SwiftUI

struct SpellRowView: View {
    let czar: Spells
    @Bindable var player: Player
    let onRowTapped: () -> Void
    @Binding var ostatniRzut: RollResult?
    
    @State private var showCastingOptions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(czar.nazwa).font(.headline)
                    Text(czar.opis)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "info.circle").font(.title3).foregroundColor(.accentColor)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onRowTapped()
            }
            
            Button(action: {
                if czar.poziom == 0 {
                    castSpell(atLevel: 0)
                } else {
                    showCastingOptions = true
                }
            }) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Rzuć czar")
                }
            }
            .buttonStyle(.bordered)
            .disabled(isUnavailable)
            .padding(.top, 4)
        }
        .padding(.vertical, 6)
        .confirmationDialog("Rzuć '\(czar.nazwa)' używając komórki...", isPresented: $showCastingOptions, titleVisibility: .visible) {
            ForEach((czar.poziom..<10), id: \.self) { poziom in
                let index = poziom - 1
                if index < player.currentSpellSlots.count, player.currentSpellSlots[index] > 0 {
                    Button("Poziom \(poziom) (\(player.currentSpellSlots[index]) dost.)") {
                        castSpell(atLevel: poziom)
                    }
                }
            }
        }
    }
    
    private var isUnavailable: Bool {
        guard czar.poziom > 0 else { return false }
        let usableLevels = czar.poziom..<10
        let canCast = usableLevels.contains { level in
            let index = level - 1
            guard index < player.currentSpellSlots.count else { return false }
            return player.currentSpellSlots[index] > 0
        }
        return !canCast
    }
    
    private func castSpell(atLevel level: Int) {
        if level > 0 {
            useSpellSlot(atLevel: level)
        }
        
        print("DEBUG: Próba rzucenia czaru o nazwie: '\(czar.nazwa)' (ID: \(czar.id))")
        
        if czar.wymagaAtaku == true {
            performSpellAttackRoll(spell: czar, atLevel: level)
            // Sprawdzamy, czy czar zadaje obrażenia
        } else if (czar.iloscKosciObrazen ?? 0) > 0 {
            performSpellDamageRoll(spell: czar, atLevel: level)
            // W przeciwnym wypadku to czar użytkowy
        } else {
            let utilitySpellResult = RollResult(
                tytul: "Rzucono czar", wynikOstateczny: 0, rzutKosci: 0, modyfikator: 0, formula: czar.nazwa
            )
            // Bezpośrednio ustawiamy stan
            withAnimation(.spring()) {
                ostatniRzut = utilitySpellResult
            }
        }
    }
    
    private func useSpellSlot(atLevel level: Int) {
        let index = level - 1
        guard index >= 0, player.currentSpellSlots.indices.contains(index), player.currentSpellSlots[index] > 0 else { return }
        player.currentSpellSlots[index] -= 1
    }
    
    private func performSpellAttackRoll(spell: Spells, atLevel level: Int) {
        let diceRoll = Int.random(in: 1...20)
        let modifier = player.spellAttackModifier
        let result = RollResult(
            tytul: "Atak Czarem: \(spell.nazwa) (\(level) poz.)",
            wynikOstateczny: diceRoll + modifier,
            rzutKosci: diceRoll,
            modyfikator: modifier,
            czarDoAtaku: spell
        )
        withAnimation(.spring()) {
            ostatniRzut = result
        }
    }
    
    private func performSpellDamageRoll(spell: Spells, atLevel level: Int) {
        guard var diceCount = spell.iloscKosciObrazen, let diceType = spell.koscObrazen else { return }
        
        if level > spell.poziom, ["leczenie-ran", "kula-ognia"].contains(spell.id) {
            diceCount += (level - spell.poziom)
        }
        
        var totalRoll = 0
        for _ in 0..<diceCount {
            totalRoll += Int.random(in: 1...diceType)
        }
        
        let damageModifier = (spell.typObrazen == "Leczenie") ? player.spellcastingAbilityModifier : 0
        let formula = damageModifier != 0 ? "\(diceCount)k\(diceType) + \(damageModifier)" : "\(diceCount)k\(diceType)"
        
        let result = RollResult(
            tytul: spell.typObrazen == "Leczenie" ? "Leczenie: \(spell.nazwa)" : "Obrażenia: \(spell.nazwa)",
            wynikOstateczny: totalRoll + damageModifier,
            rzutKosci: totalRoll,
            modyfikator: damageModifier,
            formula: formula
        )
        withAnimation(.spring()) {
            ostatniRzut = result
        }
    }
}
