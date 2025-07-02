//
//  Class.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import Foundation

enum SpellcastingType {
    case prepared, known
}

enum FighterArchetype: String, Codable, CaseIterable, Hashable {
    case battleMaster = "Mistrz Bitewny"
    case champion = "Czempion"
    case eldritchKnight = "Mistyczny Rycerz"
}

enum FightingStyle: String, Codable, CaseIterable, Hashable {
    case archery = "Łucznictwo" // +2 do ataku bronią dystansową
    case defense = "Obrona" // +1 do KP
    case dueling = "Walka Szermiercza" // +2 do obrażeń z bronią jednoręczną
    case greatWeaponFighting = "Walka Bronią Dwuręczną" // Możliwość przerzucenia 1 i 2 na kościach obrażeń
    case protection = "Ochrona" // Użycie reakcji, by utrudnić atak przeciwnikowi
    case twoWeaponFighting = "Walka Dwiema Broniami" // Dodanie modyfikatora do obrażeń z drugiej broni
}

// -- Classes -- //
enum Class: String, CaseIterable, Codable, Identifiable, Hashable {
    case barbarzynca = "Barbarzyńca"
    case bard = "Bard"
    case druid = "Druid"
    case kleryk = "Kleryk"
    case lotr = "Łotr"
    case mag = "Mag"
    case mnich = "Mnich"
    case paladyn = "Paladyn"
    case lowca = "Łowca"
    case wojownik = "Wojownik"
    case zaklinacz = "Zaklinacz"
    case czarownik = "Czarownik"
    
    var id: String { self.rawValue }
    
    var subclassSelectionLevel: Int {
           switch self {
           case .kleryk, .druid, .mag, .czarownik:
               return 2
           case .wojownik, .lotr, .lowca, .bard, .barbarzynca, .mnich, .paladyn:
               return 3
           default:
               return 1 // Większość klas wybiera na poziomach 1-3
           }
       }
    
    var classMainSill: BasicStatistics {
        switch self {
        case .barbarzynca, .paladyn, .wojownik: return .siła
        case .bard, .czarownik, .zaklinacz: return .charyzma
        case .druid, .kleryk, .mnich: return .mądrość
        case .lotr, .lowca: return .zręczność
        case .mag: return .inteligencja
        }
    }
    
    var classHitDice: HitDice {
        switch self {
        case .barbarzynca: return .k12
        case .wojownik, .paladyn, .lowca: return .k10
        case .bard, .kleryk, .druid, .mnich, .lotr, .zaklinacz: return .k8
        case .mag, .czarownik: return .k6
        }
    }
    
    var savingThrowsProficiency: Set<BasicStatistics> {
        switch self {
        case .barbarzynca: return [.siła, .kondycja]
        case .bard: return [.zręczność, .charyzma]
        case .kleryk, .mag, .druid: return [.inteligencja, .mądrość]
        case .wojownik, .mnich: return [.siła, .zręczność]
        case .lotr: return [.zręczność, .inteligencja]
        case .paladyn, .zaklinacz: return [.mądrość, .charyzma]
        case .lowca: return [.siła, .zręczność]
        case .czarownik: return [.kondycja, .charyzma]
        }
    }
    
    var proficiencyInWeapons: Set<String> {
        switch self {
        case .wojownik, .barbarzynca, .paladyn, .lowca:
            return [KategoriaBroni.prosta.rawValue, KategoriaBroni.zolnierska.rawValue]
        case .lotr, .bard:
            return [KategoriaBroni.prosta.rawValue, "Rapier", "Krótki miecz"]
        case .kleryk, .druid, .mag, .czarownik, .zaklinacz, .mnich:
            return [KategoriaBroni.prosta.rawValue]
        }
    }
    
    var spellcastingAbility: BasicStatistics? {
        switch self {
        case .bard, .czarownik, .paladyn, .zaklinacz: return .charyzma
        case .kleryk, .druid, .lowca: return .mądrość
        case .mag: return .inteligencja
        default: return nil
        }
    }
    
    var spellcastingType: SpellcastingType? {
        switch self {
        case .kleryk, .druid, .paladyn, .mag:
            return .prepared
        case .bard, .lowca, .czarownik, .zaklinacz:
            return .known
        default:
            return nil
        }
    }
}

enum HitDice: Int, CaseIterable, Codable, Identifiable, Hashable {
    case k6 = 6
    case k8 = 8
    case k10 = 10
    case k12 = 12
    
    var id: Int { self.rawValue }
    var description: String { "k\(self.rawValue)" }
}
