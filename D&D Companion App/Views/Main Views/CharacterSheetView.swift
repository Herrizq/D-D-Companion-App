import SwiftUI

// MARK: - Typy Pomocnicze

enum ActiveModalElement: Identifiable {
    case edycjaStatystyk
    case zarzadzanieStanami

    var id: Self { self }
}

// MARK: - Główny Widok Karty Postaci

struct CharacterSheetView: View {
    @Bindable var player: Player
    @Binding var ostatniRzut: RollResult?

    @State private var aktywnyElement: ActiveModalElement?
    @State private var showingAsiSheetForLevel: Int?
    
    private var shouldShowSubclassPicker: Bool {
        switch player.klasa {
        case .wojownik:
            return player.poziom >= player.klasa.subclassSelectionLevel && player.fighterArchetype == nil
        case .kleryk:
            return player.poziom >= player.klasa.subclassSelectionLevel && player.clericDomain == nil
        default:
            return false
        }
    }
    
    var body: some View {
        Form {
            CharacterInfoSection(player: player)
            
            if shouldShowSubclassPicker {
                SubclassPickerSection(player: player)
            }
            
            // --- INTEGRACJA WIDOKÓW ZDOLNOŚCI ---
            if player.klasa == .wojownik {
                FighterAbilitiesView(player: player, ostatniRzut: $ostatniRzut)
            }
            
            if player.klasa == .kleryk {
                ClericAbilitiesView(player: player)
            }
            
            ASISection(player: player) { level in
                showingAsiSheetForLevel = level
            }
            
            BattleStatsSection(player: player) {
                performInitiativeRoll()
            }
            
            MainStatsSection(player: player) {
                aktywnyElement = .edycjaStatystyk
            }
            
            HPAndResourcesSection(player: player, ostatniRzut: $ostatniRzut, aktywnyElement: $aktywnyElement)
            
            if player.canCastSpells {
                MagicSection(player: player, ostatniRzut: $ostatniRzut)
            }
            
            SkillsSection(player: player, ostatniRzut: $ostatniRzut)
        }
        .navigationTitle("Karta Postaci")
        .sheet(item: $aktywnyElement) { element in
            switch element {
            case .edycjaStatystyk: PointBuyView(player: player)
            case .zarzadzanieStanami: ConditionsView(aktywneStany: $player.aktywneStany)
            }
        }
        .sheet(item: $showingAsiSheetForLevel) { level in
            ASISelectionView(player: player, level: level)
        }
        .onChange(of: player.klasa) {
            player.resetSubclassProperties()
            player.applyClassBonuses()
        }
        .onChange(of: player.poziom) { oldValue, newValue in
            if newValue < oldValue {
                for (level, _) in player.asiChoices where level > newValue {
                    player.asiChoices.removeValue(forKey: level)
                }
            }
        }
        .onAppear {
            player.applyClassBonuses()
            player.applyRaceBonuses()
        }
    }
    
    private func performInitiativeRoll() {
        player.useRelentless()
        let modyfikator = player.inicjatywa
        let rzutKosci = Int.random(in: 1...20)
        ostatniRzut = RollResult(tytul: "Rzut na Inicjatywę", wynikOstateczny: rzutKosci + modyfikator, rzutKosci: rzutKosci, modyfikator: modyfikator)
    }
}

// MARK: - Wydzielone Komponenty (Sekcje)

struct CharacterInfoSection: View {
    @Bindable var player: Player
    
    var body: some View {
        Section(header: Text("Podstawowe informacje")) {
            TextField("Imię Postaci", text: $player.imie).font(.headline)
            HStack {
                Picker("Rasa", selection: $player.rasa) {
                    ForEach(Race.allCases) { rasa in Text(rasa.rawValue).tag(rasa) }
                }
                Picker("Klasa", selection: $player.klasa) {
                    ForEach(Class.allCases) { klasa in Text(klasa.rawValue).tag(klasa) }
                }
            }
            Stepper("Poziom: \(player.poziom)", value: $player.poziom, in: 1...20)
        }
    }
}

struct SubclassPickerSection: View {
    @Bindable var player: Player
    
