//
//  PointBuyView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct PointBuyView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Punkty do rozdania")) {
                    Text("\(viewModel.pointsToSpend)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(viewModel.pointsToSpend == 0 ? .green : (viewModel.pointsToSpend < 0 ? .red : .primary))
                }

                Section(header: Text("Statystyki Bazowe (8-15)")) {
                    ForEach(BasicStatistics.allCases, id: \.self) { stat in
                        Stepper(
                            "\(stat.rawValue): \(viewModel.postac.baseStatistics[stat, default: 8])",
                            value: Binding(
                                get: {
                                    viewModel.postac.baseStatistics[stat, default: 8]
                                },
                                set: { newValue in
                                    viewModel.postac.baseStatistics[stat] = newValue
                                }
                            ),
                            in: 8...15
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
                    .disabled(viewModel.pointsToSpend != 0)
                }
            }
        }
    }
}
