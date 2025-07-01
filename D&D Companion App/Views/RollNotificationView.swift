//
//  RollNotificationView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI

struct RollNotificationView: View {
    // Potrzebujemy dostępu do ViewModelu, aby wywołać akcję rzutu na obrażenia
    @EnvironmentObject var viewModel: PlayerViewModel
    let wynik: RollResult

    var body: some View {
        VStack(spacing: 0) {
            // Główna część powiadomienia z wynikiem rzutu
            HStack(spacing: 15) {
                Image(systemName: "die.face.6.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(wynik.tytul.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.gray)
                    
                    // Używamy teraz nowej właściwości `rozbicie` z modelu
                    Text("\(wynik.rzutKosci) \(wynik.modyfikator >= 0 ? "+" : "") \(wynik.modyfikator)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    // Wyświetlamy formułę tylko jeśli istnieje
                    if let formula = wynik.formula {
                        Text(formula)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
                
                Spacer()
                
                Text("\(wynik.wynikOstateczny)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            
            // NOWA, WARUNKOWA CZĘŚĆ: Przycisk do rzutu na obrażenia
            // Pojawi się tylko, jeśli wynik rzutu był atakiem (RollResult.bronDoAtaku nie jest nil)
            if let bron = wynik.bronDoAtaku {
                Divider()
                    .background(Color.gray.opacity(0.5))
                
                Button(action: {
                    // Wywołujemy nową funkcję z ViewModelu do rzutu na obrażenia
                    viewModel.wykonajRzutNaObrazenia(dlaBroni: bron)
                }) {
                    let modyfikatorObrazen = viewModel.postac.StatisticsModifier(for: bron.wlasciwosci.contains("Finezyjna") && viewModel.postac.StatisticsModifier(for: .zręczność) > viewModel.postac.StatisticsModifier(for: .siła) ? .zręczność : .siła)
                    let formulaObrazen = "\(bron.iloscKosciObrazen)k\(bron.koscObrazen) \(modyfikatorObrazen >= 0 ? "+" : "") \(modyfikatorObrazen)"
                    
                    Label("Rzuć na Obrażenia (\(formulaObrazen))", systemImage: "shield.lefthalf.filled.slash")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                }
                .tint(.orange)
            }
        }
        .background(.black.opacity(0.95))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.4), radius: 10, y: -5)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