    var body: some View {
        Section(header: Text("Wybór Archetypu")) {
            if player.klasa == .wojownik {
                Picker("Archetyp Wojownika", selection: $player.fighterArchetype) {
                    Text("Wybierz...").tag(nil as FighterArchetype?)
                    ForEach(FighterArchetype.allCases, id: \.self) { archetype in
                        Text(archetype.rawValue).tag(archetype as FighterArchetype?)
                    }
                }
            }
            
            if player.klasa == .kleryk {
                Picker("Boska Domena", selection: $player.clericDomain) {
                    Text("Wybierz...").tag(nil as ClericDomain?)
                    ForEach(ClericDomain.allCases, id: \.self) { domain in
                        Text(domain.rawValue).tag(domain as ClericDomain?)
                    }
                }
            }
        }
    }
}

struct ClericAbilitiesView: View {
    @Bindable var player: Player
    
    // Stany do zarządzania widokami modalnymi
    @State private var featureToShow: CombatAction?
    @State private var showingExpertiseSelection = false
    @State private var showingNatureSkillSelection = false
    @State private var showingDruidCantripSelection = false
    // W przyszłości można dodać stany dla innych wyborów, np. języków

    var body: some View {
        Group {
            Section(header: Text("Wiara i Bóstwo")) {
                TextField("Imię Bóstwa", text: $player.deityName)
            }
            
            Section(header: Text("Zdolności Klasowe")) {
                if player.maxChannelDivinityUses > 0 {
                    HStack {
                        Button(action: {
                            featureToShow = CombatAction(id: "kanal-mocy", name: "Kanał Mocy", description: "Kierujesz boską energią, aby uzyskać magiczne efekty. Odzyskujesz użycia po krótkim lub długim odpoczynku.", source: "Zdolność klasowa", range: "-", hitBonus: "-", damage: "-", damageType: "-", rollable: .none)
                        }) { Text("Kanał Mocy") }
                        .foregroundColor(.primary)
                        Spacer()
                        Stepper("", value: $player.channelDivinityUses, in: 0...player.maxChannelDivinityUses).labelsHidden()
                        Text("\(player.maxChannelDivinityUses - player.channelDivinityUses) / \(player.maxChannelDivinityUses)")
                    }
                }
            }
            
            if let domain = player.clericDomain {
                Section(header: Text("Zdolności Domeny (\(domain.rawValue))")) {
                    
                    // Używamy `switch`, aby czytelnie obsłużyć każdą domenę
                    switch domain {
                    case .knowledge:
                        FeatureDescriptionView(name: "Błogosławieństwo Wiedzy", description: "Zyskujesz biegłość w dwóch dodatkowych językach.", sourceLevel: 1)
                        Button("Wybierz Ekspertyzy (\(player.knowledgeDomainExpertise.count)/2)") { showingExpertiseSelection = true }
                        
                    case .life:
                        FeatureDescriptionView(name: "Biegłość w Ciężkich Pancerzach", description: "Zyskujesz biegłość w ciężkich pancerzach.", sourceLevel: 1)
                        FeatureDescriptionView(name: "Uczeń Życia", description: "Twoje czary leczące przywracają dodatkowe PŻ równe 2 + poziom czaru.", sourceLevel: 1)
                        
                    case .light:
                        FeatureDescriptionView(name: "Sztuczka: Światło", description: "Znasz sztuczkę Światło.", sourceLevel: 1)
                        HStack {
                            Text("Ochronny Rozbłysk")
                            Spacer()
                            Stepper("", value: $player.protectiveFlareUses, in: 0...player.maxProtectiveFlareUses).labelsHidden()
                            Text("\(player.maxProtectiveFlareUses - player.protectiveFlareUses) / \(player.maxProtectiveFlareUses)")
                        }
                        
                    case .nature:
                        FeatureDescriptionView(name: "Biegłość w Ciężkich Pancerzach", description: "Zyskujesz biegłość w ciężkich pancerzach.", sourceLevel: 1)
                        Button(action: { showingNatureSkillSelection = true }) {
                            HStack { Text("Biegłość z Domeny"); Spacer(); Text(player.natureDomainSkillProficiency?.rawValue ?? "Wybierz") }
                        }
                        Button(action: { showingDruidCantripSelection = true }) {
                            HStack { Text("Sztuczka Druida"); Spacer(); Text(player.natureDomainDruidCantrip?.nazwa ?? "Wybierz") }
                        }

                    case .tempest:
                        FeatureDescriptionView(name: "Biegłości Domeny Burzy", description: "Zyskujesz biegłość w broniach żołnierskich i ciężkich pancerzach.", sourceLevel: 1)
                        FeatureDescriptionView(name: "Furia Burzy", description: "Jako reakcję na trafienie, możesz zadać atakującemu 2k8 obrażeń od błyskawic lub grzmotu (użycia równe mod. z Mądrości).", sourceLevel: 1)
                        
                    case .trickery:
                        FeatureDescriptionView(name: "Błogosławieństwo Oszusta", description: "Jako akcję, możesz dać sojusznikowi przewagę w testach Ukrywania się na 1 godzinę.", sourceLevel: 1)
                        
                    case .war:
                        FeatureDescriptionView(name: "Biegłości Domeny Wojny", description: "Zyskujesz biegłość w broniach żołnierskich i ciężkich pancerzach.", sourceLevel: 1)
                        HStack {
                            Text("Kapłan Wojny")
                            Spacer()
                            Stepper("", value: $player.warPriestUses, in: 0...player.maxWarPriestUses).labelsHidden()
                            Text("\(player.maxWarPriestUses - player.warPriestUses) / \(player.maxWarPriestUses)")
                        }
                    }
                    
                    // --- ZDOLNOŚCI 6 POZIOMU ---
                    if player.poziom >= 6 {
                        switch domain {
                        case .life:
                            FeatureDescriptionView(name: "Błogosławiony Uzdrowiciel", description: "Gdy rzucisz czar leczący na inną istotę, Ty również odzyskujesz PŻ równe 2 + poziom czaru.", sourceLevel: 6)
                        case .light:
                            FeatureDescriptionView(name: "Poprawiony Rozbłysk", description: "Możesz użyć Ochronnego Rozbłysku również, gdy atakowany jest Twój sojusznik.", sourceLevel: 6)
                        case .nature:
                            FeatureDescriptionView(name: "Tłumienie Żywiołów", description: "Jako reakcję, możesz zapewnić odporność na obrażenia od kwasu, zimna, ognia, błyskawic lub grzmotu.", sourceLevel: 6)
                        case .tempest:
                             FeatureDescriptionView(name: "Gniew Burzy", description: "Gdy istota w zasięgu 5 stóp trafi Cię atakiem, możesz odepchnąć ją na 10 stóp.", sourceLevel: 6)
                        case .war:
                            FeatureDescriptionView(name: "Błogosławieństwo Boga Wojny", description: "Używając Kanału Mocy, możesz dać sojusznikowi premię +10 do jego rzutu na atak.", sourceLevel: 6)
                        default: EmptyView()
                        }
                    }
                    
                    // --- ZDOLNOŚCI 8 POZIOMU ---
                    if player.poziom >= 8 {
                        FeatureDescriptionView(name: domain.level8FeatureName, description: domain.level8FeatureDescription, sourceLevel: 8)
                    }
                    
                    // --- ZDOLNOŚCI 17 POZIOMU ---
                    if player.poziom >= 17 {
                        switch domain {
                        case .life:
                            FeatureDescriptionView(name: "Najwyższe Leczenie", description: "Twoje czary leczące zawsze przywracają maksymalną możliwą liczbę punktów życia.", sourceLevel: 17)
                        case .light:
                            FeatureDescriptionView(name: "Korona Światłości", description: "Jako akcję, możesz stworzyć aurę światła, która daje utrudnienie wrogom w rzutach obronnych przeciwko czarom zadającym obrażenia od ognia lub promieniste.", sourceLevel: 17)
                        case .tempest:
                            FeatureDescriptionView(name: "Urodzony w Burzy", description: "Zyskujesz szybkość latania równą Twojej aktualnej szybkości chodzenia, gdy jesteś na zewnątrz.", sourceLevel: 17)
                        case .war:
                            FeatureDescriptionView(name: "Awatar Bitwy", description: "Zyskujesz odporność na obrażenia kłute, cięte i obuchowe od broni niemagicznej.", sourceLevel: 17)
                        default: EmptyView()
                        }
                    }
                }
            }
        }
        .foregroundColor(.primary)
        .sheet(item: $featureToShow) { feature in
            ActionDetailView(action: feature)
        }
        .sheet(isPresented: $showingExpertiseSelection) { ExpertiseSelectionView(player: player) }
        .sheet(isPresented: $showingNatureSkillSelection) { SkillProficiencySelectionView(player: player) }
        .sheet(isPresented: $showingDruidCantripSelection) { DruidCantripSelectionView(player: player) }
    }
}


