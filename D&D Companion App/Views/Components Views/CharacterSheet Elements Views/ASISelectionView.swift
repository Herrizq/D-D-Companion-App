import SwiftUI
import SwiftData

struct ASISelectionView: View {
    @Bindable var player: Player
    let level: Int
    
    @Environment(\.dismiss) var dismiss
    @Query private var allFeats: [Feat]
    
    @State private var selectionType: ASIType
    @State private var selectedFeat: Feat?
    @State private var pointIncreases: [BasicStatistics: Int]
    @State private var pointsToSpend: Int
    
    enum ASIType { case stats, feat }
    
    init(player: Player, level: Int) {
        self.player = player
        self.level = level
        
        // Wczytujemy istniejący wybór lub ustawiamy domyślne wartości
        if let existingChoice = player.asiChoices[level] {
            switch existingChoice {
            case .statIncrease(let points):
                _selectionType = State(initialValue: .stats)
                _pointIncreases = State(initialValue: points)
                _pointsToSpend = State(initialValue: 0) // Już wydane
            case .feat(let feat):
                _selectionType = State(initialValue: .feat)
                _pointIncreases = State(initialValue: [:])
                _pointsToSpend = State(initialValue: 2)
                _selectedFeat = State(initialValue: feat)
            }
        } else {
            // Domyślny stan dla nowego wyboru
            _selectionType = State(initialValue: .stats)
            _pointIncreases = State(initialValue: [:])
            _pointsToSpend = State(initialValue: 2)
        }
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Typ Ulepszenia", selection: $selectionType) {
                    Text("Ulepszenie Cech").tag(ASIType.stats)
                    Text("Wybór Atutu").tag(ASIType.feat)
                }
                .pickerStyle(.segmented)
                
                if selectionType == .stats {
                    Section(header: Text("Rozdaj 2 punkty")) {
                        Text("Punkty do wydania: \(pointsToSpend)")
                        
                        ForEach(BasicStatistics.allCases, id: \.self) { stat in
                            Stepper("\(stat.rawValue): +\(pointIncreases[stat, default: 0])") {
                                if pointsToSpend > 0 && pointIncreases[stat, default: 0] < 2 {
                                    pointIncreases[stat, default: 0] += 1
                                    pointsToSpend -= 1
                                }
                            } onDecrement: {
                                if pointIncreases[stat, default: 0] > 0 {
                                    pointIncreases[stat, default: 0] -= 1
                                    pointsToSpend += 1
                                }
                            }
                        }
                    }
                }
                
                if selectionType == .feat {
                    Section(header: Text("Wybierz Atut")) {
                        Picker("Dostępne Atuty", selection: $selectedFeat) {
                            Text("Brak").tag(nil as Feat?)
                            // --- POPRAWKA: Filtrujemy już wybrane atuty ---
                            ForEach(allFeats.filter { feat in
                                // Pokaż atut, jeśli nie jest jeszcze nauczony, LUB jeśli to ten, który edytujemy
                                !(player.learnedFeats.contains(where: { $0.id == feat.id })) || feat.id == selectedFeat?.id
                            }.sorted(by: { $0.nazwa < $1.nazwa })) { feat in
                                Text(feat.nazwa).tag(feat as Feat?)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Ulepszenie na \(level) poziomie")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Zatwierdź", action: saveChoice).disabled(!isChoiceValid())
                }
            }
        }
    }
    
    private func isChoiceValid() -> Bool {
        (selectionType == .stats && pointsToSpend == 0) || (selectionType == .feat && selectedFeat != nil)
    }
    
    private func saveChoice() {
        if selectionType == .stats {
            player.asiChoices[level] = .statIncrease(points: pointIncreases)
        } else if let feat = selectedFeat {
            player.asiChoices[level] = .feat(feat)
        }
        dismiss()
    }
}
