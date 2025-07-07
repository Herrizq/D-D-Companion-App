// D&D Companion App/Views/ArmorDetailView.swift

import SwiftUI

struct ArmorDetailView: View {
    let armor: Armor
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    ArmorDetailSectionView(title: "Podstawowe Informacje") {
                        ArmorDetailRowView(label: "Typ", value: armor.typ)
                        Divider()
                        ArmorDetailRowView(label: "Klasa Pancerza (Bazowa)", value: "\(armor.klasaPancerzaBazowa)")
                        Divider()
                        ArmorDetailRowView(label: "Modyfikator ze Zręczności", value: armor.modyfikatorZeZrecznosci)
                        Divider()
                        if let wymaganaSila = armor.wymaganaSila {
                            ArmorDetailRowView(label: "Wymagana Siła", value: "\(wymaganaSila)")
                            Divider()
                        }
                        Divider()
                        ArmorDetailRowView(label: "Kara do Skradania", value: armor.karaDoSkradania ? "Tak" : "Nie")
                        Divider()
                        ArmorDetailRowView(label: "Waga", value: "\(armor.waga)")
                        Divider()
                        ArmorDetailRowView(label: "Koszt", value: armor.koszt)
                    }
                }
                .padding(.horizontal)
            }
            .background(Color(UIColor.systemGroupedBackground)) // Tło dla całego widoku
            .navigationTitle(armor.nazwa)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gotowe") { dismiss() }
                }
            }
        }
    }
}






struct ArmorDetailSectionView<Content: View>: View {
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
struct ArmorDetailRowView: View {
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