struct FighterAbilitiesView: View {
    @Bindable var player: Player
    @Binding var ostatniRzut: RollResult? // Dodajemy binding do rzutu
    
    @State private var showingManeuverSelection = false
    @State private var showingToolSelection = false
    @State private var showingWeaponBondSelection = false
    @State private var featureToShow: CombatAction?
    
    var body: some View {
        Section(header: Text("Zdolności Wojownika")) {
            NavigationLink("Styl Walki (\(player.fightingStyles.count)/\(player.fighterArchetype == .champion && player.poziom >= 10 ? 2 : 1))") {
                FightingStyleSelectionView(player: player)
            }
            
            Button(action: useSecondWind) {
                HStack {
                    Text("Drugi Oddech")
                    Spacer()
                    Text(player.hasUsedSecondWind ? "Zużyto" : "1k10 + \(player.poziom)")
                        .foregroundStyle(player.hasUsedSecondWind ? .secondary : Color.accentColor)
                }
            }
            .disabled(player.hasUsedSecondWind)
            .foregroundColor(.primary)
            
            HStack {
                // Ta część jest teraz przyciskiem
                Button(action: {
                    featureToShow = CombatAction(
                        id: "przyplyw-mocy",
                        name: "Przypływ Mocy (Action Surge)",
                        description: "W swojej turze możesz wykonać jedną dodatkową akcję. Możesz użyć tej zdolności ponownie po krótkim lub długim odpoczynku. Od 17. poziomu możesz użyć jej dwa razy przed odpoczynkiem.",
                        source: "Zdolność klasowa", range: "-", hitBonus: "-", damage: "-", damageType: "-", rollable: .none
                    )
                }) {
                    Text("Przypływ Mocy")
                }
                .foregroundColor(.primary)
                
                Spacer()
                
                // Stepper pozostaje do zarządzania użyciami
                Stepper("", value: $player.actionSurgeUses, in: 0...player.maxActionSurgeUses)
                    .labelsHidden()
                Text("\(player.maxActionSurgeUses - player.actionSurgeUses) / \(player.maxActionSurgeUses)")
            }
            
            if player.maxIndomitableUses > 0 {
                HStack {
                    Button(action: {
                        featureToShow = CombatAction(
                            id: "niezlomnosc",
                            name: "Niezłomność (Indomitable)",
                            description: "Możesz przerzucić rzut obronny, który Ci się nie powiódł. Musisz użyć nowego wyniku.",
                            source: "Zdolność klasowa", range: "-", hitBonus: "-", damage: "-", damageType: "-", rollable: .none
                        )
                    }) {
                        Text("Niezłomność")
                    }
                    .foregroundColor(.primary)
                    Spacer()
                    Stepper("", value: $player.indomitableUses, in: 0...player.maxIndomitableUses).labelsHidden()
                    Text("\(player.maxIndomitableUses - player.indomitableUses) / \(player.maxIndomitableUses)")
                }
            }
        }
        
        if let archetype = player.fighterArchetype {
            Section(header: Text("Zdolności Archetypu (\(archetype.rawValue))")) {
                
                // --- CZEMPION ---
                if archetype == .champion {
                    FeatureDescriptionView(name: "Ulepszony Rzut Krytyczny", description: "Twoje ataki bronią trafiają krytycznie przy rzucie \(player.poziom >= 15 ? "18" : "19")-20.", sourceLevel: 3)
                    
                    if player.poziom >= 7 {
                        FeatureDescriptionView(name: "Wybitny Atleta", description: "Możesz dodać połowę swojej premii z biegłości do testów Siły, Zręczności lub Kondycji, które jeszcze jej nie uwzględniają.", sourceLevel: 7)
                    }
                    if player.poziom >= 18 {
                        // Dodajemy przycisk do aktywacji Ocaleńca
                        Button(action: { player.useSurvivor() }) {
                             FeatureDescriptionView(name: "Ocaleniec (Użyj)", description: "Na początku swojej tury odzyskujesz punkty życia równe 5 + modyfikator z Kondycji, jeśli masz mniej niż połowę PŻ.", sourceLevel: 18)
                        }
                        .disabled(player.currentHitPoints >= (player.hitPointsMaximum / 2))
                        .foregroundColor(.primary)
                    }
                }
                
                // --- MISTRZ BITWY ---
                if archetype == .battleMaster {
                    Stepper("Kości Dominacji (k\(player.superiorityDiceType)): \(player.maxSuperiorityDice - player.superiorityDiceUsed) / \(player.maxSuperiorityDice)",
                            value: $player.superiorityDiceUsed,
                            in: 0...player.maxSuperiorityDice)
                    
                    Button("Zarządzaj manewrami (\(player.maneuvers?.count ?? 0)/\(player.maxManeuversKnown))") {
                        showingManeuverSelection = true
                    }
                    .foregroundColor(.primary)
                    
                    Button(action: { showingToolSelection = true }) {
                        HStack {
                            Text("Biegłość (Uczeń Wojny)")
                            Spacer()
                            Text(player.studentOfWarProficiency ?? "Wybierz").foregroundStyle(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                    
                    if player.poziom >= 15 {
                        FeatureDescriptionView(name: "Nieustępliwość", description: "Gdy wykonujesz rzut na inicjatywę i nie masz Kości Dominacji, odzyskujesz jedną.", sourceLevel: 15)
                    }
                }
                
                // --- MISTYCZNY RYCERZ ---
                if archetype == .eldritchKnight {
                    Button(action: { showingWeaponBondSelection = true }) {
                        HStack {
                            Text("Więź z Bronią")
                            Spacer()
                            Text("\(player.bondedWeapons?.count ?? 0)/2")
                        }
                    }
                    .foregroundColor(.primary)
                    
                    if player.poziom >= 7 {
                        FeatureDescriptionView(name: "Magia Wojenna", description: "Gdy w swojej turze użyjesz akcji do rzucenia sztuczki, możesz za pomocą akcji dodatkowej wykonać jeden atak bronią.", sourceLevel: 7)
                    }
                    if player.poziom >= 10 {
                        FeatureDescriptionView(name: "Mistyczne Uderzenie", description: "Gdy trafisz istotę bronią, ma ona utrudnienie w następnym rzucie obronnym przeciwko Twojemu czarowi.", sourceLevel: 10)
                    }
                    if player.poziom >= 15 {
                        FeatureDescriptionView(name: "Tajemna Szarża", description: "Używając Przypływu Mocy, możesz teleportować się na odległość do 30 stóp.", sourceLevel: 15)
                    }
                    if player.poziom >= 18 {
                        FeatureDescriptionView(name: "Ulepszona Magia Wojenna", description: "Gdy użyjesz akcji Ataku, możesz rzucić czar jako akcję dodatkową.", sourceLevel: 18)
                    }
                }
            }
            .sheet(item: $featureToShow) { feature in
                        ActionDetailView(action: feature)
                    }
            .sheet(isPresented: $showingManeuverSelection) { ManeuverSelectionView(player: player) }
            .sheet(isPresented: $showingToolSelection) { ToolProficiencySelectionView(selectedProficiency: $player.studentOfWarProficiency) }
            .sheet(isPresented: $showingWeaponBondSelection) { WeaponBondSelectionView(player: player) }
        }
    }
    
    // Przeniesiona funkcja, aby zachować czystość kodu
    private func useSecondWind() {
        let roll = Int.random(in: 1...10)
        let healingAmount = roll + player.poziom
        player.currentHitPoints = min(player.hitPointsMaximum, player.currentHitPoints + healingAmount)
        player.hasUsedSecondWind = true
        
        let rollResult = RollResult(
            tytul: "Drugi Oddech",
            wynikOstateczny: healingAmount,
            rzutKosci: roll,
            modyfikator: player.poziom,
            formula: "1k10 + \(player.poziom)"
        )
        ostatniRzut = rollResult
    }
}


struct BattleStatsSection: View {
    @Bindable var player: Player
    var onInitiativeRoll: () -> Void
    
    var body: some View {
        Section {
            HStack(spacing: 12) {
                StatBox(label: "Klasa Pancerza", value: "\(player.klasaPancerza)")
                Button(action: onInitiativeRoll) {
                    StatBox(label: "Inicjatywa", value: "\(player.inicjatywa >= 0 ? "+" : "")\(player.inicjatywa)")
                }.buttonStyle(.plain)
                StatBox(label: "Szybkość", value: "\(player.rasa.movingSpeed)m")
            }
        }
        .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
    }
}

struct MainStatsSection: View {
    @Bindable var player: Player
    var onEdit: () -> Void
    
    var body: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(BasicStatistics.allCases, id: \.self) { stat in
                        BasicStatisticView(
                            ostatecznaWartosc: player.currentStatistics[stat] ?? 10,
                            modyfikatorKoncowy: player.statisticsModifier(for: stat),
                            nazwa: stat.rawValue
                        )
                    }
                }
            }
            .listRowInsets(EdgeInsets())
        } header: {
            HStack {
                Text("Główne Cechy")
                Spacer()
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle").font(.title2)
                }
            }
        }
    }
}

