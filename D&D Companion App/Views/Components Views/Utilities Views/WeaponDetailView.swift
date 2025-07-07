// D&D Companion App/Views/WeaponDetailView.swift

import SwiftUI

struct WeaponDetailView: View {
    let weapon: Weapon
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    WeaponDetailSectionView(title: "Podstawowe Informacje") {
                        WeaponDetailRowView(label: "Kategoria", value: weapon.kategoria.rawValue)
                        Divider()
                        WeaponDetailRowView(label: "Obrażenia", value: "\(weapon.iloscKosciObrazen)k\(weapon.koscObrazen) \(weapon.typObrazen)")
                        Divider()
                        WeaponDetailRowView(label: "Waga", value: "\(weapon.waga)")
                        Divider()
                        ArmorDetailRowView(label: "Koszt", value: weapon.koszt)
                    }
                    
                    WeaponDetailSectionView(title: "Właściwości") {
                        Text(weapon.wlasciwosci.joined(separator: ", "))
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                }
                .padding(.horizontal)
            }
            .background(Color(UIColor.systemGroupedBackground)) // Tło dla całego widoku
            .navigationTitle(weapon.nazwa)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gotowe") { dismiss() }
                }
            }
        }
    }
}
struct WeaponDetailSectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 16)
            
            VStack(alignment: .leading) {
                content
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

// Widok dla pojedynczego wiersza (etykieta + wartość)
struct WeaponDetailRowView: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
    }
}
