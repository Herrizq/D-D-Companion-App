//
//  FloatingDiceRoller.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 01/07/2025.
//

import SwiftUI
import ColorSync
import Combine
import Foundation

struct FloatingDiceRoller: View {
    @Bindable var player: Player
    @Binding var ostatniRzut: RollResult?

    @State private var czyPanelJestRozwiniety = false
    @State private var wybraneKosci: [Int: Int] = [:]

    private let typyKosci = [20, 12, 100, 10, 8, 6, 4]
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            if czyPanelJestRozwiniety {
                VStack(spacing: 8) {
                    ForEach(typyKosci.sorted(by: >), id: \.self) { typ in
                        Button(action: { wybraneKosci[typ, default: 0] += 1 }) {
                            Text(typ == 100 ? "k100" : "k\(typ)")
                                .fontWeight(.bold)
                                .frame(width: 50, height: 50)
                                .background(Circle().fill(Color(UIColor.systemGroupedBackground)))
                                .overlay(
                                    ZStack {
                                        if let ilosc = wybraneKosci[typ], ilosc > 0 {
                                            Circle().fill(Color.red)
                                                .frame(width: 22, height: 22)
                                            Text("\(ilosc)").font(.caption).foregroundColor(.white)
                                        }
                                    }
                                    .offset(x: 18, y: -18)
                                )
                        }
                    }
                    
                    Button(action: performGeneralRoll) {
                        Image(systemName: "dice.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(.green))
                    .disabled(wybraneKosci.isEmpty)
                    .padding(.top, 10)
                }
                .padding()
                .background(Capsule().fill(Color(UIColor.systemBackground)))
                .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .transition(.scale(scale: 0.1, anchor: .bottomTrailing).combined(with: .opacity))
            }
            
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    if czyPanelJestRozwiniety { wybraneKosci.removeAll() }
                    czyPanelJestRozwiniety.toggle()
                }
            }) {
                Image(systemName: czyPanelJestRozwiniety ? "xmark" : "die.face.5.fill")
                    .font(.title)
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(Color(UIColor.systemGroupedBackground)))
                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    .rotationEffect(.degrees(czyPanelJestRozwiniety ? 90 : 0))
            }
        }
    }
    
    private func performGeneralRoll() {
        var totalSum = 0
        var formula: [String] = []
        
        for diceType in wybraneKosci.keys.sorted(by: >) {
            if let count = wybraneKosci[diceType], count > 0 {
                var sumForType = 0
                for _ in 0..<count {
                    sumForType += Int.random(in: 1...diceType)
                }
                totalSum += sumForType
                formula.append("\(count)k\(diceType)")
            }
        }
        
        guard !formula.isEmpty else { return }
        
        let rollResult = RollResult(
            tytul: "Rzut Ogólny",
            wynikOstateczny: totalSum,
            rzutKosci: totalSum,
            modyfikator: 0,
            formula: formula.joined(separator: " + ")
        )
        
        showRollNotification(rollResult)

        withAnimation(.spring()) {
            wybraneKosci.removeAll()
            czyPanelJestRozwiniety = false
        }
    }

    private func showRollNotification(_ wynik: RollResult) {
        withAnimation(.spring()) {
            ostatniRzut = wynik
        }
        
        Task {
            try? await Task.sleep(for: .seconds(4))
            if ostatniRzut == wynik {
                withAnimation(.easeOut) {
                    ostatniRzut = nil
                }
            }
        }
    }
}
