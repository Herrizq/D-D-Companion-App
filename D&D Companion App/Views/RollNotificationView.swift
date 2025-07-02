//
//  RollNotificationView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct RollNotificationView: View {
    let wynik: RollResult
    
    // Przyjmujemy postać i binding do ostatniego rzutu
    @Bindable var player: Player
    @Binding var ostatniRzut: RollResult?
    
    private var isUtilitySpell: Bool {
        // Jeśli rzut i modyfikator są zerowe, a nie ma ataku bronią,
        // zakładamy, że to czar użytkowy.
        return wynik.rzutKosci == 0 && wynik.modyfikator == 0 && wynik.bronDoAtaku == nil
    }

    var body: some View {
        VStack(spacing: 0) {
            // --- Główna część powiadomienia (wygląd bez zmian) ---
            HStack(spacing: 15) {
                Image(systemName: "die.face.6.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(wynik.tytul)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.gray)
                    
                    if isUtilitySpell {
                                           // Dla czarów użytkowych wyświetlamy tylko nazwę w formule
                                           if let formula = wynik.formula {
                                               Text(formula.capitalized)
                                                   .font(.title2).fontWeight(.bold).foregroundStyle(.white)
                                           }
                                       } else {
                                           // Dla normalnych rzutów wyświetlamy jak dawniej
                                           Text("\(wynik.rzutKosci) \(wynik.modyfikator >= 0 ? "+" : "") \(wynik.modyfikator)")
                                               .font(.title2).fontWeight(.bold).foregroundStyle(.white)
                                       }
                }
                
                Spacer()
                
                if !isUtilitySpell {
                                    Text("\(wynik.wynikOstateczny)")
                                        .font(.system(size: 44, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            
            // --- Przycisk do rzutu na obrażenia bronią ---
            if let bron = wynik.bronDoAtaku {
                Divider().background(Color.gray.opacity(0.5))
                
                Button(action: {
                    // Wywołujemy nową funkcję lokalną do rzutu na obrażenia
                    performDamageRoll(for: bron)
                }) {
                    let bonusy = player.calculateToHitBonuses(dlaBroni: bron)
                    Label("Rzuć na Obrażenia (\(bonusy.obrazenia))", systemImage: "shield.lefthalf.filled.slash")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                }
                .tint(.orange)
            }
            
            // --- Przycisk do rzutu na obrażenia czarem ---
            if let czar = wynik.czarDoAtaku, czar.iloscKosciObrazen != nil {
                Divider().background(Color.gray.opacity(0.5))
                
                Button(action: {
                    // Domyślnie rzucamy na obrażenia na bazowym poziomie czaru
                    performSpellDamageRoll(spell: czar, atLevel: czar.poziom)
                }) {
                    let formula = "\(czar.iloscKosciObrazen ?? 1)k\(czar.koscObrazen ?? 4)"
                    Label("Rzuć na Obrażenia (\(formula))", systemImage: "sparkles")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                }
                .tint(.blue)
            }
        }
        .background(.black.opacity(0.95))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.4), radius: 10, y: -5)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    // --- Prywatne metody do obsługi rzutów ---

    private func performDamageRoll(for weapon: Weapon) {
        let usedStat: BasicStatistics = weapon.wlasciwosci.contains("Finezyjna") && player.statisticsModifier(for: .zręczność) > player.statisticsModifier(for: .siła) ? .zręczność : .siła
        let damageModifier = player.statisticsModifier(for: usedStat)
        
        var diceSum = 0
        for _ in 0..<weapon.iloscKosciObrazen {
            diceSum += Int.random(in: 1...weapon.koscObrazen)
        }
        
        let damageResult = RollResult(
            tytul: "Obrażenia: \(weapon.nazwa)",
            wynikOstateczny: diceSum + damageModifier,
            rzutKosci: diceSum,
            modyfikator: damageModifier,
            formula: "\(weapon.iloscKosciObrazen)k\(weapon.koscObrazen) \(damageModifier >= 0 ? "+" : "") \(damageModifier)"
        )
        
        // Zastępujemy stary rzut nowym, aby zaktualizować powiadomienie
        ostatniRzut = damageResult
    }

    private func performSpellDamageRoll(spell: Spells, atLevel level: Int) {
        guard var iloscKosci = spell.iloscKosciObrazen, let kosc = spell.koscObrazen else { return }

        // POPRAWIONA LINIA:
        // Usuwamy "let id = spell.id" i używamy "spell.id" bezpośrednio
        if level > spell.poziom && ["leczenie-ran", "kula-ognia"].contains(spell.id) {
            iloscKosci += (level - spell.poziom)
        }
        
        var sumaRzutu = 0
        for _ in 0..<iloscKosci {
            sumaRzutu += Int.random(in: 1...kosc)
        }
        
        let modyfikatorObrazen = (spell.typObrazen == "Leczenie") ? player.spellcastingAbilityModifier : 0
        let formula = modyfikatorObrazen != 0 ? "\(iloscKosci)k\(kosc) + \(modyfikatorObrazen)" : "\(iloscKosci)k\(kosc)"

        let wynikObrazen = RollResult(
            tytul: spell.typObrazen == "Leczenie" ? "Leczenie: \(spell.nazwa)" : "Obrażenia: \(spell.nazwa)",
            wynikOstateczny: sumaRzutu + modyfikatorObrazen,
            rzutKosci: sumaRzutu,
            modyfikator: modyfikatorObrazen,
            formula: formula
        )
        
        ostatniRzut = wynikObrazen
    }
}
