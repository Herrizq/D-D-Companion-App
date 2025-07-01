//
//  Race.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import Foundation

// -- Races in the game -- //
enum Race: String, CaseIterable, Codable, Identifiable, Hashable {
    case czlowiek = "Człowiek"
    case elf = "Elf"
    case krasnolud = "Krasnolud"
    case niziolek = "Niziołek"
    case drakonid = "Drakonid"
    case gnom = "Gnom"
    case polelf = "Półelf"
    case polork = "Półork"
    case diabelstwo = "Diabelstwo"
    
    var id: String { self.rawValue }
    
    var skillsModifier: [BasicStatistics: Int] {
        switch self {
        case .czlowiek: return [.siła: 1, .zręczność: 1, .kondycja: 1, .inteligencja: 1, .mądrość: 1, .charyzma: 1]
        case .elf: return [.zręczność: 2]
        case .krasnolud: return [.kondycja: 2]
        case .niziolek: return [.zręczność: 2]
        case .drakonid: return [.siła: 2, .charyzma: 1]
        case .gnom: return [.inteligencja: 2]
        case .polelf: return [.charyzma: 2] // + dwie inne cechy o 1
        case .polork: return [.siła: 2, .kondycja: 1]
        case .diabelstwo: return [.inteligencja: 1, .charyzma: 2]
        }
    }
    
    var movingSpeed: Int {
        switch self {
        case .krasnolud, .niziolek, .gnom: return 25
        default: return 30
        }
    }
    
    var proficiencyInWeapons: Set<String> {
        switch self {
        case .elf, .polelf:
            return ["Długi miecz", "Krótki miecz", "Krótki łuk", "Długi łuk"]
        case .krasnolud:
            return ["Topór bojowy", "Toporek", "Młot lekki", "Młot bojowy"]
        default:
            return []
        }
    }
}
