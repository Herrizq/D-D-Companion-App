//
//  DataManager.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//
import Foundation
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published private(set) var bronie: [Weapon] = []
    @Published private(set) var czary: [Spells] = []
    
    private init() {
        // ZMIANA: Wywołujemy teraz funkcję z dwoma argumentami
        bronie = wczytaj("weapons", rozszerzenie: "json")
        czary = wczytaj("spells", rozszerzenie: "json")
    }
    
    // ZMIANA: Funkcja przyjmuje teraz osobno nazwę i rozszerzenie
    private func wczytaj<T: Decodable>(_ nazwaZasobu: String, rozszerzenie: String) -> T {
        // ZMIANA: Używamy teraz obu parametrów
        guard let url = Bundle.main.url(forResource: nazwaZasobu, withExtension: rozszerzenie) else {
            // Zmieniamy też komunikat błędu, żeby był bardziej czytelny
            fatalError("Nie znaleziono pliku o nazwie \(nazwaZasobu).\(rozszerzenie) w projekcie.")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Błąd podczas wczytywania i dekodowania pliku \(nazwaZasobu).\(rozszerzenie): \(error)")
        }
    }
}

