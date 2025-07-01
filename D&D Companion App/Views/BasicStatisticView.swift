//
//  BasicStatisticView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct BasicStatisticView: View {
    let ostatecznaWartosc: Int
    let modyfikatorKoncowy: Int
    let nazwa: String

    var body: some View {
        VStack(spacing: 4) {
            Text(nazwa.uppercased().prefix(3))
                .font(.headline)
                .padding(.bottom, 4)

            Text("\(ostatecznaWartosc)")
                .font(.title)
                .fontWeight(.bold)

            Text(modyfikatorKoncowy >= 0 ? "+\(modyfikatorKoncowy)" : "\(modyfikatorKoncowy)")
                .font(.title2)
                .frame(width: 60, height: 60)
                .background(Circle().fill(Color.secondary.opacity(0.2)))
        }
        .padding()
        .frame(width: 120)
    }
}
