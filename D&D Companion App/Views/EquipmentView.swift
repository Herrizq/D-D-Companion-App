import SwiftUI
import SwiftData

struct EquipmentView: View {
    @Bindable var player: Player
    @Binding var ostatniRzut: RollResult?

    enum SheetItem: Identifiable {
        case weapon(Weapon), armor(Armor)
        var id: String {
            switch self {
            case .weapon(let w): return "w_\(w.id)"
            case .armor(let a): return "a_\(a.id)"
            }
        }
    }

    @State private var showingAddWeaponSheet = false
    @State private var showingCreateWeaponSheet = false
    @State private var showingAddArmorSheet = false
    @State private var itemToShow: SheetItem?

    var body: some View {
        List {
            // Używamy nowego, wydzielonego widoku dla sekcji pancerzy
            ArmorSectionView(player: player) { armor in
                itemToShow = .armor(armor)
            }
            
            // Używamy nowego, wydzielonego widoku dla sekcji broni
            WeaponSectionView(player: player, ostatniRzut: $ostatniRzut) { weapon in
                itemToShow = .weapon(weapon)
            }
        }
        .navigationTitle("Ekwipunek")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Dodaj Broń z Listy", systemImage: "list.bullet") { showingAddWeaponSheet = true }
                    Button("Stwórz Własną Broń", systemImage: "hammer.fill") { showingCreateWeaponSheet = true }
                    Button("Dodaj Pancerz z Listy", systemImage: "shield.checkered") { showingAddArmorSheet = true }
                } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showingAddWeaponSheet) { AddWeaponView(player: player) }
        .sheet(isPresented: $showingCreateWeaponSheet) { CreateWeaponView() }
        .sheet(isPresented: $showingAddArmorSheet) { AddArmorView(player: player) }
        .sheet(item: $itemToShow) { item in
            switch item {
            case .weapon(let weapon):
                ActionDetailView(action: weapon.asCombatAction(for: player))
            case .armor(let armor):
                ActionDetailView(action: armor.asCombatAction())
            }
        }
    }
}


// MARK: - Komponenty Widoku

// --- NOWY WIDOK DLA SEKCJI PANCERZY ---
struct ArmorSectionView: View {
    @Bindable var player: Player
    var onShowDetails: (Armor) -> Void

    var body: some View {
        Section(header: Text("Pancerz i Tarcza")) {
            if player.armorInventory?.isEmpty ?? true {
                Text("Brak pancerzy w ekwipunku.").foregroundStyle(.secondary)
            }
            ForEach(player.armorInventory ?? []) { item in
                HStack {
                    Button(action: { onShowDetails(item) }) {
                        HStack {
                            Text(item.nazwa)
                            Spacer()
                            Text(item.typ).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .foregroundColor(.primary)

                    Spacer()
                    
                    let isEquipped = (player.equippedArmor?.id == item.id) || (player.equippedShield?.id == item.id)
                    Button(isEquipped ? "Zdejmij" : "Załóż") {
                        toggleEquipment(item)
                    }
                    .buttonStyle(.bordered).tint(isEquipped ? .gray : .accentColor)
                }
            }
            .onDelete(perform: usunPancerz)
        }
    }

    private func toggleEquipment(_ item: Armor) {
        if item.typ == "Tarcza" {
            player.equippedShield = (player.equippedShield?.id == item.id) ? nil : item
        } else {
            player.equippedArmor = (player.equippedArmor?.id == item.id) ? nil : item
        }
    }

    private func usunPancerz(at offsets: IndexSet) {
        player.armorInventory?.remove(atOffsets: offsets)
    }
}


// --- NOWY WIDOK DLA SEKCJI BRONI ---
struct WeaponSectionView: View {
    @Bindable var player: Player
    @Binding var ostatniRzut: RollResult?
    var onShowDetails: (Weapon) -> Void

    var body: some View {
        Section(header: WeaponSectionHeader()) {
            if player.carriedWeapons?.isEmpty ?? true {
                Text("Brak broni w ekwipunku.").foregroundStyle(.secondary)
            }
            ForEach(player.carriedWeapons ?? []) { weapon in
                let action = weapon.asCombatAction(for: player)
                HStack(spacing: 16) {
                    Button(action: { onShowDetails(weapon) }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(action.name).font(.headline).foregroundColor(.primary)
                            Text(action.source.uppercased()).font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Text(action.hitBonus).frame(width: 50, alignment: .center)
                    Text(action.damage).frame(width: 80, alignment: .leading)
                    Text(action.damageType).frame(width: 80, alignment: .leading) // Nowa kolumna
                    Button(action: { performAttackRoll(with: weapon) }) {
                        Image(systemName: "dice.fill").font(.title2).foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 8)
            }
            .onDelete(perform: usunBron)
        }
    }
    
    // Nagłówek dla sekcji broni
    struct WeaponSectionHeader: View {
        var body: some View {
            HStack(spacing: 16) {
                Text("Nazwa").frame(maxWidth: .infinity, alignment: .leading)
                Text("Traf.").frame(width: 50, alignment: .center)
                Text("Obr.").frame(width: 80, alignment: .leading)
                Text("Typ").frame(width: 80, alignment: .leading) // Nowy nagłówek
                Image(systemName: "dice").frame(width: 24, alignment: .center).opacity(0)
            }
            .font(.caption.bold())
            .foregroundStyle(.secondary)
        }
    }

    private func usunBron(at offsets: IndexSet) {
        player.carriedWeapons?.remove(atOffsets: offsets)
    }

    private func performAttackRoll(with weapon: Weapon) {
        let bonuses = player.calculateToHitBonuses(dlaBroni: weapon)
        let roll = Int.random(in: 1...20)
        ostatniRzut = RollResult(tytul: "Atak: \(weapon.nazwa)", wynikOstateczny: roll + bonuses.trafienie, rzutKosci: roll, modyfikator: bonuses.trafienie, bronDoAtaku: weapon)
    }
}


// MARK: - Rozszerzenia Modeli

// Dodajemy małe funkcje pomocnicze do modeli, aby łatwo tworzyć z nich akcje
extension Weapon {
    func asCombatAction(for player: Player) -> CombatAction {
        let bonuses = player.calculateToHitBonuses(dlaBroni: self)
        return CombatAction(
            name: self.nazwa,
            description: "Szczegółowy opis broni.",
            source: self.kategoria.rawValue,
            range: self.isRanged ? "Dystansowa" : "5 ft.",
            hitBonus: "+\(bonuses.trafienie)",
            damage: bonuses.obrazenia,
            damageType: self.typObrazen,
            // --- POPRAWKA ---
            // Dodajemy informację, że ta akcja wiąże się z rzutem dla broni.
            rollable: .weapon(self)
        )
    }
}

extension Armor {
    func asCombatAction() -> CombatAction {
        let acDescription = "KP: \(self.klasaPancerzaBazowa)" + (self.typ != "Tarcza" ? " + mod. ze Zręczności (\(self.modyfikatorZeZrecznosci))" : "")
        return CombatAction(
            name: self.nazwa,
            description: acDescription,
            source: self.typ,
            range: "-",
            hitBonus: "-",
            damage: "-",
            damageType: "-",
            // --- POPRAWKA ---
            // Dodajemy informację, że ta akcja nie wiąże się z żadnym rzutem.
            rollable: .none
        )
    }
}
