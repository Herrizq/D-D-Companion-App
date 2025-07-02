//
//  ActionRowView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 06/07/2025.
//

import Foundation
import SwiftUI

struct ActionRowView: View {
    let action: CombatAction
    
    // Akcje wywoływane w widoku nadrzędnym
    var onRoll: () -> Void
    var onShowDetails: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Przycisk do pokazywania szczegółów
            Button(action: onShowDetails) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(action.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(action.source.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()

           
            
            // Kolumny ze statystykami
            HStack{
                Text(action.range)
                    .font(.subheadline)
                    .frame(width: 80, alignment: .center)
                    .padding(.trailing, 8)
                
                Text(action.hitBonus)
                    .font(.subheadline.bold())
                    .frame(width: 50, alignment: .center)
                    .padding(.trailing, 8)
                
                Text(action.damage)
                    .font(.subheadline)
                    .frame(width: 100, alignment: .leading)
                    .padding(.trailing, 8)
                
                Text(action.damageType)
                    .font(.subheadline)
                    .frame(width: 100, alignment: .leading)
                    .padding(.trailing, 8)
                
                
                // Przycisk do rzucania kością
                Button(action: onRoll) {
                    Image(systemName: "dice.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .disabled(action.rollable == .none)
            }
        }
        .padding(.vertical, 8)
    }
}