struct HPAndResourcesSection: View {
    @Bindable var player: Player
    @Binding var ostatniRzut: RollResult?
    @Binding var aktywnyElement: ActiveModalElement?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        Section {
            let layout = (horizontalSizeClass == .compact) ?
            AnyLayout(VStackLayout(spacing: 16)) : AnyLayout(HStackLayout(alignment: .top, spacing: 16))
            
            layout {
                VStack(spacing: 16) {
                    HPView(player: player)
                    SavesAndSensesView(player: player, ostatniRzut: $ostatniRzut)
                }
                .frame(maxWidth: .infinity, alignment: .top)
                
                ActionsResourcesView(player: player, aktywnyElement: $aktywnyElement)
                    .frame(maxWidth: .infinity, alignment: .top)
            }
        }
        .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .buttonStyle(.plain)
    }
}

struct MagicSection: View {
    @Bindable var player: Player
    @Binding var ostatniRzut: RollResult?
    
    var body: some View {
        Section(header: Text("Magia")) {
            NavigationLink("Księga Czarów") {
                SpellbookView(player: player, ostatniRzut: $ostatniRzut)
            }
        }
    }
}

struct SkillsSection: View {
    @Bindable var player: Player
    @Binding var ostatniRzut: RollResult?
    
    var body: some View {
        Section(header: Text("Umiejętności")) {
            ForEach(Skills.allCases, id: \.self) { umiejetnosc in
                UmiejetnoscRowView(umiejetnosc: umiejetnosc, player: player, ostatniRzut: $ostatniRzut)
            }
        }
    }
}

struct ASISection: View {
    @Bindable var player: Player
    var onSelect: (Int) -> Void
    
    var body: some View {
        Section(header: Text("Ulepszenia Cech / Atuty")) {
            ForEach(player.asiLevels.filter { $0 <= player.poziom && player.asiChoices[$0] == nil }) { level in
                HStack {
                    Text("Wybór na \(level) poziomie")
                    Spacer()
                    Button("Wybierz") {
                        onSelect(level)
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            // --- NOWY SPOSÓB WYŚWIETLANIA ATUTÓW ---
            if !player.learnedFeats.isEmpty {
                Text("Wybrane Atuty:")
                    .font(.headline)
                    .padding(.top)
                
                ForEach(player.asiChoices.keys.sorted(), id: \.self) { level in
                    if let choice = player.asiChoices[level], case .feat(let feat) = choice {
                        FeatureDescriptionView(name: feat.nazwa, description: feat.opis, sourceLevel: level)
                    }
                }
            }
        }
    }
}

// MARK: - Pozostałe Widoki Pomocnicze

struct StatBox: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Zgodność z Identifiable
extension Int: Identifiable {
    public var id: Int { self }
}
