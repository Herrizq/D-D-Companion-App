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

// -- Elamenty klasy wojownika -- //
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

// -- Elementy klasy kleryka -- //
enum ClericDomain: String, Codable, CaseIterable, Hashable {
    case knowledge = "Domena Wiedzy"
    case life = "Domena Życia"
    case light = "Domena Światłości"
    case nature = "Domena Natury"
    case tempest = "Domena Burzy"
    case trickery = "Domena Oszustwa"
    case war = "Domena Wojny"

    // --- PEŁNA LISTA CZARÓW DOMENOWYCH ---
    var spellIDs: [Int: [String]] {
        switch self {
        case .knowledge: return [
            1: ["rozkaz", "identyfikacja"],
            3: ["augurium", "sugestia"],
            5: ["niewykrywalność", "rozmawianie-ze-zmarłymi"],
            7: ["magiczne-oko", "splątanie"],
            9: ["legendy-i-opowieści", "wypatrzenie"]
        ]
        case .life: return [
            1: ["błogosławieństwo", "leczenie-ran"],
            3: ["mniejsze-przywrócenie", "duchowy-opiekun"],
            5: ["latarnia-nadziei", "wskrzeszenie"],
            7: ["ochrona-przed-śmiercią", "strażnik-wiary"],
            9: ["masowe-leczenie-ran", "wskrzeszenie-zmarłych"]
        ]
        case .light: return [
            1: ["płonące-dłonie", "baśniowy-ogień"],
            3: ["płonąca-kula", "płomienny-promień"],
            5: ["światło-dnia", "kula-ognia"],
            7: ["strażnik-wiary", "ściana-ognia"],
            9: ["uderzenie-płomienia", "wypatrzenie"]
        ]
        case .nature: return [
            1: ["przyjaźń-ze-zwierzętami", "rozmawianie-ze-zwierzętami"],
            3: ["kora", "kolczasty-wzrost"],
            5: ["wzrost-roślin", "ściana-wiatru"],
            7: ["dominacja-nad-zwierzęciem", "pnąca-roślina"],
            9: ["plaga-insektów", "krok-przez-drzewa"]
        ]
        case .tempest: return [
            1: ["chmura-mgły", "gromowa-fala"],
            3: ["kruszenie", "podmuch-wiatru"],
            5: ["wezwanie-błyskawicy", "burza-śnieżna"],
            7: ["kontrola-nad-wodą", "lodowa-burza"],
            9: ["niszczycielska-fala", "plaga-insektów"]
        ]
        case .trickery: return [
            1: ["urok-osobisty", "przebranie-siebie"],
            3: ["lustrzane-odbicie", "przejście-bez-śladu"],
            5: ["mignięcie", "rozproszenie-magii"],
            7: ["drzwi-przez-wymiary", "polimorfia"],
            9: ["dominacja-nad-osobą", "modyfikacja-pamięci"]
        ]
        case .war: return [
            1: ["boska-przychylność", "tarcza-wiary"],
            3: ["magiczna-broń", "duchowy-opiekun"],
            5: ["płaszcz-krzyżowca", "duchy-obronne"],
            7: ["swoboda-ruchów", "kamienna-skóra"],
            9: ["uderzenie-płomienia", "wstrzymanie-potwora"]
        ]
        }
    }

