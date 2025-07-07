import SwiftUI
import SwiftData

struct ManeuverSelectionView: View {
    @Bindable var player: Player
    @Query private var allManeuvers: [Maneuver]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Wybierz znane manewry")) {
                    Text("Możesz znać \(player.maneuvers?.count ?? 0) / \(player.maxManeuversKnown) manewrów.")
                        .foregroundColor((player.maneuvers?.count ?? 0) > player.maxManeuversKnown ? .red : .primary)
                    
                    ForEach(allManeuvers) { maneuver in
                        Button(action: { toggleManeuver(maneuver) }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(maneuver.nazwa)
                                        .font(.headline)
                                    Text(maneuver.opis)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                // Sprawdzamy, czy tablica manewrów zawiera ten konkretny manewr
                                if player.maneuvers?.contains(maneuver) ?? false {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                        .disabled(
                            !(player.maneuvers?.contains(maneuver) ?? false) &&
                            (player.maneuvers?.count ?? 0) >= player.maxManeuversKnown
                        )
                    }
                }
            }
            .navigationTitle("Nauka Manewrów")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gotowe") { dismiss() }
                }
            }
        }
    }
    
    private func toggleManeuver(_ maneuver: Maneuver) {
        // Inicjalizujemy tablicę, jeśli jest nil
        if player.maneuvers == nil { player.maneuvers = [] }
        
        if let index = player.maneuvers?.firstIndex(of: maneuver) {
            player.maneuvers?.remove(at: index)
        } else {
            if (player.maneuvers?.count ?? 0) < player.maxManeuversKnown {
                player.maneuvers?.append(maneuver)
            }
        }
    }
}
