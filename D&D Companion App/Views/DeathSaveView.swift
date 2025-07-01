//
//  DeathSaveView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct DeathSaveView: View {
    @Binding var count: Int
    
    var body: some View {
        HStack {
            // Pętla tworzy trzy interaktywne kółka
            ForEach(0..<3) { index in
                Image(systemName: index < count ? "circle.fill" : "circle")
                    .onTapGesture {
                        if index + 1 == count { count = index }
                        else { count = index + 1 }
                    }
            }
        }
        .foregroundColor(.primary)
    }
}

