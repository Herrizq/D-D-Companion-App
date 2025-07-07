import SwiftUI
import SwiftData

struct EquipmentView: View {
    @Bindable var player: Player
    @Binding var ostatniRzut: RollResult?

    // Enum do zarządzania tym, który widok szczegółów pokazać
    enum SheetItem: Identifiable {
        case weapon(Weapon)
        case armor(Armor)
        
        var id: String {
            switch self {
            case .weapon(let w): return "w_\(w.id)"
            case .armor(let a): return "a_\(a.id)"
            }
        }
    }

    @State private var itemToShow: SheetItem?
    
    // Stany do kontrolowania widoków dodawania przedmiotów
    @State private var showingAddWeaponSheet = false
    @State private var showingCreateWeaponSheet = false
    @State private var showingAddArmorSheet = false
    
    var body: some View {
        List {
            // Używamy wydzielonego widoku dla sekcji pancerzy
            ArmorSectionView(player: player) { armor in
                itemToShow = .armor(armor)
            }
            
            // Używamy wydzielonego widoku dla sekcji broni
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
                // Używamy nowego widoku dla broni
                WeaponDetailView(weapon: weapon)
            case .armor(let armor):
                // Używamy nowego widoku dla pancerza
                ArmorDetailView(armor: armor)
            }
        }
    }
}


// MARK: - Komponenty Widoku (Wydzielone Sekcje)

private struct ArmorSectionView: View {
    @Bindable var player: Player
    var onShowDetails: (Armor) -> Void

    var body: some View {
        Section(header: Text("Pancerz i Tarcza")) {
            if player.armorInventory?.isEmpty ?? true {
                Text("Brak pancerzy w ekwipunku.").foregroundStyle(.secondary)
            }
            // Sortujemy listę, aby zapewnić stabilną kolejność
            ForEach((player.armorInventory ?? []).sorted(by: { $0.nazwa < $1.nazwa })) { item in
                HStack {
                    // Przycisk do pokazywania szczegółów, obejmuje nazwę i typ
                    Button(action: { onShowDetails(item) }) {
                        VStack(alignment: .leading) {
                            Text(item.nazwa).font(.headline)
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
                .padding(.vertical, 4)
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

private struct WeaponSectionView: View {
    @Bindable var player: Player
    @Binding var ostatniRzut: RollResult?
    var onShowDetails: (Weapon) -> Void

    var body: some View {
        Section(header: WeaponSectionHeader()) {
            if player.carriedWeapons?.isEmpty ?? true {
                Text("Brak broni w ekwipunku.").foregroundStyle(.secondary)
            }
            // Sortujemy listę, aby zapewnić stabilną kolejność
            ForEach((player.carriedWeapons ?? []).sorted(by: { $0.nazwa < $1.nazwa })) { weapon in
                let action = weapon.asCombatAction(for: player)
                // Używamy ActionRowView dla spójnego wyglądu z zakładką Walka
                ActionRowView(
                    action: action,
                    onRoll: { performAttackRoll(with: weapon) },
                    onShowDetails: { onShowDetails(weapon) }
                )
            }
            .onDelete(perform: usunBron)
        }
    }
    
    // Prywatny komponent dla nagłówka, dopasowany do ActionRowView
    private struct WeaponSectionHeader: View {
        var body: some View {
            HStack(spacing: 16) {
                Text("Nazwa").frame(maxWidth: .infinity, alignment: .leading)
                Text("Zasięg").frame(width: 80, alignment: .center)
                Text("Traf.").frame(width: 50, alignment: .center)
                Text("Obr.").frame(width: 100, alignment: .leading)
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
