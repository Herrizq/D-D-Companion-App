//
//  GameDataModels.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import Foundation

// -- Weapons -- //
struct Weapon: Codable, Identifiable, Hashable {
    let id: String
    let nazwa: String
    let kategoria: KategoriaBroni
    let koszt: String
    let iloscKosciObrazen: Int
    let koscObrazen: Int
    let typObrazen: String
    let waga: Double
    let wlasciwosci: [String]
}


// -- Armor -- //
struct Armor: Codable, Identifiable, Hashable {
    let id: String
    let nazwa: String
    let koszt: String
    let klasaPancerza: String
    let typ: String
    let wymaganaSila: Int?
    let karaDoSkradania: Bool
    let waga: Double
}


// -- Item -- //
struct Item: Codable, Identifiable, Hashable {
    let id: String
    let nazwa: String
    let koszt: String
    let waga: Double
    let opis: String?
}


// -- Spells -- //
struct Spells: Codable, Identifiable, Hashable {
    let id: String
    let nazwa: String
    let opis: String
    let wyzszePoziomy: String? // Opis działania na wyższych poziomach
    let poziom: Int // 0 dla sztuczek (cantrips)
    let szkolaMagii: String
    let czasRzucania: String
    let zasieg: String
    let komponenty: [String] // ["W", "S", "M"]
    let czasTrwania: String
    let czyRytual: Bool
    let dostepnyDlaKlas: [String]
}
