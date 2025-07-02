//
//  ConditionsView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct ConditionsView: View {
    @Binding var aktywneStany: [Condition]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List(Condition.allCases) { stan in
                Button(action: {
                    toggleStan(stan)
                }) {
                    HStack {
                        Text(stan.rawValue)
                        Spacer()
                        if aktywneStany.contains(stan) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Zarządzaj Stanami")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gotowe") { dismiss() }
                }
            }
        }
    }
    
    private func toggleStan(_ stan: Condition) {
        if let index = aktywneStany.firstIndex(of: stan) {
            // Jeśli stan już istnieje, usuwamy go
            aktywneStany.remove(at: index)
        } else {
            // Jeśli nie, dodajemy go
            aktywneStany.append(stan)
        }
    }
}
