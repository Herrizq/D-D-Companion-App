//
//  FeatureDescriptionView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 07/07/2025.
//

import Foundation
import SwiftUI

struct FeatureDescriptionView: View {
    let name: String
    let description: String
    var sourceLevel: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.headline)
                if let level = sourceLevel {
                    Spacer()
                    Text("Poziom \(level)")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
            }
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
