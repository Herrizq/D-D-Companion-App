//
//  CharacterSheetView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

enum ActiveModalElement: Identifiable {
    case edycjaStatystyk
    case zarzadzanieStanami

    var id: Self { self }
}



struct CharacterSheetView: View {
    // Zamiast @EnvironmentObject, przyjmujemy postać jako parametr
    @Bindable var player: Player
    
    // Binding do ostatniego rzutu jest przekazywany z ContentView
    @Binding var ostatniRzut: RollResult?
    
    @State private var aktywnyElement: ActiveModalElement?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var showingSpellSelection = false
    @State private var showingManeuverSelection = false
    
    private var shouldShowSubclassPicker: Bool {
        // Pokaż, jeśli poziom postaci jest wystarczający i subklasa nie została jeszcze wybrana
        switch player.klasa {
        case .wojownik:
            return player.poziom >= player.klasa.subclassSelectionLevel && player.fighterArchetype == nil
            // W przyszłości dodaj case dla innych klas
            // case .lotr:
            //    return player.poziom >= player.klasa.subclassSelectionLevel && player.rogueArchetype == nil
        default:
            return false
        }
    }
    
    var body: some View {
        Form {
            // -- Podstawowe informacje -- //
            Section(header: Text("Podstawowe informacje")) {
                TextField("Imię Postaci", text: $player.imie)
                    .font(.headline)
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
            if shouldShowSubclassPicker {
                Section(header: Text("Wybór Archetypu")) {
                    // Picker wyświetlany tylko dla Wojownika
                    if player.klasa == .wojownik {
                        Picker("Archetyp Wojownika", selection: $player.fighterArchetype) {
                            Text("Wybierz...").tag(nil as FighterArchetype?)
                            ForEach(FighterArchetype.allCases, id: \.self) { archetype in
                                Text(archetype.rawValue).tag(archetype as FighterArchetype?)
                            }
                        }
                    }
                    // W przyszłości: if player.klasa == .lotr { ... }
                }
            }
            if player.klasa == .wojownik {
                Section(header: Text("Zdolności Wojownika")) {
                    
                    // --- Wybór Stylu Walki (pojawi się na 1. poziomie) ---
                    if player.fightingStyles.isEmpty && player.poziom >= 1 {
                        NavigationLink("Wybierz Styl Walki") {
                            // Przekierowanie do nowego widoku wyboru
                            FightingStyleSelectionView(player: player)
                        }
                    } else if let style = player.fightingStyles.first {
                        // Wyświetlanie wybranego stylu
                        HStack {
                            Text("Styl Walki")
                            Spacer()
                            Text(style.rawValue)
                        }
                    }
                    
                    // --- Przypływ Mocy ---
                    Stepper("Przypływ Mocy: \(player.maxActionSurgeUses - player.actionSurgeUses) / \(player.maxActionSurgeUses)",
                            value: $player.actionSurgeUses,
                            in: 0...player.maxActionSurgeUses)
                    .disabled(player.actionSurgeUses >= player.maxActionSurgeUses)
                }
            }
            if let archetype = player.fighterArchetype {
                Section(header: Text("Zasoby Archetypu (\(archetype.rawValue))")) {
                    
                    // --- ZASOBY MISTRZA BITWY ---
                    if archetype == .battleMaster {
                        // Stepper do zarządzania zużytymi kośćmi
                        Stepper("Kości Dominacji (k\(player.superiorityDiceType)): \(player.maxSuperiorityDice - player.superiorityDiceUsed) / \(player.maxSuperiorityDice)",
                                value: $player.superiorityDiceUsed,
                                in: 0...player.maxSuperiorityDice)
                        
                        // Przycisk otwierający widok zarządzania manewrami
                        Button("Zarządzaj manewrami (\(player.maneuvers?.count ?? 0)/\(player.maxManeuversKnown))") {
                                showingManeuverSelection = true
                            }
                            .foregroundColor(.primary)
                    }
                    
                    // --- ZDOLNOŚCI CZEMPIONA ---
                    if archetype == .champion {
                        HStack {
                            Text("Ulepszony Rzut Krytyczny")
                            Spacer()
                            // Logika dla improved critical
                            Text(player.poziom >= 15 ? "18-20" : "19-20")
                        }
                    }
                }
            }
            Section {
                // StatBoxy (bez zmian)
                HStack(spacing: 12) {
                    // Ten StatBox będzie teraz dynamicznie się aktualizował
                    StatBox(label: "Klasa Pancerza", value: "\(player.klasaPancerza)")
                    Button(action: { performInitiativeRoll() }) { /* ... */ }.buttonStyle(.plain)
                    StatBox(label: "Szybkość", value: "\(player.rasa.movingSpeed)m")
                }
            }
            .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
            
            // -- Statystyki Bitewne -- //
            Section {
                HStack(spacing: 12) {
                    StatBox(label: "Klasa Pancerza", value: "\(player.klasaPancerza)")
                    Button(action: { performInitiativeRoll() }) {
                        StatBox(label: "Inicjatywa", value: "\(player.inicjatywa >= 0 ? "+" : "")\(player.inicjatywa)")
                    }.buttonStyle(.plain)
                    StatBox(label: "Szybkość", value: "\(player.rasa.movingSpeed)m")
                }
            }
            .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
            
            
            
            // -- Główne Cechy -- //
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
                    Button(action: { aktywnyElement = .edycjaStatystyk }) {
                        Image(systemName: "pencil.circle").font(.title2)
                    }
                }
            }
            
            // -- HP, Rzuty Obronne, Zasoby -- //
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
            
            if player.canCastSpells {
                Section(header: Text("Magia")) {
                    NavigationLink("Księga Czarów") {
                        // Zawsze prowadzi do tego samego widoku
                        SpellbookView(player: player, ostatniRzut: $ostatniRzut)
                    }
                }
            }
            
            // -- Umiejętności -- //
            Section(header: Text("Umiejętności")) {
                ForEach(Skills.allCases, id: \.self) { umiejetnosc in
                    UmiejetnoscRowView(umiejetnosc: umiejetnosc, player: player, ostatniRzut: $ostatniRzut)
                }
            }
        }
        .navigationTitle("Karta Postaci")
        .sheet(item: $aktywnyElement) { element in
            switch element {
            case .edycjaStatystyk:
                PointBuyView(player: player)
            case .zarzadzanieStanami:
                ConditionsView(aktywneStany: $player.aktywneStany)
            }
        }
        .sheet(isPresented: $showingSpellSelection) {
            EldritchKnightSpellSelectionView(player: player)
        }
        .sheet(isPresented: $showingManeuverSelection) {
            ManeuverSelectionView(player: player)
        }
        .onChange(of: player.klasa) {
            // Najpierw resetujemy dane starej subklasy
            player.resetSubclassProperties()
            // A potem aplikujemy bonusy dla nowej klasy
            player.applyClassBonuses()
        }
        .onChange(of: player.rasa) {
            player.applyRaceBonuses()
        }
        .onAppear {
            player.applyClassBonuses()
            player.applyRaceBonuses()
        }
    }
    
    private func performInitiativeRoll() {
        let modyfikator = player.inicjatywa
        let rzutKosci = Int.random(in: 1...20)
        
        let wynikRzutu = RollResult(
            tytul: "Rzut na Inicjatywę",
            wynikOstateczny: rzutKosci + modyfikator,
            rzutKosci: rzutKosci,
            modyfikator: modyfikator
        )
        ostatniRzut = wynikRzutu
    }
}

// Pomocniczy widok, bez zmian
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