    // Zwraca dodatkowe biegłości z domeny
    var grantedProficiencies: [String] {
        switch self {
        case .life, .nature, .tempest:
            return ["Ciężkie pancerze"]
        case .war:
            return ["Ciężkie pancerze", "Broń żołnierska"]
        default:
            return []
        }
    }
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
            // Kleryk wybiera domenę na 1. poziomie
            switch self {
            case .kleryk: return 1
            case .druid, .mag, .czarownik: return 2
            case .wojownik, .lotr, .lowca, .bard, .barbarzynca, .mnich, .paladyn: return 3
            default: return 1
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

extension ClericDomain {
    var hasDivineStrike: Bool {
        switch self {
        case .life, .tempest, .trickery, .war: return true
        default: return false
        }
    }
    var divineStrikeDamageType: String {
            switch self {
            case .life: return "Promieniste"
            case .tempest: return "Grzmotowe"
            case .trickery: return "Trucizna"
            case .war: return "takie jak broń"
            default: return ""
            }
        }
    
    var level8FeatureName: String {
            return self.hasDivineStrike ? "Boskie Uderzenie" : "Potężne Rzucanie Czarów"
        }
        
    var level8FeatureDescription: String {
        if self.hasDivineStrike {
            return "Raz na turę, gdy trafisz bronią, możesz zadać dodatkowe 1k8 (2k8 od 14 poz.) obrażeń typu: \(self.divineStrikeDamageType)."
        } else {
            return "Dodajesz swój modyfikator z Mądrości do obrażeń zadawanych przez sztuczki kleryka."
        }
    }
    
    
    func channelDivinityAction(player: Player) -> CombatAction? {
        switch self {
        case .knowledge:
            return CombatAction(id: "wiedza-wiekow", name: "Wiedza Wieków", description: "Jako akcję, możesz użyć Kanału Mocy, by zyskać biegłość w dowolnej umiejętności lub narzędziu na 10 minut.", source: "Kanał Mocy", range: "Własny", hitBonus: "-", damage: "-", damageType: "Efekt", rollable: .none)
        case .life:
            let healingAmount = player.poziom * 5
            return CombatAction(id: "zachowanie-zycia", name: "Zachowanie Życia", description: "Jako akcję, przywracasz \(healingAmount) PŻ, rozdzielając je między istoty w promieniu 30 stóp.", source: "Kanał Mocy", range: "30 stóp", hitBonus: "-", damage: "\(healingAmount) PŻ", damageType: "Leczenie", rollable: .none)
        case .light:
            let damage = "\(2 + player.poziom)k6"
            return CombatAction(id: "promienistosc-switu", name: "Promienistość Świtu", description: "Jako akcję, rozpraszasz magiczną ciemność w promieniu 30 stóp i zadajesz \(damage) obrażeń promienistych każdej wrogiej istocie.", source: "Kanał Mocy", range: "30 stóp", hitBonus: "-", damage: damage, damageType: "Promieniste", rollable: .none)
        case .nature:
            return CombatAction(id: "urok-dla-zwierzat-i-roslin", name: "Urok dla Zwierząt i Roślin", description: "Jako akcję, możesz użyć Kanału Mocy, by oczarować bestie lub rośliny w promieniu 30 stóp.", source: "Kanał Mocy", range: "30 stóp", hitBonus: "-", damage: "-", damageType: "Efekt", rollable: .none)
        case .tempest:
             let damage = "\(2 * player.poziom)k6"
            return CombatAction(id: "niszczycielski-gniew", name: "Niszczycielski Gniew", description: "Gdy zadajesz obrażenia od błyskawic lub grzmotu, możesz użyć Kanału Mocy, by zadać maksymalne obrażenia zamiast rzucać kośćmi.", source: "Kanał Mocy", range: "Własny", hitBonus: "-", damage: "Max", damageType: "Błyskawice/Grzmot", rollable: .none)
        case .trickery:
            return CombatAction(id: "wezwanie-podobienstwa", name: "Wezwanie Podobieństwa", description: "Jako akcję, tworzysz iluzorycznego sobowtóra, który może rozpraszać wrogów i rzucać z niego czary.", source: "Kanał Mocy", range: "30 stóp", hitBonus: "-", damage: "-", damageType: "Efekt", rollable: .none)
        case .war:
            return CombatAction(id: "uderzenie-wojenne", name: "Uderzenie Wojenne", description: "Możesz użyć Kanału Mocy, by zyskać premię +10 do następnego rzutu na atak.", source: "Kanał Mocy", range: "Własny", hitBonus: "+10", damage: "-", damageType: "Premia", rollable: .none)
        }
    }
}
