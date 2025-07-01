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
    @EnvironmentObject var viewModel: PlayerViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var aktywnyElement: ActiveModalElement?
    
    
    var body: some View {
        Form {
            
            // -- Main Information About Character -- //
            Section(header: Text("Podstawowe informacje")) {
                TextField("Imię Postaci", text: $viewModel.postac.imie)
                    .font(.headline)
                HStack {
                    Picker("Rasa", selection: $viewModel.postac.rasa) {
                        ForEach(Race.allCases) { rasa in Text(rasa.rawValue).tag(rasa) }
                    }
                    Picker("Klasa", selection: $viewModel.postac.klasa) {
                        ForEach(Class.allCases) { klasa in Text(klasa.rawValue).tag(klasa) }
                    }
                }
                Stepper("Poziom: \(viewModel.postac.poziom)", value: $viewModel.postac.poziom, in: 1...20)
            }
            
            // -- Battle Statistics -- //
            Section {
                HStack(spacing: 12) {
                    StatBox(label: "Klasa Pancerza", value: "\(viewModel.postac.klasaPancerza)")
                    Button(action: { viewModel.InitiativeRoll() }) {
                        StatBox(label: "Inicjatywa", value: "\(viewModel.postac.inicjatywa >= 0 ? "+" : "")\(viewModel.postac.inicjatywa)")
                    }.buttonStyle(.plain)
                    StatBox(label: "Szybkość", value: "\(viewModel.postac.prędkość)m")
                }
            }
            .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
            
            // -- Main Statistics -- //
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(BasicStatistics.allCases, id: \.self) { stat in
                            BasicStatisticView(
                                ostatecznaWartosc: viewModel.postac.currentStatistics[stat] ?? 10,
                                modyfikatorKoncowy: viewModel.postac.StatisticsModifier(for: stat),
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
            
            // -- Hit Points, Saving Throws and Armor -- //
            Section {
                let layout = (horizontalSizeClass == .compact) ?
                    AnyLayout(VStackLayout(spacing: 16)) : AnyLayout(HStackLayout(alignment: .top, spacing: 16))
                
                layout {
                    // --- LEWA KOLUMNA ---
                    VStack(spacing: 16) {
                        HPView()
                        SavesAndSensesView()
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    
                    // --- PRAWA KOLUMNA (NOWY, JEDEN KOMPONENT) ---
                    ActionsResourcesView(aktywnyElement: $aktywnyElement)
                        .frame(maxWidth: .infinity, alignment: .top)
                }
            }
            .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
            .buttonStyle(.plain)
            
            // -- Skills -- //
            Section(header: Text("Umiejętności")) {
                ForEach(Skills.allCases, id: \.self) { umiejetnosc in
                    UmiejetnoscRowView(umiejetnosc: umiejetnosc, postacBinding: $viewModel.postac)
                }
            }
        }
        .navigationTitle("Karta Postaci")
        .sheet(item: $aktywnyElement) { element in
            switch element {
            case .edycjaStatystyk:
                PointBuyView().environmentObject(viewModel)
            case .zarzadzanieStanami:
                ConditionsView(aktywneStany: $viewModel.postac.aktywneStany)
            }
        }
        .onChange(of: viewModel.postac.klasa) { viewModel.ApplieClassBonuses() }
        .onChange(of: viewModel.postac.rasa) { viewModel.ApplieRaceBonuses() }
        .onAppear {
            viewModel.ApplieClassBonuses()
            viewModel.ApplieRaceBonuses()
        }
    }
}

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
