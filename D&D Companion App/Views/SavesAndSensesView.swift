//
//  SavesAndSensesView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct SavesAndSensesView: View {
    @EnvironmentObject var viewModel: PlayerViewModel

    var body: some View {
        TitledContainer(title: "Rzuty Obronne i Zmysły") {
            VStack(spacing: 10) {
                ForEach(BasicStatistics.allCases, id: \.self) { stat in
                    SavingThrowRowView(statystyka: stat, postacBinding: $viewModel.postac)
                }
                
                Divider().padding(.vertical, 5)
                
                HStack {
                    Text("Pasywna Percepcja").font(.caption)
                    Spacer()
                    Text("\(viewModel.postac.passiveWisdom)").fontWeight(.bold)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

