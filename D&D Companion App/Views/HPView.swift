//
//  HPView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct HPView: View {
    @Bindable var player: Player
    
    var body: some View {
        TitledContainer(title: "Punkty Wytrzymałości") {
            HStack {
                VStack(alignment: .leading) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(player.currentHitPoints)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("/ \(player.hitPointsMaximum)")
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
                    Button(action: { changeHP(by: 1) }) {
                        Image(systemName: "plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .frame(height: 20)
                    
                    Button(action: { changeHP(by: -1) }) {
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

    private func changeHP(by amount: Int) {
        let newValue = player.currentHitPoints + amount
        // Upewniamy się, że HP nie spadnie poniżej 0 i nie przekroczy maksimum.
        player.currentHitPoints = max(0, min(player.hitPointsMaximum, newValue))
    }
}
