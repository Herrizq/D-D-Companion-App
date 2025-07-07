//
//  ActionReasourcesView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct ActionsResourcesView: View {
    @Bindable var player: Player
    @Binding var aktywnyElement: ActiveModalElement?

    var body: some View {
        VStack(spacing: 16) {
            TitledContainer(title: "Zasoby i Akcje") {
                HStack {
                    Text("Inspiracja")
                    Toggle("Inspiracja", isOn: $player.inspiracja).labelsHidden()
                    Spacer()
                    Text("Premia z Biegłości")
                    Text("+\(player.proficiencyBonus)").font(.title2).fontWeight(.bold)
                }
                .padding(.bottom, 8)
                .padding(.top, 5)
                
                Divider()
                
                HStack {
                    Button(action: {
                        // Wywołujemy nową, ulepszoną funkcję shortRest
                        player.shortRest()
                        // W przyszłości można tu dodać rzucanie kośćmi wytrzymałości
                    }) {
                        Label("Krótki", systemImage: "hourglass").frame(maxWidth: .infinity)
                    }
                    .disabled(player.poziom - player.zuzyteKosciWytrzymalosci == 0)
                    
                    Button(action: { player.longRest() }) {
                        Label("Długi", systemImage: "powersleep").frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.bordered)
                .padding(.vertical, 8)
                
                Divider()
                
                Grid(alignment: .center, horizontalSpacing: 20) {
                    GridRow {
                        Text("Kości Wytrzymałości").font(.caption).foregroundStyle(.secondary)
                        Text("Sukcesy").font(.caption).foregroundStyle(.secondary)
                        Text("Porażki").font(.caption).foregroundStyle(.secondary)
                    }
                    GridRow(alignment: .center) {
                        Text("\(player.poziom - player.zuzyteKosciWytrzymalosci)/\(player.poziom) \(player.koscWytrzymalosci.description)")
                            .fontWeight(.semibold)
                        
                        DeathSaveView(count: $player.successesInSavingThrows)
                        DeathSaveView(count: $player.failuresInSavingThrows)
                    }
                }
                .padding(.top, 8)
            }
            
            TitledContainer(title: "Stany") {
                VStack {
                    if player.aktywneStany.isEmpty {
                        Text("Brak aktywnych stanów").font(.caption).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 4)
                    } else {
                        Text(player.aktywneStany.map { $0.rawValue }.joined(separator: ", "))
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Button("Zarządzaj Stanami") { aktywnyElement = .zarzadzanieStanami }
                        .buttonStyle(.bordered).frame(maxWidth: .infinity)
                }
            }
        }
    }
}
