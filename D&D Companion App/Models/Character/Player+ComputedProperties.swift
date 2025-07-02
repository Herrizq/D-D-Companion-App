//
//  Player+ComputedProperties.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 02/07/2025.
//

import Foundation
import SwiftUI

extension Player {
    
    var maxActionSurgeUses: Int {
            return self.poziom >= 17 ? 2 : 1
        }
    // --- ZASOBY MISTRZA BITWY ---
        var maxSuperiorityDice: Int {
            guard fighterArchetype == .battleMaster else { return 0 }
            if poziom >= 15 { return 6 }
            if poziom >= 7 { return 5 }
            return 4
        }
    
    var klasaPancerza: Int {
            var baseAC = 10
            var dexModifier = self.statisticsModifier(for: .zręczność)
            
            // Sprawdzamy założony pancerz
            if let armor = self.equippedArmor {
                baseAC = armor.klasaPancerzaBazowa
                switch armor.modyfikatorZeZrecznosci {
                case "max 2":
                    dexModifier = min(dexModifier, 2)
                case "brak":
                    dexModifier = 0
                default: // "pełny"
                    break
                }
            }
            
            var totalAC = baseAC + dexModifier
            
            // Dodajemy bonus z tarczy
            if let shield = self.equippedShield {
                totalAC += shield.klasaPancerzaBazowa
            }
            
            // Dodajemy bonus ze stylu walki "Obrona"
            if self.fightingStyles.contains(.defense) && self.equippedArmor != nil {
                totalAC += 1
            }
            
            return totalAC
        }
    
    var maxManeuversKnown: Int {
        guard fighterArchetype == .battleMaster else { return 0 }
        if poziom >= 15 { return 9 }
        if poziom >= 10 { return 7 }
        if poziom >= 7 { return 5 }
        return 3
    }
        
        var superiorityDiceType: Int {
            guard fighterArchetype == .battleMaster else { return 0 }
            if poziom >= 18 { return 12 }
            if poziom >= 10 { return 10 }
            return 8
        }

        // --- ZASOBY MISTYCZNEGO RYCERZA ---
        // Logika slotów czarów dla Mistycznego Rycerza (1/3 caster)
        var eldritchKnightSpellSlots: [Int] {
            guard fighterArchetype == .eldritchKnight else { return [0,0,0,0] }
            let effectiveLevel = Int(ceil(Double(poziom) / 3.0))
            // Tabela slotów dla 1/3 castera
            let slots: [[Int]] = [
                /* 1*/ [2,0,0,0], /* 2*/ [3,0,0,0], /* 3*/ [3,0,0,0], /* 4*/ [4,2,0,0],
                /* 5*/ [4,2,0,0], /* 6*/ [4,2,0,0], /* 7*/ [4,3,0,0], /* 8*/ [4,3,0,0],
                /* 9*/ [4,3,0,0], /*10*/ [4,3,2,0], /*11*/ [4,3,2,0], /*12*/ [4,3,2,0],
                /*13*/ [4,3,3,0], /*14*/ [4,3,3,0], /*15*/ [4,3,3,0], /*16*/ [4,3,3,1],
                /*17*/ [4,3,3,1], /*18*/ [4,3,3,1], /*19*/ [4,3,3,2], /*20*/ [4,3,3,2]
            ]
            return slots[effectiveLevel - 1]
        }
    
    // Właściwości Obliczeniowe (Computed Properties)

    var currentStatistics: [BasicStatistics: Int] {
        var finalne = baseStatistics
        for (stat, bonus) in rasa.skillsModifier {
            finalne[stat, default: 8] += bonus
        }
        return finalne
    }

    var proficiencyBonus: Int {
        return (poziom - 1) / 4 + 2
    }

    var passiveWisdom: Int {
        return 10 + skillsModifier(for: .percepcja)
    }

    var inicjatywa: Int {
        return statisticsModifier(for: .zręczność)
    }

    var hitPointsMaximum: Int {
        let modKondycji = statisticsModifier(for: .kondycja)
        let pierwszyPoziomHP = koscWytrzymalosci.rawValue + modKondycji
        if poziom == 1 { return pierwszyPoziomHP }
        let sredniaWartoscKosci = (koscWytrzymalosci.rawValue / 2) + 1
        let dodatkowePoziomyHP = (poziom - 1) * (sredniaWartoscKosci + modKondycji)
        return pierwszyPoziomHP + dodatkowePoziomyHP
    }

    var combinedWeaponsProficiency: Set<String> {
        return rasa.proficiencyInWeapons.union(klasa.proficiencyInWeapons)
    }
    
    // --- Magia ---
    var canCastSpells: Bool {
            // Czy klasa bazowa jest klasą czarującą?
            if self.klasa.spellcastingAbility != nil {
                return true
            }
            // Czy subklasa daje zdolności magiczne?
            if self.fighterArchetype == .eldritchKnight {
                return true
            }
            // W przyszłości można tu dodać inne warunki, np. dla Łotra z subklasą magiczną
            
            return false
        }
    var primarySpellcastingAbility: BasicStatistics? {
        if self.fighterArchetype == .eldritchKnight {
            return .inteligencja
        }
        return self.klasa.spellcastingAbility
    }
    
