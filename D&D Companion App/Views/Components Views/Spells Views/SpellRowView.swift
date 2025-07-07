import SwiftUI

struct SpellRowView: View {
    @Bindable var player: Player
    let czar: Spells
    let onRowTapped: () -> Void
    @Binding var ostatniRzut: RollResult?
    
    @State private var showCastingOptions = false
    
    private var isDomainSpell: Bool {
        guard let domain = player.clericDomain else { return false }
        return domain.spellIDs.values.flatMap { $0 }.contains(czar.id)
    }

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onRowTapped) {
                Image(systemName: "info.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.white, Color.accentColor)
                    .font(.title2)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(czar.nazwa).font(.headline)
                HStack(spacing: 6) {
                    Text("Szkoła magii: \(czar.szkolaMagii)")
                    if isDomainSpell, let domainName = player.clericDomain?.rawValue {
                        Text("• \(domainName)").fontWeight(.bold).foregroundStyle(.purple)
                    }
                }
                .font(.caption).foregroundStyle(.secondary)
            }
            .padding(.leading, 10)

            Spacer()

            if czar.czyRytual {
                Button(action: { castSpell(atLevel: czar.poziom, isRitual: true) }) {
                    Label("Rytuał", systemImage: "book.closed.fill")
                }
                .buttonStyle(.bordered).tint(.purple)
            } else {
                Button(action: {
                    if czar.poziom == 0 { castSpell(atLevel: 0, isRitual: false) }
                    else { showCastingOptions = true }
                }) {
                    Label("Rzuć czar", systemImage: "sparkles")
                }
                .buttonStyle(.bordered).disabled(isUnavailable)
            }
        }
        .padding(.vertical, 8)
        .confirmationDialog("Rzuć '\(czar.nazwa)' używając komórki...", isPresented: $showCastingOptions, titleVisibility: .visible) {
            let spellSlots = player.isEldritchKnight ? player.eldritchKnightCurrentSpellSlots : player.currentSpellSlots
            ForEach((czar.poziom..<10), id: \.self) { poziom in
                let index = poziom - 1
                if index < spellSlots.count, spellSlots[index] > 0 {
                    Button("Poziom \(poziom) (\(spellSlots[index]) dost.)") {
                        castSpell(atLevel: poziom, isRitual: false)
                    }
                }
            }
        }
    }
    
    private var isUnavailable: Bool {
        guard czar.poziom > 0 else { return false }
        let spellSlots = player.isEldritchKnight ? player.eldritchKnightCurrentSpellSlots : player.currentSpellSlots
        let usableLevels = czar.poziom..<10
        let canCast = usableLevels.contains { level in
            let index = level - 1
            guard index < spellSlots.count else { return false }
            return spellSlots[index] > 0
        }
        return !canCast
    }
    
    private func castSpell(atLevel level: Int, isRitual: Bool) {
        if !isRitual {
            player.useSpellSlot(atLevel: level)
        }
        
        if czar.wymagaAtaku == true {
            ostatniRzut = player.performSpellAttack(spell: czar, atLevel: level)
        } else if (czar.iloscKosciObrazen ?? 0) > 0 {
            performSpellDamageRoll(spell: czar, atLevel: level)
        } else {
            let resultTitle = isRitual ? "Rzucono Rytuał" : "Rzucono Czar"
            ostatniRzut = RollResult(tytul: resultTitle, wynikOstateczny: 0, rzutKosci: 0, modyfikator: 0, formula: czar.nazwa)
        }
    }
    
    private func performSpellDamageRoll(spell: Spells, atLevel level: Int) {
        guard var diceCount = spell.iloscKosciObrazen, let diceType = spell.koscObrazen else { return }
        if level > spell.poziom, ["leczenie-ran", "kula-ognia"].contains(spell.id) {
            diceCount += (level - spell.poziom)
        }
        
        var totalRoll = 0
        for _ in 0..<diceCount { totalRoll += Int.random(in: 1...diceType) }
        
        var damageModifier = 0
        if spell.typObrazen == "Leczenie" {
            damageModifier = player.spellcastingAbilityModifier
            if player.clericDomain == .life { damageModifier += (2 + level) }
        } else if spell.poziom == 0, let domain = player.clericDomain, (domain == .knowledge || domain == .light), player.poziom >= 8 {
            damageModifier += player.spellcastingAbilityModifier
        }
        
        let finalResult = totalRoll + damageModifier
        let formula = damageModifier != 0 ? "\(diceCount)k\(diceType) + \(damageModifier)" : "\(diceCount)k\(diceType)"
        
        ostatniRzut = RollResult(
            tytul: spell.typObrazen == "Leczenie" ? "Leczenie: \(spell.nazwa)" : "Obrażenia: \(spell.nazwa)",
            wynikOstateczny: finalResult, rzutKosci: totalRoll, modyfikator: damageModifier, formula: formula
        )
        
        if player.clericDomain == .life, player.poziom >= 6, spell.typObrazen == "Leczenie" {
            player.currentHitPoints = min(player.hitPointsMaximum, player.currentHitPoints + (2 + level))
        }
    }
}
