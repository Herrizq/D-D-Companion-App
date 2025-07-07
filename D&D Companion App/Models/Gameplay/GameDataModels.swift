import Foundation
import SwiftData

// --- STRUKTURY DO WCZYTYWANIA Z PLIKÓW JSON ---
// Te struktury idealnie odzwierciedlają Twoje pliki .json

struct WeaponJSON: Codable {
    // Nazwy pól odpowiadają kluczom w weapons.json (snake_case)
    let id: String
    let nazwa: String
    let kategoria: KategoriaBroni
    let koszt: String
    let ilosc_kosci_obrazen: Int
    let kosc_obrazen: Int
    let typ_obrazen: String
    let waga: Double
    let wlasciwosci: [String]
}

struct SpellsJSON: Codable {
    // Pola w strukturze
    let id: String
    let nazwa: String
    let opis: String
    let wyzszePoziomy: String?
    let poziom: Int
    let szkolaMagii: String
    let czasRzucania: String
    let zasieg: String
    let komponenty: [String]
    let czasTrwania: String
    let czyRytual: Bool
    let dostepnyDlaKlas: [String]
    let wymagaAtaku: Bool?
    let iloscKosciObrazen: Int?
    let koscObrazen: Int?
    let typObrazen: String?

    // Mapowanie kluczy z JSON na pola struktury
    enum CodingKeys: String, CodingKey {
        case id, nazwa, opis, poziom, zasieg, komponenty
        
        // Klucze, które mają inne nazwy w JSON
        case wyzszePoziomy = "wyzsze_poziomy"
        case szkolaMagii = "szkolaMagii" // Poprawione na camelCase
        case czasRzucania = "czasRzucania" // Poprawione na camelCase
        case czasTrwania = "czasTrwania" // Poprawione na camelCase
        case czyRytual = "czyRytual" // Poprawione na camelCase
        case dostepnyDlaKlas = "dostepnyDlaKlas" // Poprawione na camelCase
        case wymagaAtaku = "wymaga_ataku"
        case iloscKosciObrazen = "ilosc_kosci_obrazen"
        case koscObrazen = "kosc_obrazen"
        case typObrazen = "typ_obrazen"
    }
}

struct ManeuverJSON: Codable {
    let id: String
    let nazwa: String
    let opis: String
}

struct ArmorJSON: Codable {
    let id: String
    let nazwa: String
    let koszt: String
    let klasa_pancerza_bazowa: Int
    let modyfikator_ze_zrecznosci: String // "pełny", "max 2" lub "brak"
    let typ: String // "Lekki", "Średni", "Ciężki", "Tarcza"
    let wymagana_sila: Int?
    let kara_do_skradania: Bool
    let waga: Double
}

struct FeatJSON: Codable {
    let id: String
    let nazwa: String
    let opis: String
}


// --- MODELE SWIFTDATA ---
// Te modele są teraz czystsze i służą tylko do pracy z bazą danych

@Model
final class Weapon {
    var id: String = ""
    var nazwa: String = ""
    var kategoria: KategoriaBroni = KategoriaBroni.prosta
    var koszt: String = ""
    var iloscKosciObrazen: Int = 1
    var koscObrazen: Int = 4
    var typObrazen: String = ""
    var waga: Double = 0.0
    var wlasciwosci: [String] = []
    var isRanged: Bool {
            // Zakładamy, że broń jest dystansowa, jeśli ma właściwość "Amunicyjna"
            return self.wlasciwosci.contains(where: { $0.contains("Amunicyjna") })
    }

    var owner: Player?
    
    var bondedPlayer: Player?
    
    init(from json: WeaponJSON) {
        self.id = json.id
        self.nazwa = json.nazwa
        self.kategoria = json.kategoria
        self.koszt = json.koszt
        self.iloscKosciObrazen = json.ilosc_kosci_obrazen
        self.koscObrazen = json.kosc_obrazen
        self.typObrazen = json.typ_obrazen
        self.waga = json.waga
        self.wlasciwosci = json.wlasciwosci
    }
    
