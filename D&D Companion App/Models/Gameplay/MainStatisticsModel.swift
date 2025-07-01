//
//  BasicStatistics.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import Foundation


// -- Main Statistics in the Game -- //
enum BasicStatistics: String, CaseIterable, Codable, Hashable {
    case siła = "Siła"
    case zręczność = "Zręczność"
    case kondycja = "Kondycja"
    case inteligencja = "Inteligencja"
    case mądrość = "Mądrość"
    case charyzma = "Charyzma"
}


// -- Skills in the game -- //
enum Skills: String, CaseIterable, Codable, Hashable {
    case akrobatyka = "Akrobatyka"
    case atletyka = "Atletyka"
    case historia = "Historia"
    case spostrzegawczosc = "Spostrzegawczość"
    case medycyna = "Medycyna"
    case opiekaNadZwierzetami = "Opieka nad Zwierzętami"
    case oszustwo = "Oszustwo"
    case percepcja = "Percepcja"
    case perswazja = "Perswazja"
    case przyroda = "Przyroda"
    case religia = "Religia"
    case skradanieSie = "Skradanie Się"
    case sztukaPrzetrwania = "Sztuka Przetrwania"
    case śledztwo = "Śledztwo"
    case wiedzaTajemna = "Wiedza Tajemna"
    case występy = "Występy"
    case zastraszanie = "Zastraszanie"
    case zwinneDlonie = "Zwinne Dłonie"
    
    var powiązanaStatystyka: BasicStatistics {
        switch self {
        case .akrobatyka, .skradanieSie, .zwinneDlonie: return .zręczność
        case .atletyka: return .siła
        case .historia, .przyroda, .religia, .śledztwo, .wiedzaTajemna: return .inteligencja
        case .spostrzegawczosc, .medycyna, .opiekaNadZwierzetami, .percepcja, .sztukaPrzetrwania: return .mądrość
        case .oszustwo, .perswazja, .występy, .zastraszanie: return .charyzma
        }
    }
}

// -- Conditions -- //
enum Condition: String, CaseIterable, Codable, Hashable, Identifiable {
    case Oślepiony, Oczarowany, Ogłuszony, Obezwładniony, Oszołomiony, Przestraszony, Chwytany, Niewidzialny, Sparaliżowany, Skamieniały, Otruty, Leżący, Powściągnięty, Nieprzytomny
    var id: String { self.rawValue }
}
