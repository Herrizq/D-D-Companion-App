//
//  DiceRollModel.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import Foundation

// -- Dice Roll Mechanism -- //
struct RollResult: Equatable {
    let tytul: String
    let wynikOstateczny: Int
    let rzutKosci: Int
    let modyfikator: Int
    var formula: String? // Zmieniamy na opcjonalne
    
    // NOWE, OPCJONALNE WŁAŚCIWOŚCI
    // Jeśli nie są nil, wiemy, że to był rzut na trafienie
    var bronDoAtaku: Weapon? = nil
    
    // Usprawniamy porównywanie
    static func == (lhs: RollResult, rhs: RollResult) -> Bool {
        return lhs.tytul == rhs.tytul && lhs.wynikOstateczny == rhs.wynikOstateczny && lhs.formula == rhs.formula
    }
}
