import SwiftUI

struct FloatingDiceRoller: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    
    @State private var czyPanelJestRozwiniety = false
    @State private var wybraneKosci: [Int: Int] = [:]

    private let typyKosci = [20, 12, 100, 10, 8, 6, 4]
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            
            if czyPanelJestRozwiniety {
                VStack(spacing: 8) {
                    ForEach(typyKosci, id: \.self) { typ in
                        Button(action: { wybraneKosci[typ, default: 0] += 1 }) {
                            Text(typ == 100 ? "k100" : "k\(typ)")
                                .fontWeight(.bold)
                                .frame(width: 50, height: 50)
                                // ZMIANA: Prostsze, mniej kosztowne tło
                                .background(Circle().fill(Color(UIColor.secondarySystemGroupedBackground)))
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
                    
                    Button(action: wykonajRzut) {
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
                // ZMIANA: Prostsze, mniej kosztowne tło
                .background(Capsule().fill(Color(UIColor.systemBackground)))
                .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1)) // Zamiast cienia, delikatna ramka
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
                    // ZMIANA: Prostsze, mniej kosztowne tło
                    .background(Circle().fill(Color(UIColor.secondarySystemGroupedBackground)))
                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1)) // Delikatna ramka zamiast cienia
                    .rotationEffect(.degrees(czyPanelJestRozwiniety ? 90 : 0))
            }
        }
        .padding()
    }
    
    private func wykonajRzut() {
        viewModel.wykonajRzutOgolny(kosciDoRzucenia: wybraneKosci)
        withAnimation(.spring()) {
            wybraneKosci.removeAll()
            czyPanelJestRozwiniety = false
        }
    }
}