    var spellcastingAbilityModifier: Int {
        guard let ability = primarySpellcastingAbility else { return 0 }
        return statisticsModifier(for: ability)
    }

    // ST Rzutu Obronnego na czar
    var spellSaveDC: Int {
        guard canCastSpells else { return 0 }
        return 8 + proficiencyBonus + spellcastingAbilityModifier
    }

    // Premia do ataku czarem
    var spellAttackModifier: Int {
        guard canCastSpells else { return 0 }
        return proficiencyBonus + spellcastingAbilityModifier
    }
    
    var maxSpellSlots: [Int] {
        let spellSlotsByLevel: [[Int]] = [
            [2, 0, 0, 0, 0, 0, 0, 0, 0], [3, 0, 0, 0, 0, 0, 0, 0, 0],
            [4, 2, 0, 0, 0, 0, 0, 0, 0], [4, 3, 0, 0, 0, 0, 0, 0, 0],
            [4, 3, 2, 0, 0, 0, 0, 0, 0], [4, 3, 3, 0, 0, 0, 0, 0, 0],
            [4, 3, 3, 1, 0, 0, 0, 0, 0], [4, 3, 3, 2, 0, 0, 0, 0, 0],
            [4, 3, 3, 3, 1, 0, 0, 0, 0], [4, 3, 3, 3, 2, 0, 0, 0, 0],
            [4, 3, 3, 3, 2, 1, 0, 0, 0], [4, 3, 3, 3, 2, 1, 0, 0, 0],
            [4, 3, 3, 3, 2, 1, 1, 0, 0], [4, 3, 3, 3, 2, 1, 1, 0, 0],
            [4, 3, 3, 3, 2, 1, 1, 1, 0], [4, 3, 3, 3, 2, 1, 1, 1, 0],
            [4, 3, 3, 3, 2, 1, 1, 1, 1], [4, 3, 3, 3, 3, 1, 1, 1, 1],
            [4, 3, 3, 3, 3, 2, 1, 1, 1], [4, 3, 3, 3, 3, 2, 2, 1, 1]
        ]
        guard klasa.spellcastingAbility != nil, poziom > 0, poziom <= spellSlotsByLevel.count else {
            return Array(repeating: 0, count: 9)
        }
        return spellSlotsByLevel[poziom - 1]
    }
    
    var maxEldritchKnightKnownSpells: Int {
            guard fighterArchetype == .eldritchKnight else { return 0 }
            
            // Tabela znanych czarów dla Mistycznego Rycerza
            let spellsKnownTable: [Int] = [
                // Poziom: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20
                           0, 0, 3, 4, 4, 4, 5, 6, 6, 7,  8,  8,  9, 10, 10, 11, 11, 11, 12, 13
            ]
            
            // Upewniamy się, że nie wyjdziemy poza zakres tablicy
            if poziom > 0 && poziom <= spellsKnownTable.count {
                return spellsKnownTable[poziom - 1]
            }
            return 0
        }
    var extraAttacks: Int {
        guard self.klasa == .wojownik else { return 1 }
        if poziom >= 20 { return 4 }
        if poziom >= 11 { return 3 }
        if poziom >= 5 { return 2 }
        return 1
    }
    
    var maxIndomitableUses: Int {
        guard self.klasa == .wojownik else { return 0 }
        if poziom >= 17 { return 3 }
        if poziom >= 13 { return 2 }
        if poziom >= 9 { return 1 }
        return 0
    }
    
    var maxPreparedSpells: Int {
        guard klasa.spellcastingType == .prepared, let ability = klasa.spellcastingAbility else { return 0 }
        let modifier = statisticsModifier(for: ability)
        return max(1, modifier + poziom)
    }
    

    // Metody obliczające modyfikatory

    func statisticsModifier(for statystyka: BasicStatistics) -> Int {
        let wynik = currentStatistics[statystyka] ?? 10
        let modyfikator = floor(Double(wynik - 10) / 2.0)
        return Int(modyfikator)
    }

    func skillsModifier(for umiejętność: Skills) -> Int {
        let podstawa = statisticsModifier(for: umiejętność.powiązanaStatystyka)
        let biegłość = skillsProficiencyList.contains(umiejętność) ? proficiencyBonus : 0
        
        // --- LOGIKA DLA WYBITNEGO ATLETY ---
        // Jeśli postać jest Czempionem na poziomie 7+ i nie ma biegłości w tej umiejętności...
        if biegłość == 0 && self.fighterArchetype == .champion && self.poziom >= 7 {
            let powiązanaStatystyka = umiejętność.powiązanaStatystyka
            // ...a umiejętność bazuje na Sile, Zręczności lub Kondycji...
            if powiązanaStatystyka == .siła || powiązanaStatystyka == .zręczność || powiązanaStatystyka == .kondycja {
                // ...dodaj połowę premii z biegłości.
                let halfProficiency = Int(ceil(Double(proficiencyBonus) / 2.0))
                return podstawa + halfProficiency
            }
        }
        
        return podstawa + biegłość
    }

