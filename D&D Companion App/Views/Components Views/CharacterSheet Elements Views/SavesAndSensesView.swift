//
//  SavesAndSensesView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct SavesAndSensesView: View {
    @Bindable var player: Player
    @Binding var ostatniRzut: RollResult?

    var body: some View {
        TitledContainer(title: "Rzuty Obronne i Zmysły") {
            VStack(spacing: 10) {
                ForEach(BasicStatistics.allCases, id: \.self) { stat in
                    SavingThrowRowView(statystyka: stat, player: player, ostatniRzut: $ostatniRzut)
                }
                Divider().padding(.vertical, 5)
                HStack {
                    Text("Pasywna Percepcja").font(.caption)
                    Spacer()
                    Text("\(player.passiveWisdom)").fontWeight(.bold)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
