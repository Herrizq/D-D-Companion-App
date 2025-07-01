//
//  RoleplayView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct RoleplayView: View {
    @EnvironmentObject var viewModel: PlayerViewModel

    var body: some View {
        Form {
            Section(header: Text("Cechy Osobowości")) {
                TextEditor(text: $viewModel.postac.cechyOsobowości)
                    .frame(minHeight: 100)
            }
            Section(header: Text("Ideały")) {
                TextEditor(text: $viewModel.postac.ideały)
                    .frame(minHeight: 100)
            }
            Section(header: Text("Więzi")) {
                TextEditor(text: $viewModel.postac.więzi)
                    .frame(minHeight: 100)
            }
            Section(header: Text("Słabości")) {
                TextEditor(text: $viewModel.postac.słabości)
                    .frame(minHeight: 100)
            }
        }
        .navigationTitle("Osobowość i Tło")
    }
}
