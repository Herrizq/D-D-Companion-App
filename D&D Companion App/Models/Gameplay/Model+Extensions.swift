import Foundation

// MARK: - Rozszerzenia Modeli do Tworzenia Akcji Bojowych

// Usunęliśmy 'private', aby rozszerzenia były dostępne w całej aplikacji.
extension Weapon {
    func asCombatAction(for player: Player) -> CombatAction {
        let bonuses = player.calculateToHitBonuses(dlaBroni: self)
        return CombatAction(
            id: "weapon_\(self.id)",
            name: self.nazwa,
            description: "Szczegółowy opis broni.",
            source: self.kategoria.rawValue,
            range: self.isRanged ? "Dystansowa" : "5 ft.",
            hitBonus: "+\(bonuses.trafienie)",
            damage: bonuses.obrazenia,
            damageType: self.typObrazen,
            rollable: .weapon(self)
        )
    }
}

extension Armor {
    func asCombatAction() -> CombatAction {
        let acDescription = "KP: \(self.klasaPancerzaBazowa)" + (self.typ != "Tarcza" ? " + mod. ze Zręczności (\(self.modyfikatorZeZrecznosci))" : "")
        return CombatAction(
            id: "armor_\(self.id)",
            name: self.nazwa,
            description: acDescription,
            source: self.typ,
            range: "-",
            hitBonus: "-",
            damage: "-",
            damageType: "-",
            rollable: .none
        )
    }
}

extension Spells {
    func asCombatAction(for player: Player) -> CombatAction {
        let hit = player.spellAttackModifier
        return CombatAction(
            id: "spell_\(self.id)",
            name: self.nazwa,
            description: self.opis,
            source: self.poziom == 0 ? "Sztuczka" : "Czar poz. \(self.poziom)",
            range: self.zasieg,
            hitBonus: self.wymagaAtaku == true ? "+\(hit)" : "-",
            damage: "\(self.iloscKosciObrazen ?? 0)k\(self.koscObrazen ?? 0)",
            damageType: self.typObrazen ?? "",
            rollable: .spell(self)
        )
    }
}
