//
//  PlayerViewModel.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import Foundation
import SwiftUI
import Combine

class PlayerViewModel: ObservableObject {
    @Published var postac: Player = Player()
    @Published var ostatniRzut: RollResult? = nil
    
    
    // -- Point Buy system -- //
    private func pointsPrice(value: Int) -> Int {
        switch value {
        case 8: return 0
        case 9: return 1
        case 10: return 2
        case 11: return 3
        case 12: return 4
        case 13: return 5
        case 14: return 7
        case 15: return 9
        default: return 999
        }
    }
    
    var totalPriceOfStatisticPoints: Int {
        postac.baseStatistics.values.reduce(0) { $0 + pointsPrice(value: $1) }
    }
    
    var pointsToSpend: Int {
        return 27 - totalPriceOfStatisticPoints
    }
    
    
    // -- Gameplay Mechanism -- //
    func ApplieClassBonuses() {
        let wybranaKlasa = postac.klasa
        postac.savingThrowsProficiency = wybranaKlasa.savingThrowsProficiency
        postac.koscWytrzymalosci = wybranaKlasa.classHitDice
    }
    
    func ApplieRaceBonuses() {
        postac.prędkość = postac.rasa.movingSpeed
    }
    
    // ZMIANA NAZWY dla przejrzystości
        func wykonajRzutNaTrafienie(bronia bron: Weapon) {
            let bonusy = postac.CalculateToHitBonuses(dlaBroni: bron)
            let rzutNaTrafienie = Int.random(in: 1...20)
            let wynikRzutu = RollResult(
                tytul: "Rzut na Trafienie: \(bron.nazwa)",
                wynikOstateczny: rzutNaTrafienie + bonusy.trafienie,
                rzutKosci: rzutNaTrafienie,
                modyfikator: bonusy.trafienie,
                // Przekazujemy broń, aby UI wiedziało, że ma pokazać przycisk obrażeń
                bronDoAtaku: bron
            )
            pokazPowiadomienieORzucie(wynikRzutu)
        }

        // NOWA FUNKCJA do rzutu na obrażenia
        func wykonajRzutNaObrazenia(dlaBroni bron: Weapon) {
            // 1. Oblicz modyfikator do obrażeń
            var uzywanaStatystyka: BasicStatistics = .siła
            if bron.wlasciwosci.contains("Finezyjna") {
                if postac.StatisticsModifier(for: .zręczność) > postac.StatisticsModifier(for: .siła) {
                    uzywanaStatystyka = .zręczność
                }
            }
            let modyfikatorObrazen = postac.StatisticsModifier(for: uzywanaStatystyka)
            
            // 2. Rzuć kośćmi
            var sumaRzutu = 0
            for _ in 0..<bron.iloscKosciObrazen {
                sumaRzutu += Int.random(in: 1...bron.koscObrazen)
            }
            
            // 3. Stwórz nowe powiadomienie
            let wynikObrazen = RollResult(
                tytul: "Obrażenia: \(bron.nazwa)",
                wynikOstateczny: sumaRzutu + modyfikatorObrazen,
                rzutKosci: sumaRzutu,
                modyfikator: modyfikatorObrazen,
                formula: "\(bron.iloscKosciObrazen)k\(bron.koscObrazen) + \(modyfikatorObrazen)"
            )
            pokazPowiadomienieORzucie(wynikObrazen)
        }

    func wykonajRzutOgolny(kosciDoRzucenia: [Int: Int]) {
        var sumaCalkowita = 0
        var formulaRzutu: [String] = []
        
        // Sortujemy klucze, aby formuła była zawsze w tej samej kolejności (np. k20, potem k12 itd.)
        for typKosci in kosciDoRzucenia.keys.sorted(by: >) {
            if let liczbaKosci = kosciDoRzucenia[typKosci], liczbaKosci > 0 {
                var sumaDlaTypu = 0
                for _ in 0..<liczbaKosci {
                    sumaDlaTypu += Int.random(in: 1...typKosci)
                }
                sumaCalkowita += sumaDlaTypu
                formulaRzutu.append("\(liczbaKosci)k\(typKosci)")
            }
        }
        
        guard !formulaRzutu.isEmpty else { return }
        
        let wynikRzutu = RollResult(
            tytul: "Rzut Ogólny",
            wynikOstateczny: sumaCalkowita,
            rzutKosci: sumaCalkowita, // Dla rzutu ogólnego, rzut i wynik to to samo
            modyfikator: 0,
            formula: formulaRzutu.joined(separator: " + ")
        )
        pokazPowiadomienieORzucie(wynikRzutu)
    }

    
    func AddWeapon(_ bron: Weapon) {
        postac.carriedWeapons.append(bron)
    }
    
