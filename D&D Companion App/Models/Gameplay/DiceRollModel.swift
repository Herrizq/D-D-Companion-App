//
//  DiceRollModel.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import Foundation

// Dodajemy unikalny identyfikator do każdego rzutu
struct RollResult: Equatable {
    let id = UUID() // Każdy nowy rzut będzie miał unikalne ID
    let tytul: String
    let wynikOstateczny: Int
    let rzutKosci: Int
    let modyfikator: Int
    var formula: String?
    
    var bronDoAtaku: Weapon? = nil
    var czarDoAtaku: Spells? = nil
    
    // Porównujemy teraz tylko po unikalnym ID
    static func == (lhs: RollResult, rhs: RollResult) -> Bool {
        return lhs.id == rhs.id
    }
}
