//
//  FightingStyleSelectionView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 06/07/2025.
//

import Foundation
import SwiftUI

struct FightingStyleSelectionView: View {
    @Bindable var player: Player
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List(FightingStyle.allCases, id: \.self) { style in
            Button(action: {
                player.fightingStyles.append(style)
                dismiss()
            }) {
                HStack {
                    Text(style.rawValue)
                    Spacer()
                }
            }
            .foregroundColor(.primary)
        }
        .navigationTitle("Wybierz Styl Walki")
    }
}