    func ChangeHP(o ilosc: Int) {
        let nowaWartosc = postac.currentHitPoints + ilosc
        postac.currentHitPoints = max(0, min(postac.hitPointsMaximum, nowaWartosc))
    }
    
    func InitiativeRoll() {
        let modyfikator = postac.StatisticsModifier(for: .zręczność)
        let rzutKosci = Int.random(in: 1...20)
        
        let wynikRzutu = RollResult(
            tytul: "Rzut na Inicjatywę",
            wynikOstateczny: rzutKosci + modyfikator,
            rzutKosci: rzutKosci,
            modyfikator: modyfikator
        )
        pokazPowiadomienieORzucie(wynikRzutu)
    }
    
    func SkillRoll(umiejetnosc: Skills, zPrzewaga: Bool = false) {
        if zPrzewaga && postac.inspiracja { postac.inspiracja = false }
        
        let maUtrudnienie = postac.aktywneStany.contains(.Otruty) || postac.aktywneStany.contains(.Przestraszony)
        
        let modyfikator = postac.SkillsModifier(for: umiejetnosc)
        var rzutKosci = Int.random(in: 1...20)
        var tytulRzutu = "Test: \(umiejetnosc.rawValue)"
        
        if zPrzewaga && !maUtrudnienie {
            rzutKosci = max(rzutKosci, Int.random(in: 1...20))
            tytulRzutu = "Test (Przewaga): \(umiejetnosc.rawValue)"
        } else if maUtrudnienie && !zPrzewaga {
            rzutKosci = min(rzutKosci, Int.random(in: 1...20))
            tytulRzutu = "Test (Utrudnienie): \(umiejetnosc.rawValue)"
        }
        
        let wynikRzutu = RollResult(
            tytul: tytulRzutu,
            wynikOstateczny: rzutKosci + modyfikator,
            rzutKosci: rzutKosci,
            modyfikator: modyfikator
        )
        pokazPowiadomienieORzucie(wynikRzutu)
    }
    
    func wykonajRzutObronny(statystyka: BasicStatistics, zPrzewaga: Bool = false) {
        let maUtrudnienie = postac.aktywneStany.contains(.Otruty) || postac.aktywneStany.contains(.Przestraszony)
        
        if zPrzewaga && postac.inspiracja {
            postac.inspiracja = false
        }
        
        let modyfikator = postac.SavingThromModifier(for: statystyka)
        var rzutKosci = Int.random(in: 1...20)
        var tytulRzutu = "Rzut obronny: \(statystyka.rawValue)"
        
        if zPrzewaga && !maUtrudnienie {
            rzutKosci = max(rzutKosci, Int.random(in: 1...20))
            tytulRzutu = "Rzut obronny: (Przewaga): \(statystyka.rawValue)"
        } else if maUtrudnienie && !zPrzewaga {
            rzutKosci = min(rzutKosci, Int.random(in: 1...20))
            tytulRzutu = "Rzut obronny: (Utrudnienie): \(statystyka.rawValue)"
        }
        
        let wynikRzutu = RollResult(
            tytul: tytulRzutu,
            wynikOstateczny: rzutKosci + modyfikator,
            rzutKosci: rzutKosci,
            modyfikator: modyfikator
        )
        pokazPowiadomienieORzucie(wynikRzutu)
    }
    
    func ShortRest(ilosc: Int = 1) {
        let dostepneKosci = postac.poziom - postac.zuzyteKosciWytrzymalosci
        guard ilosc <= dostepneKosci else { return }
        
        var odzyskanePW = 0
        for _ in 1...ilosc {
            let rzut = Int.random(in: 1...postac.koscWytrzymalosci.rawValue)
            odzyskanePW += rzut + postac.StatisticsModifier(for: .kondycja)
        }
        
        postac.currentHitPoints = min(postac.hitPointsMaximum, postac.currentHitPoints + odzyskanePW)
        postac.zuzyteKosciWytrzymalosci += ilosc
    }
    
    func LongRest() {
        postac.currentHitPoints = postac.hitPointsMaximum
        let odzyskaneKosic = max(1, postac.poziom / 2)
        postac.zuzyteKosciWytrzymalosci = max(0, postac.zuzyteKosciWytrzymalosci - odzyskaneKosic)
        postac.successesInSavingThrows = 0
        postac.failuresInSavingThrows = 0
    }
    
    private func pokazPowiadomienieORzucie(_ wynik: RollResult) {
        withAnimation(.spring()) {
            self.ostatniRzut = wynik
        }
        
        Task {
            try? await Task.sleep(for: .seconds(4))
            if ostatniRzut == wynik {
                withAnimation(.easeOut) {
                    self.ostatniRzut = nil
                }
            }
        }
    }
}

