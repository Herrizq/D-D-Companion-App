//
//  HPView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct HPView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    
    var body: some View {
        TitledContainer(title: "Punkty Wytrzymałości") {
            HStack {
                VStack(alignment: .leading) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(viewModel.postac.currentHitPoints)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("/ \(viewModel.postac.hitPointsMaximum)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                    Text("Aktualne / Maksymalne")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack {
                    Button(action: { viewModel.ChangeHP(o: 1) }) {
                        Image(systemName: "plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .frame(height: 20)
                    
                    Button(action: { viewModel.ChangeHP(o: -1) }) {
                        Image(systemName: "minus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .frame(height: 20)
                }
                .frame(width: 50)
            }
        }
    }
}

