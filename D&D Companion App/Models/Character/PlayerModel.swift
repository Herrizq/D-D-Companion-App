//
//  PlayerModel.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import Foundation

// -- Player -- //
final class Player {
    
    // --- Main Informations ---
    var imie: String = ""
    var rasa: Race = .czlowiek
    var klasa: Class = .wojownik
    var poziom: Int = 1
    var inspiracja: Bool = false
    var aktywneStany: Set<Condition> = []
    
    // --- Player's Base Statistics ---
    // Wartości bazowe, edytowane w systemie Point Buy
    var baseStatistics: [BasicStatistics: Int] = [
        .siła: 8, .zręczność: 8, .kondycja: 8, .inteligencja: 8, .mądrość: 8, .charyzma: 8
    ]
    
    // Wartości ostateczne, obliczone z uwzględnieniem bonusów z rasy
    var currentStatistics: [BasicStatistics: Int] {
        var finalne = baseStatistics
        for (stat, bonus) in rasa.skillsModifier {
            finalne[stat, default: 8] += bonus
        }
        return finalne
    }
    
    // --- Gameplay Functions ---
    func StatisticsModifier(for statystyka: BasicStatistics) -> Int {
        let wynik = currentStatistics[statystyka] ?? 10
        let modyfikator = floor(Double(wynik - 10) / 2.0)
        return Int(modyfikator)
    }

    // -- Proficiency --
    var savingThrowsProficiency: Set<BasicStatistics> = []
    var skillsProficiencyList: Set<Skills> = []
    
    // Właściwość obliczeniowa, która sama zbiera biegłości z rasy i klasy
    var combinedWeaponsProficiency: Set<String> {
        return rasa.proficiencyInWeapons.union(klasa.proficiencyInWeapons)
    }
    
    var proficiencyBonus: Int {
        return (poziom - 1) / 4 + 2
    }
    
    func SkillsModifier(for umiejętność: Skills) -> Int {
        let podstawa = StatisticsModifier(for: umiejętność.powiązanaStatystyka)
        let biegłość = skillsProficiencyList.contains(umiejętność) ? proficiencyBonus : 0
        return podstawa + biegłość
    }
    
    func SavingThromModifier(for statystyka: BasicStatistics) -> Int {
        let podstawa = StatisticsModifier(for: statystyka)
        let biegłość = savingThrowsProficiency.contains(statystyka) ? proficiencyBonus : 0
        return podstawa + biegłość
    }
    
    // --- Passive Senses ---
    var passiveWisdom: Int {
        return 10 + SkillsModifier(for: .percepcja)
    }

    // --- Battle Statistics ---
    var klasaPancerza: Int = 10
    var prędkość: Int = 30
    var inicjatywa: Int { return StatisticsModifier(for: .zręczność) }

    // -- Hit Points --
    var koscWytrzymalosci: HitDice = .k10
    var zuzyteKosciWytrzymalosci: Int = 0
    
    var hitPointsMaximum: Int {
        let modKondycji = StatisticsModifier(for: .kondycja)
        let pierwszyPoziomHP = koscWytrzymalosci.rawValue + modKondycji
        if poziom == 1 { return pierwszyPoziomHP }
        let sredniaWartoscKosci = (koscWytrzymalosci.rawValue / 2) + 1
        let dodatkowePoziomyHP = (poziom - 1) * (sredniaWartoscKosci + modKondycji)
        return pierwszyPoziomHP + dodatkowePoziomyHP
    }
    var currentHitPoints: Int = 10
    var temporaryHitPoints: Int = 0
    
    var successesInSavingThrows: Int = 0
    var failuresInSavingThrows: Int = 0
    
    // -- Carried Weapons --
    var carriedWeapons: [Weapon] = []
    
    // --- Attack Calculation ---
    /// Oblicza premie do ataku i obrażeń dla danej broni.
    func CalculateToHitBonuses(dlaBroni bron: Weapon) -> (trafienie: Int, obrazenia: String) {
        
        var uzywanaStatystyka: BasicStatistics = .siła // Domyślnie używamy Siły
        
        // ZASADA: Finezyjność (Finesse)
        // Jeśli broń jest finezyjna, pozwól użyć Zręczności, jeśli jej modyfikator jest wyższy.
        if bron.wlasciwosci.contains("Finezyjna") {
            if StatisticsModifier(for: .zręczność) > StatisticsModifier(for: .siła) {
                uzywanaStatystyka = .zręczność
            }
        }
        
        let modyfikatorAtrybutu = StatisticsModifier(for: uzywanaStatystyka)
        
        // Pełna logika sprawdzania biegłości (pozostaje bez zmian)
        let maBieglosc = combinedWeaponsProficiency.contains(bron.nazwa) || combinedWeaponsProficiency.contains(bron.kategoria.rawValue)
        let premiaZBiegłości = maBieglosc ? self.proficiencyBonus : 0
        
        // Premia do trafienia = modyfikator z atrybutu + premia z biegłości
        let premiaDoTrafienia = modyfikatorAtrybutu + premiaZBiegłości
        
        // Formuła obrażeń = kości broni + modyfikator z atrybutu
        let formulaObrazen = "\(bron.iloscKosciObrazen)k\(bron.koscObrazen) \(modyfikatorAtrybutu >= 0 ? "+" : "") \(modyfikatorAtrybutu)"
        
        return (premiaDoTrafienia, formulaObrazen)
    }

    // --- Descriptive Fields ---
    var atakIMagia: String = ""
    var ekwipunek: String = ""
    var cechyOsobowości: String = ""
    var ideały: String = ""
    var więzi: String = ""
    var słabości: String = ""
    var korzyściIZdolności: String = ""
}
