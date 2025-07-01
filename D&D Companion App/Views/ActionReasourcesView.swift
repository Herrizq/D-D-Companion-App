//
//  ActionReasourcesView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct ActionsResourcesView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @Binding var aktywnyElement: ActiveModalElement?

    var body: some View {
        VStack(spacing: 16) {
            TitledContainer(title: "Zasoby i Akcje") {
                HStack {
                    Text("Inspiracja")
                    Toggle("Inspiracja", isOn: $viewModel.postac.inspiracja).labelsHidden()
                    
                    Spacer()
                    
                    Text("Premia z Biegłości")
                    Text("+\(viewModel.postac.proficiencyBonus)").font(.title2).fontWeight(.bold)
                }
                .padding(.bottom, 8)
                .padding(.top, 5)
                
                Divider()
                
                HStack {
                    Button(action: { viewModel.ShortRest() }) {
                        Label("Krótki", systemImage: "hourglass").frame(maxWidth: .infinity)
                    }
                    .disabled(viewModel.postac.poziom - viewModel.postac.zuzyteKosciWytrzymalosci == 0)
                    
                    Button(action: { viewModel.LongRest() }) {
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
                        Text("\(viewModel.postac.poziom - viewModel.postac.zuzyteKosciWytrzymalosci)/\(viewModel.postac.poziom) \(viewModel.postac.koscWytrzymalosci.description)")
                            .fontWeight(.semibold)
                        
                        DeathSaveView(count: $viewModel.postac.successesInSavingThrows)
                        DeathSaveView(count: $viewModel.postac.failuresInSavingThrows)
                    }
                }
                .padding(.top, 8)
            }
            
            TitledContainer(title: "Stany") {
                VStack {
                    if viewModel.postac.aktywneStany.isEmpty {
                        Text("Brak aktywnych stanów").font(.caption).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 4)
                    } else {
                        Text(viewModel.postac.aktywneStany.map { $0.rawValue }.joined(separator: ", "))
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Button("Zarządzaj Stanami") { aktywnyElement = .zarzadzanieStanami }
                        .buttonStyle(.bordered).frame(maxWidth: .infinity)
                }
            }
        }
    }
}
