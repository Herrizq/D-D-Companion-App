//
//  ProficiencySelectionView.swift
//  D&D Companion App
//
//  Created by Michał Nalepka on 07/07/2025.
//

import Foundation
import SwiftUI
import SwiftData

struct ToolProficiencySelectionView: View {
    // Lista przykładowych narzędzi rzemieślniczych
    private let toolOptions = ["Narzędzia kowalskie", "Narzędzia stolarskie", "Narzędzia kaletnicze", "Narzędzia alchemika"]
    
    // Binding do właściwości w modelu Player
    @Binding var selectedProficiency: String?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List(toolOptions, id: \.self) { tool in
                Button(action: {
                    selectedProficiency = tool
                    dismiss()
                }) {
                    HStack {
                        Text(tool)
                        Spacer()
                        if selectedProficiency == tool {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Wybierz biegłość")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SkillProficiencySelectionView: View {
    @Bindable var player: Player
    @Environment(\.dismiss) var dismiss
    
    // Kleryk Domeny Natury wybiera jedną z tych trzech umiejętności
    private let skillOptions: [Skills] = [.opiekaNadZwierzetami, .przyroda, .sztukaPrzetrwania]

    var body: some View {
        NavigationView {
            List(skillOptions, id: \.self) { skill in
                Button(action: {
                    player.natureDomainSkillProficiency = skill
                    dismiss()
                }) {
                    HStack {
                        Text(skill.rawValue)
                        Spacer()
                        if player.natureDomainSkillProficiency == skill {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Wybierz Biegłość")
        }
    }
}

// --- WIDOK DO WYBORU EKSPERTYZ (DLA DOMENY WIEDZY) ---
struct ExpertiseSelectionView: View {
    @Bindable var player: Player
    @Environment(\.dismiss) var dismiss
    
    // Kleryk Domeny Wiedzy wybiera dwie z tych czterech umiejętności
    private let expertiseOptions: [Skills] = [.historia, .religia, .wiedzaTajemna, .przyroda]
    private var canSelectMore: Bool {
        player.knowledgeDomainExpertise.count < 2
    }

    var body: some View {
        NavigationView {
            List(expertiseOptions, id: \.self) { skill in
                Button(action: {
                    toggleExpertise(for: skill)
                }) {
                    HStack {
                        Text(skill.rawValue)
                        Spacer()
                        if player.knowledgeDomainExpertise.contains(skill) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        } else {
                            Image(systemName: "circle")
                        }
                    }
                }
                .foregroundColor(.primary)
                .disabled(!canSelectMore && !player.knowledgeDomainExpertise.contains(skill))
            }
            .navigationTitle("Wybierz Ekspertyzy (\(player.knowledgeDomainExpertise.count)/2)")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gotowe") { dismiss() }
                }
            }
        }
    }
    
    private func toggleExpertise(for skill: Skills) {
        if let index = player.knowledgeDomainExpertise.firstIndex(of: skill) {
            player.knowledgeDomainExpertise.remove(at: index)
        } else if canSelectMore {
            player.knowledgeDomainExpertise.append(skill)
        }
    }
}


// --- WIDOK DO WYBORU SZTUCZKI DRUIDA (DLA DOMENY NATURY) ---
struct DruidCantripSelectionView: View {
    @Bindable var player: Player
    @Query private var allSpells: [Spells]
    @Environment(\.dismiss) var dismiss

    private var druidCantrips: [Spells] {
        allSpells.filter { $0.poziom == 0 && $0.dostepnyDlaKlas.contains("Druid") }
    }
    
    var body: some View {
        NavigationView {
            List(druidCantrips) { spell in
                Button(action: {
                    player.natureDomainDruidCantrip = spell
                    dismiss()
                }) {
                    HStack {
                        Text(spell.nazwa)
                        Spacer()
                        if player.natureDomainDruidCantrip?.id == spell.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Wybierz Sztuczkę Druida")
        }
    }
}
