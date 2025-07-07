import Foundation
import SwiftData
import Combine

enum ASIChoice: Codable, Hashable {
    case statIncrease(points: [BasicStatistics: Int]) // np. [.strength: 2] lub [.strength: 1, .dexterity: 1]
    case feat(Feat)
}

@Model
final class Player {
    // Pola z wartościami domyślnymi
    var imie: String = ""
    var rasa: Race = Race.czlowiek
    var klasa: Class = Class.wojownik
    var poziom: Int = 1
    var inspiracja: Bool = false
    var aktywneStany: [Condition] = []
    var baseStatistics: [BasicStatistics: Int] = [
        BasicStatistics.siła: 8, BasicStatistics.zręczność: 8, BasicStatistics.kondycja: 8,
        BasicStatistics.inteligencja: 8, BasicStatistics.mądrość: 8, BasicStatistics.charyzma: 8
    ]
    var savingThrowsProficiency: [BasicStatistics] = []
    var skillsProficiencyList: [Skills] = []
    var currentHitPoints: Int = 10
    var temporaryHitPoints: Int = 0
    var koscWytrzymalosci: HitDice = HitDice.k10
    var zuzyteKosciWytrzymalosci: Int = 0
    var successesInSavingThrows: Int = 0
    var failuresInSavingThrows: Int = 0
    var atakIMagia: String = ""
    var ekwipunek: String = ""
    
    
    // -- Rzeczy związane z Klerykiem -- //
    var clericDomain: ClericDomain?
    var channelDivinityUses: Int = 0
    var hasUsedDivineIntervention: Bool = false
    var deityName: String = ""
    
    // Domena Wiedzy
    var knowledgeDomainLanguages: [String] = []
    var knowledgeDomainExpertise: [Skills] = []
       
    // Domena Natury
    var natureDomainSkillProficiency: Skills?
    
    @Relationship(inverse: \Spells.learnedByNatureClerics)
    var natureDomainDruidCantrip: Spells?

    // Domena Wojny
    var warPriestUses: Int = 0
    
    //Domena Światła
    var protectiveFlareUses: Int = 0
    
    // -- Rzeczy związane z Wojownikiem -- //
    var fighterArchetype: FighterArchetype?
    var fightingStyles: [FightingStyle] = []
    var hasUsedSecondWind: Bool = false
    var actionSurgeUses: Int = 0
    var indomitableUses: Int = 0
    var eldritchKnightCurrentSpellSlots: [Int] = []
    
    
    // Zasoby Mistrza Bitewnego
    var superiorityDiceUsed: Int = 0
    var asiChoices: [Int: ASIChoice] = [:]
    
    @Relationship(inverse: \Maneuver.knowingPlayers)
    var maneuvers: [Maneuver]? = []
    
    @Relationship(inverse: \Spells.knownByEldritchKnights)
    var eldritchKnightKnownSpells: [Spells]? = []
    
    // Zmienione nazwy pól, aby były zgodne z ASCII
    var cechyOsobowosci: String = ""
    var idealy: String = ""
    var wiezi: String = ""
    var slabosci: String = ""
    var korzysciIZdolnosci: String = ""
    
    var preparedSpells: [String] = []
    var currentSpellSlots: [Int] = []
    
    var luckPointsUsed: Int = 0

    // Zmieniono na opcjonalny i dodano relację odwrotną
    @Relationship(inverse: \Weapon.owner)
    var carriedWeapons: [Weapon]? = []
    
    @Relationship(inverse: \Armor.inventoryOwner)
    var armorInventory: [Armor]? = []

    // Ta relacja definiuje, który pancerz jest założony.
    @Relationship(inverse: \Armor.equippedByPlayerAsArmor)
    var equippedArmor: Armor?
        
    // Ta relacja definiuje, która tarcza jest założona.
    @Relationship(inverse: \Armor.equippedByPlayerAsShield)
    var equippedShield: Armor?
    
    var studentOfWarProficiency: String?
       
    // Więź z Bronią (Mistyczny Rycerz)
    @Relationship(inverse: \Weapon.bondedPlayer)
    var bondedWeapons: [Weapon]? = []

    init() {
        self.currentHitPoints = self.hitPointsMaximum
        self.currentSpellSlots = self.maxSpellSlots
    }
}