    func savingThrowModifier(for statystyka: BasicStatistics) -> Int {
        let podstawa = statisticsModifier(for: statystyka)
        let biegłość = savingThrowsProficiency.contains(statystyka) ? proficiencyBonus : 0
        return podstawa + biegłość
    }

    func calculateToHitBonuses(dlaBroni bron: Weapon) -> (trafienie: Int, obrazenia: String) {
            var uzywanaStatystyka: BasicStatistics = .siła
            if bron.wlasciwosci.contains("Finezyjna") {
                if statisticsModifier(for: .zręczność) > statisticsModifier(for: .siła) {
                    uzywanaStatystyka = .zręczność
                }
            }
            let modyfikatorAtrybutu = statisticsModifier(for: uzywanaStatystyka)
            let maBieglosc = combinedWeaponsProficiency.contains(bron.nazwa) || combinedWeaponsProficiency.contains(bron.kategoria.rawValue)
            let premiaZBiegłości = maBieglosc ? self.proficiencyBonus : 0
            
            var premiaDoTrafienia = modyfikatorAtrybutu + premiaZBiegłości
            
            // --- LOGIKA DLA STYLU WALKI "ŁUCZNICTWO" ---
            if self.fightingStyles.contains(.archery) && bron.isRanged {
                premiaDoTrafienia += 2
            }
            
            let formulaObrazen = "\(bron.iloscKosciObrazen)k\(bron.koscObrazen) \(modyfikatorAtrybutu >= 0 ? "+" : "") \(modyfikatorAtrybutu)"
            
            return (premiaDoTrafienia, formulaObrazen)
        }
    
    func spellsToDisplay(allSpells: [Spells]) -> [Spells] {
        if self.fighterArchetype == .eldritchKnight {
            return allSpells.filter { self.eldritchKnightKnownSpells?.contains($0) ?? false }
        }
        
        if self.klasa.spellcastingType == .prepared {
            return allSpells.filter { self.preparedSpells.contains($0.id) }
        }
        
        // Logika dla innych klas znających czary (np. Bard, Czarownik)
        if self.klasa.spellcastingAbility != nil {
            return allSpells.filter { $0.dostepnyDlaKlas.contains(self.klasa.rawValue) }
        }
        
        return []
    }
    
    // Zwraca listę dostępnych sztuczek (cantrips)
    func cantrips(allSpells: [Spells]) -> [Spells] {
        let spellcastingClass = (self.fighterArchetype == .eldritchKnight) ? "Mag" : self.klasa.rawValue
        return allSpells.filter { $0.poziom == 0 && $0.dostepnyDlaKlas.contains(spellcastingClass) }
    }
    
    // Metody do zarządzania stanem postaci

    func longRest() {
        currentHitPoints = hitPointsMaximum
        let odzyskaneKosic = max(1, poziom / 2)
        zuzyteKosciWytrzymalosci = max(0, zuzyteKosciWytrzymalosci - odzyskaneKosic)
        successesInSavingThrows = 0
        failuresInSavingThrows = 0
        currentSpellSlots = maxSpellSlots
        
        // Resetowanie zasobów Wojownika
        hasUsedSecondWind = false
        actionSurgeUses = 0
        superiorityDiceUsed = 0
        indomitableUses = 0
    }
    
    func shortRest(ilosc: Int = 1) {
            // Resetowanie zasobów Wojownika, które odnawiają się po krótkim odpoczynku
            hasUsedSecondWind = false
            actionSurgeUses = 0
            superiorityDiceUsed = 0
        
        let dostepneKosci = poziom - zuzyteKosciWytrzymalosci
        guard ilosc <= dostepneKosci else { return }
        
        var odzyskanePW = 0
        for _ in 1...ilosc {
            let rzut = Int.random(in: 1...koscWytrzymalosci.rawValue)
            odzyskanePW += rzut + statisticsModifier(for: .kondycja)
        }
        
        currentHitPoints = min(hitPointsMaximum, currentHitPoints + odzyskanePW)
        zuzyteKosciWytrzymalosci += ilosc
        }
    
   func resetSpellSlots() {
        self.currentSpellSlots = self.maxSpellSlots
    }

   func applyClassBonuses() {
        self.savingThrowsProficiency = self.klasa.savingThrowsProficiency.map { $0 }
        self.koscWytrzymalosci = self.klasa.classHitDice
    }

    func applyRaceBonuses() {
        // Ta logika jest teraz w `currentStatistics`, ale zachowujemy dla prędkości
        // self.prędkość = self.rasa.movingSpeed // Prędkość powinna być polem, nie chcemy jej w modelu Race
    }
    
    func resetSubclassProperties() {
         // Resetuj dane związane z Wojownikiem
         fighterArchetype = nil
         superiorityDiceUsed = 0
        maneuvers?.removeAll()
        eldritchKnightKnownSpells?.removeAll()
         
         // W przyszłości, gdy dodasz inne klasy, ich resetowanie umieścisz tutaj
     }
}
