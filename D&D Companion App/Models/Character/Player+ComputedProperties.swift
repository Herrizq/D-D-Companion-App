import Foundation
import SwiftUI
import SwiftData

extension Player {
    
    // MARK: - Podstawowe Statystyki i Modyfikatory
    
    var currentStatistics: [BasicStatistics: Int] {
        var finalStats = baseStatistics
        
        for (stat, bonus) in rasa.skillsModifier {
            finalStats[stat, default: 0] += bonus
        }
        
        for (level, choice) in asiChoices where self.poziom >= level {
            if case .statIncrease(let points) = choice {
                for (stat, bonus) in points {
                    finalStats[stat, default: 0] += bonus
                }
            }
        }
        
        if self.learnedFeats.contains(where: { $0.id == "twardziel" }) {
            finalStats[.kondycja, default: 0] += 1
        }
        
        return finalStats
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

    func statisticsModifier(for statystyka: BasicStatistics) -> Int {
        let wynik = currentStatistics[statystyka] ?? 10
        let modyfikator = floor(Double(wynik - 10) / 2.0)
        return Int(modyfikator)
    }

    func skillsModifier(for umiejętność: Skills) -> Int {
        let podstawa = statisticsModifier(for: umiejętność.powiązanaStatystyka)
        let maBieglosc = skillsProficiencyList.contains(umiejętność) || self.natureDomainSkillProficiency == umiejętność
        var premiaZBiegłości = maBieglosc ? proficiencyBonus : 0
        
        if self.knowledgeDomainExpertise.contains(umiejętność) {
            premiaZBiegłości = proficiencyBonus * 2
        }
        
        if premiaZBiegłości == 0, self.fighterArchetype == .champion, self.poziom >= 7 {
            let powiązanaStatystyka = umiejętność.powiązanaStatystyka
            if powiązanaStatystyka == .siła || powiązanaStatystyka == .zręczność || powiązanaStatystyka == .kondycja {
                let halfProficiency = Int(ceil(Double(proficiencyBonus) / 2.0))
                return podstawa + halfProficiency
            }
        }
        
        return podstawa + premiaZBiegłości
    }

    func savingThrowModifier(for statystyka: BasicStatistics) -> Int {
        let podstawa = statisticsModifier(for: statystyka)
        let biegłość = savingThrowsProficiency.contains(statystyka) ? proficiencyBonus : 0
        return podstawa + biegłość
    }

    // MARK: - Walka i Ekwipunek
    
    var hitPointsMaximum: Int {
        let modKondycji = statisticsModifier(for: .kondycja)
        let pierwszyPoziomHP = koscWytrzymalosci.rawValue + modKondycji
        if poziom == 1 { return pierwszyPoziomHP }
        let sredniaWartoscKosci = (koscWytrzymalosci.rawValue / 2) + 1
        let dodatkowePoziomyHP = (poziom - 1) * (sredniaWartoscKosci + modKondycji)
        return pierwszyPoziomHP + dodatkowePoziomyHP
    }
    
    var klasaPancerza: Int {
        var baseAC = 10
        var dexModifier = self.statisticsModifier(for: .zręczność)
        
        if let armor = self.equippedArmor {
            baseAC = armor.klasaPancerzaBazowa
            switch armor.modyfikatorZeZrecznosci {
            case "max 2": dexModifier = min(dexModifier, 2)
            case "brak": dexModifier = 0
            default: break
            }
        }
        
        var totalAC = baseAC + dexModifier
        if let shield = self.equippedShield { totalAC += shield.klasaPancerzaBazowa }
        if self.fightingStyles.contains(.defense) && self.equippedArmor != nil { totalAC += 1 }
        
        return totalAC
    }

    var combinedWeaponsProficiency: Set<String> {
        return rasa.proficiencyInWeapons.union(klasa.proficiencyInWeapons)
    }

    func calculateToHitBonuses(dlaBroni bron: Weapon) -> (trafienie: Int, obrazenia: String) {
        var uzywanaStatystyka: BasicStatistics = .siła
        if bron.wlasciwosci.contains("Finezyjna"), statisticsModifier(for: .zręczność) > statisticsModifier(for: .siła) {
            uzywanaStatystyka = .zręczność
        }
        let modyfikatorAtrybutu = statisticsModifier(for: uzywanaStatystyka)
        let maBieglosc = combinedWeaponsProficiency.contains(bron.nazwa) || combinedWeaponsProficiency.contains(bron.kategoria.rawValue)
        let premiaZBiegłości = maBieglosc ? self.proficiencyBonus : 0
        
        var premiaDoTrafienia = modyfikatorAtrybutu + premiaZBiegłości
        
        if self.fightingStyles.contains(.archery) && bron.isRanged {
            premiaDoTrafienia += 2
        }
        
        var formulaObrazen = "\(bron.iloscKosciObrazen)k\(bron.koscObrazen) \(modyfikatorAtrybutu >= 0 ? "+" : "") \(modyfikatorAtrybutu)"
        
        if self.poziom >= 8, let domain = self.clericDomain, domain.hasDivineStrike {
            let dice = self.poziom >= 14 ? "2k8" : "1k8"
            formulaObrazen += " + \(dice) (\(domain.divineStrikeDamageType))"
        }
        
        return (premiaDoTrafienia, formulaObrazen)
    }

    // MARK: - Zdolności Klasowe i Archetypów
    
    var asiLevels: [Int] {
        var levels = [4, 8, 12, 16, 19]
        if self.klasa == .wojownik { levels.append(contentsOf: [6, 14]) }
        return levels.sorted()
    }

    var learnedFeats: [Feat] {
        var feats: [Feat] = []
        for (level, choice) in asiChoices where self.poziom >= level {
            if case .feat(let feat) = choice { feats.append(feat) }
        }
        return feats
    }
    
    var extraAttacks: Int {
        guard self.klasa == .wojownik else { return 1 }
        if poziom >= 20 { return 4 }
        if poziom >= 11 { return 3 }
        if poziom >= 5 { return 2 }
        return 1
    }
    
    var maxActionSurgeUses: Int {
        return self.poziom >= 17 ? 2 : 1
    }
    
    var maxIndomitableUses: Int {
        guard self.klasa == .wojownik else { return 0 }
        if poziom >= 17 { return 3 }
        if poziom >= 13 { return 2 }
        if poziom >= 9 { return 1 }
        return 0
    }

    var maxSuperiorityDice: Int {
        guard fighterArchetype == .battleMaster else { return 0 }
        if poziom >= 15 { return 6 }
        if poziom >= 7 { return 5 }
        return 4
    }
    
    var superiorityDiceType: Int {
        guard fighterArchetype == .battleMaster else { return 0 }
        if poziom >= 18 { return 12 }
        if poziom >= 10 { return 10 }
        return 8
    }
    
    var maxManeuversKnown: Int {
        guard fighterArchetype == .battleMaster else { return 0 }
        if poziom >= 15 { return 9 }
        if poziom >= 10 { return 7 }
        if poziom >= 7 { return 5 }
        return 3
    }

    var maxLuckPoints: Int {
        return self.learnedFeats.contains(where: { $0.id == "szczesliwiec" }) ? 3 : 0
    }
    
    var maxWarPriestUses: Int {
        guard let domain = self.clericDomain, domain == .war else { return 0 }
        return max(1, self.statisticsModifier(for: .mądrość))
    }
    
    var maxProtectiveFlareUses: Int {
        guard let domain = self.clericDomain, domain == .light else { return 0 }
        return max(1, self.statisticsModifier(for: .mądrość))
    }
    
    var maxChannelDivinityUses: Int {
        guard self.klasa == .kleryk else { return 0 }
        if poziom >= 18 { return 3 }
        if poziom >= 6 { return 2 }
        if poziom >= 2 { return 1 }
        return 0
    }
    
    var destroyUndeadCR: Double {
        guard self.klasa == .kleryk else { return 0 }
        if poziom >= 17 { return 4 }
        if poziom >= 14 { return 3 }
        if poziom >= 11 { return 2 }
        if poziom >= 8 { return 1 }
        if poziom >= 5 { return 0.5 }
        return 0
    }

    // MARK: - Logika Magii
    
    var canCastSpells: Bool {
        if self.klasa.spellcastingAbility != nil { return true }
        if self.fighterArchetype == .eldritchKnight { return true }
        return false
    }
    
    var isEldritchKnight: Bool {
        return self.fighterArchetype == .eldritchKnight
    }
    
    var primarySpellcastingAbility: BasicStatistics? {
        if self.isEldritchKnight { return .inteligencja }
        return self.klasa.spellcastingAbility
    }
    
    var spellcastingAbilityModifier: Int {
        guard let ability = primarySpellcastingAbility else { return 0 }
        return statisticsModifier(for: ability)
    }
    
    var spellSaveDC: Int {
        guard canCastSpells else { return 0 }
        return 8 + proficiencyBonus + spellcastingAbilityModifier
    }
    
    var spellAttackModifier: Int {
        guard canCastSpells else { return 0 }
        return proficiencyBonus + spellcastingAbilityModifier
    }
    
    var eldritchKnightSpellSlots: [Int] {
        guard isEldritchKnight else { return [] }
        let effectiveLevel = Int(ceil(Double(poziom) / 3.0))
        let slots: [[Int]] = [ [2,0,0,0], [3,0,0,0], [3,0,0,0], [4,2,0,0], [4,2,0,0], [4,2,0,0], [4,3,0,0], [4,3,0,0], [4,3,0,0], [4,3,2,0], [4,3,2,0], [4,3,2,0], [4,3,3,0], [4,3,3,0], [4,3,3,0], [4,3,3,1], [4,3,3,1], [4,3,3,1], [4,3,3,2], [4,3,3,2] ]
        // Bezpieczny dostęp do tablicy
        return (effectiveLevel > 0 && effectiveLevel <= slots.count) ? slots[effectiveLevel - 1] : []
    }
    
    var maxSpellSlots: [Int] {
        let spellSlotsByLevel: [[Int]] = [ [2,0,0,0,0,0,0,0,0], [3,0,0,0,0,0,0,0,0], [4,2,0,0,0,0,0,0,0], [4,3,0,0,0,0,0,0,0], [4,3,2,0,0,0,0,0,0], [4,3,3,0,0,0,0,0,0], [4,3,3,1,0,0,0,0,0], [4,3,3,2,0,0,0,0,0], [4,3,3,3,1,0,0,0,0], [4,3,3,3,2,0,0,0,0], [4,3,3,3,2,1,0,0,0], [4,3,3,3,2,1,0,0,0], [4,3,3,3,2,1,1,0,0], [4,3,3,3,2,1,1,0,0], [4,3,3,3,2,1,1,1,0], [4,3,3,3,2,1,1,1,0], [4,3,3,3,2,1,1,1,1], [4,3,3,3,3,1,1,1,1], [4,3,3,3,3,2,1,1,1], [4,3,3,3,3,2,2,1,1] ]
        guard klasa.spellcastingAbility != nil, poziom > 0, poziom <= spellSlotsByLevel.count else {
            return Array(repeating: 0, count: 9)
        }
        return spellSlotsByLevel[poziom - 1]
    }
    
    func useSpellSlot(atLevel level: Int) {
        let index = level - 1
        // Upewniamy się, że nie próbujemy zużyć slotu dla sztuczek (poziom 0)
        guard level > 0, index >= 0 else { return }
        
        if self.isEldritchKnight {
            if self.eldritchKnightCurrentSpellSlots.indices.contains(index), self.eldritchKnightCurrentSpellSlots[index] > 0 {
                self.eldritchKnightCurrentSpellSlots[index] -= 1
            }
        } else {
            if self.currentSpellSlots.indices.contains(index), self.currentSpellSlots[index] > 0 {
                self.currentSpellSlots[index] -= 1
            }
        }
    }
    
    var maxEldritchKnightKnownSpells: Int {
        guard isEldritchKnight else { return 0 }
        let spellsKnownTable: [Int] = [0,0,3,4,4,4,5,6,6,7,8,8,9,10,10,11,11,11,12,13]
        if poziom > 0 && poziom <= spellsKnownTable.count { return spellsKnownTable[poziom - 1] }
        return 0
    }
    
    var maxPreparedSpells: Int {
        guard klasa.spellcastingType == .prepared, let ability = klasa.spellcastingAbility else { return 0 }
        let modifier = statisticsModifier(for: ability)
        return max(1, modifier + poziom)
    }

    func domainSpells(allSpells: [Spells]) -> [Spells] {
        guard let domain = self.clericDomain else { return [] }
        var spellIDs: [String] = []
        for (level, ids) in domain.spellIDs where self.poziom >= level {
            spellIDs.append(contentsOf: ids)
        }
        return allSpells.filter { spellIDs.contains($0.id) }
    }
    
    func spellsToDisplay(allSpells: [Spells]) -> [Spells] {
        if self.isEldritchKnight {
            return self.eldritchKnightKnownSpells ?? []
        }
        if self.klasa == .kleryk {
            let prepared = allSpells.filter { self.preparedSpells.contains($0.id) }
            let domain = domainSpells(allSpells: allSpells)
            return Array(Set(prepared + domain))
        }
        if self.klasa.spellcastingAbility != nil {
            return allSpells.filter { $0.dostepnyDlaKlas.contains(self.klasa.rawValue) }
        }
        return []
    }
    
    func cantrips(allSpells: [Spells]) -> [Spells] {
        let spellcastingClass = self.isEldritchKnight ? "Mag" : self.klasa.rawValue
        return allSpells.filter { $0.poziom == 0 && $0.dostepnyDlaKlas.contains(spellcastingClass) }
    }
    
    // MARK: - Metody Zarządzania Stanem i Odpoczynkiem
    
    func useSurvivor() {
        guard self.currentHitPoints < (self.hitPointsMaximum / 2) else { return }
        let healingAmount = 5 + self.statisticsModifier(for: .kondycja)
        self.currentHitPoints = min(self.hitPointsMaximum, self.currentHitPoints + healingAmount)
    }
    
    func useRelentless() {
        guard self.fighterArchetype == .battleMaster, self.superiorityDiceUsed >= self.maxSuperiorityDice else { return }
        self.superiorityDiceUsed -= 1
    }
    
    func longRest() {
        currentHitPoints = hitPointsMaximum
        let odzyskaneKosci = max(1, poziom / 2)
        zuzyteKosciWytrzymalosci = max(0, zuzyteKosciWytrzymalosci - odzyskaneKosci)
        successesInSavingThrows = 0
        failuresInSavingThrows = 0
        currentSpellSlots = maxSpellSlots
        if isEldritchKnight {
            eldritchKnightCurrentSpellSlots = eldritchKnightSpellSlots
        }
        hasUsedSecondWind = false
        actionSurgeUses = 0
        superiorityDiceUsed = 0
        indomitableUses = 0
        luckPointsUsed = 0
        channelDivinityUses = 0
        hasUsedDivineIntervention = false
        warPriestUses = 0
        protectiveFlareUses = 0
    }
    
    func shortRest() {
        hasUsedSecondWind = false
        actionSurgeUses = 0
        superiorityDiceUsed = 0
        channelDivinityUses = 0
        protectiveFlareUses = 0
    }
    
    func applyClassBonuses() {
        self.savingThrowsProficiency = Array(self.klasa.savingThrowsProficiency)
        self.koscWytrzymalosci = self.klasa.classHitDice
    }
    
    func applyRaceBonuses() { }
    
    func resetSubclassProperties() {
        fighterArchetype = nil
        superiorityDiceUsed = 0
        maneuvers?.removeAll()
        eldritchKnightKnownSpells?.removeAll()
        fightingStyles.removeAll()
        studentOfWarProficiency = nil
        bondedWeapons?.removeAll()
        clericDomain = nil
        knowledgeDomainExpertise.removeAll()
        knowledgeDomainLanguages.removeAll()
        natureDomainSkillProficiency = nil
        natureDomainDruidCantrip = nil
        eldritchKnightCurrentSpellSlots.removeAll()
    }
    
    // MARK: - Metody Wykonywania Akcji
    
    func performWeaponAttack(with weapon: Weapon) -> RollResult {
        let bonuses = self.calculateToHitBonuses(dlaBroni: weapon)
        let roll = Int.random(in: 1...20)
        return RollResult(tytul: "Atak: \(weapon.nazwa)", wynikOstateczny: roll + bonuses.trafienie, rzutKosci: roll, modyfikator: bonuses.trafienie, bronDoAtaku: weapon)
    }
    
    func performSpellAttack(spell: Spells, atLevel level: Int) -> RollResult {
        let roll = Int.random(in: 1...20)
        let modifier = self.spellAttackModifier
        return RollResult(tytul: "Atak Czarem: \(spell.nazwa)", wynikOstateczny: roll + modifier, rzutKosci: roll, modyfikator: modifier, czarDoAtaku: spell)
    }
}