    init(id: String, nazwa: String, kategoria: KategoriaBroni, koszt: String, iloscKosciObrazen: Int, koscObrazen: Int, typObrazen: String, waga: Double, wlasciwosci: [String]) {
            self.id = id
            self.nazwa = nazwa
            self.kategoria = kategoria
            self.koszt = koszt
            self.iloscKosciObrazen = iloscKosciObrazen
            self.koscObrazen = koscObrazen
            self.typObrazen = typObrazen
            self.waga = waga
            self.wlasciwosci = wlasciwosci
        }
}

@Model
final class Spells {
    var id: String = ""
    var nazwa: String = ""
    var opis: String = ""
    var wyzszePoziomy: String?
    var poziom: Int = 0
    var szkolaMagii: String = ""
    var czasRzucania: String = ""
    var zasieg: String = ""
    var komponenty: [String] = []
    var czasTrwania: String = ""
    var czyRytual: Bool = false
    var dostepnyDlaKlas: [String] = []
    var wymagaAtaku: Bool?
    var iloscKosciObrazen: Int?
    var koscObrazen: Int?
    var typObrazen: String?
    
    var knownByEldritchKnights: [Player]? = []
    
    var learnedByNatureClerics: [Player]? = []

    init(from json: SpellsJSON) {
        self.id = json.id
        self.nazwa = json.nazwa
        self.opis = json.opis
        self.wyzszePoziomy = json.wyzszePoziomy
        self.poziom = json.poziom
        self.szkolaMagii = json.szkolaMagii
        self.czasRzucania = json.czasRzucania
        self.zasieg = json.zasieg
        self.komponenty = json.komponenty
        self.czasTrwania = json.czasTrwania
        self.czyRytual = json.czyRytual
        self.dostepnyDlaKlas = json.dostepnyDlaKlas
        self.wymagaAtaku = json.wymagaAtaku
        self.iloscKosciObrazen = json.iloscKosciObrazen
        self.koscObrazen = json.koscObrazen
        self.typObrazen = json.typObrazen
    }
    
    init() {}
}

@Model
final class Armor {
    var id: String = ""
    var nazwa: String = ""
    var koszt: String = ""
    var klasaPancerzaBazowa: Int = 0
    var modyfikatorZeZrecznosci: String = "pełny"
    var typ: String = "Lekki"
    var wymaganaSila: Int?
    var karaDoSkradania: Bool = false
    var waga: Double = 0.0

    var inventoryOwner: Player?

    var equippedByPlayerAsArmor: Player?
    
    var equippedByPlayerAsShield: Player?

        init(from json: ArmorJSON) {
            self.id = json.id
            self.nazwa = json.nazwa
            self.koszt = json.koszt
            self.klasaPancerzaBazowa = json.klasa_pancerza_bazowa
            self.modyfikatorZeZrecznosci = json.modyfikator_ze_zrecznosci
            self.typ = json.typ
            self.wymaganaSila = json.wymagana_sila
            self.karaDoSkradania = json.kara_do_skradania
            self.waga = json.waga
        }
        
        // Dodajemy pusty inicjalizator dla SwiftData
        init() {}
}

@Model
final class Maneuver {
    // Usunięto @Attribute(.unique)
    var id: String = ""
    var nazwa: String = ""
    var opis: String = ""
    
    var knowingPlayers: [Player]? = []
    
    init(from json: ManeuverJSON) {
        self.id = json.id
        self.nazwa = json.nazwa
        self.opis = json.opis
    }
    
    init() {}
}


@Model
final class Feat: Codable {
    var id: String = ""
    var nazwa: String = ""
    var opis: String = ""

    // Add CodingKeys to handle JSON decoding
    enum CodingKeys: String, CodingKey {
        case id, nazwa, opis
    }
    
    // Add the required initializers for Codable conformance
    init(from json: FeatJSON) {
        self.id = json.id
        self.nazwa = json.nazwa
        self.opis = json.opis
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.nazwa = try container.decode(String.self, forKey: .nazwa)
        self.opis = try container.decode(String.self, forKey: .opis)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(nazwa, forKey: .nazwa)
        try container.encode(opis, forKey: .opis)
    }
}
enum KategoriaBroni: String, Codable, Hashable, CaseIterable {
    case prosta = "Prosta"
    case zolnierska = "Żołnierska"
}
