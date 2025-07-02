//
//  ActionDetailView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 06/07/2025.
//

import Foundation
import SwiftUI

struct ActionDetailView: View {
    let action: CombatAction

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text(action.name)
                    .font(.largeTitle.bold())
                
                Text(action.source.uppercased())
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Divider()
                
                // Opis pobierany z obiektu
                Text(action.description)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Szczegóły Akcji")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
