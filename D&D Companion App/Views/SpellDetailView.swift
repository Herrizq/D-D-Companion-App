// D&D Companion App/Views/SpellDetailView.swift

import SwiftUI

struct SpellDetailView: View {
    let czar: Spells
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            // ZMIANA: Używamy ScrollView zamiast List, aby obejść błąd kompilatora
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Ręcznie tworzymy wygląd sekcji
                    SpellDetailSectionView(title: "Podstawowe Informacje") {
                        SpellDetailRowView(label: "Szkoła magii", value: czar.szkolaMagii)
                        Divider()
                        SpellDetailRowView(label: "Poziom", value: czar.poziom == 0 ? "Sztuczka" : "\(czar.poziom)")
                        Divider()
                        SpellDetailRowView(label: "Czas rzucania", value: czar.czasRzucania)
                        Divider()
                        SpellDetailRowView(label: "Zasięg", value: czar.zasieg)
                        Divider()
                        SpellDetailRowView(label: "Komponenty", value: czar.komponenty.joined(separator: ", "))
                        Divider()
                        SpellDetailRowView(label: "Czas trwania", value: czar.czasTrwania)
                    }
                    
                    SpellDetailSectionView(title: "Opis") {
                        Text(czar.opis)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if let wyzszePoziomy = czar.wyzszePoziomy {
                        SpellDetailSectionView(title: "Na Wyższych Poziomach") {
                            Text(wyzszePoziomy)
                                .padding(.vertical, 5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                }
                .padding(.horizontal)
            }
            .background(Color(UIColor.systemGroupedBackground)) // Tło dla całego widoku
            .navigationTitle(czar.nazwa)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gotowe") { dismiss() }
                }
            }
        }
    }
}

// --- Pomocnicze widoki do budowy interfejsu ---

// Widok dla całej sekcji (nagłówek + tło)
struct SpellDetailSectionView<Content: View>: View {
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
struct SpellDetailRowView: View {
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
