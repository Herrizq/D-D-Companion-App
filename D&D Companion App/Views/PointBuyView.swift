//
//  PointBuyView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct PointBuyView: View {
    @Bindable var player: Player
    @Environment(\.dismiss) var dismiss

    private let pointCosts = [8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9]

    private var pointsSpent: Int {
        player.baseStatistics.values.reduce(0) { $0 + (pointCosts[$1] ?? 99) }
    }
    
    private var pointsRemaining: Int {
        27 - pointsSpent
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Punkty do rozdania")) {
                    Text("\(pointsRemaining)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(pointsRemaining == 0 ? .green : (pointsRemaining < 0 ? .red : .primary))
                }

                Section(header: Text("Statystyki Bazowe (8-15)")) {
                    ForEach(BasicStatistics.allCases, id: \.self) { stat in
                        Stepper(
                            "\(stat.rawValue): \(player.baseStatistics[stat, default: 8])",
                            onIncrement: { updateStat(stat, by: 1) },
                            onDecrement: { updateStat(stat, by: -1) }
                        )
                    }
                }
            }
            .navigationTitle("Edycja Statystyk")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gotowe") {
                        dismiss()
                    }
                    .disabled(pointsRemaining != 0)
                }
            }
        }
    }

    private func updateStat(_ stat: BasicStatistics, by value: Int) {
        let currentValue = player.baseStatistics[stat, default: 8]
        let newValue = currentValue + value
        if (8...15).contains(newValue) {
            player.baseStatistics[stat] = newValue
        }
    }
}
