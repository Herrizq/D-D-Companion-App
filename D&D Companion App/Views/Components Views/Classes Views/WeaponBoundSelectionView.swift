//
//  WeaponBoundSelectionView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 07/07/2025.
//

import Foundation
import SwiftUI
import SwiftData

struct WeaponBondSelectionView: View {
    @Bindable var player: Player
    @Environment(\.dismiss) var dismiss

    private var availableWeapons: [Weapon] {
        // Pokazujemy tylko bronie, które są w ekwipunku, ale jeszcze nie są związane
        (player.carriedWeapons ?? []).filter { weapon in
            // Ta logika wymaga, aby relacja bondedWeapons była poprawnie zdefiniowana
            !(player.bondedWeapons?.contains(where: { $0.id == weapon.id }) ?? false)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Związane Bronie (\(player.bondedWeapons?.count ?? 0)/2)")) {
                    ForEach(player.bondedWeapons ?? []) { weapon in
                        HStack {
                            Text(weapon.nazwa)
                            Spacer()
                            Button("Złam więź") {
                                unbindWeapon(weapon)
                            }
                            .tint(.red)
                        }
                    }
                }
                
                if (player.bondedWeapons?.count ?? 0) < 2 {
                    Section(header: Text("Wybierz broń do związania")) {
                        ForEach(availableWeapons) { weapon in
                            Button(weapon.nazwa) {
                                bindWeapon(weapon)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Więź z Bronią")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Gotowe") { dismiss() }
                }
            }
        }
    }
    
    private func bindWeapon(_ weapon: Weapon) {
        if player.bondedWeapons == nil { player.bondedWeapons = [] }
        player.bondedWeapons?.append(weapon)
    }
    
    private func unbindWeapon(_ weapon: Weapon) {
        player.bondedWeapons?.removeAll(where: { $0.id == weapon.id })
    }
}
