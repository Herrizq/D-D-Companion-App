import SwiftUI

struct FightingStyleSelectionView: View {
    @Bindable var player: Player
    @Environment(\.dismiss) var dismiss

    private var maxStyles: Int {
        player.fighterArchetype == .champion && player.poziom >= 10 ? 2 : 1
    }

    private var canSelectMore: Bool {
        player.fightingStyles.count < maxStyles
    }

    var body: some View {
        List(FightingStyle.allCases, id: \.self) { style in
            Button(action: {
                if !player.fightingStyles.contains(style) {
                    player.fightingStyles.append(style)
                }
                // Automatycznie zamknij widok, jeśli osiągnięto limit
                if !canSelectMore {
                    dismiss()
                }
            }) {
                HStack {
                    Text(style.rawValue)
                    Spacer()
                    if player.fightingStyles.contains(style) {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .foregroundColor(.primary)
            .disabled(!canSelectMore && !player.fightingStyles.contains(style))
        }
        .navigationTitle("Wybierz Styl Walki")
        .navigationBarTitleDisplayMode(.inline)
    }
}
