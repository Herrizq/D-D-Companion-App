//
//  ConditionsView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct ConditionsView: View {
    @Binding var aktywneStany: Set<Condition>
    
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
        }
    }
    
    private func toggleStan(_ stan: Condition) {
        if aktywneStany.contains(stan) {
            aktywneStany.remove(stan)
        } else {
            aktywneStany.insert(stan)
        }
    }
}
