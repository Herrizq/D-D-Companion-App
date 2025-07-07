import SwiftUI
import SwiftData

struct CreateWeaponView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    // Stany do przechowywania danych nowej broni
    @State private var nazwa: String = ""
    @State private var kategoria: KategoriaBroni = .prosta
    @State private var koszt: String = "0 sz"
    @State private var iloscKosciObrazen: Int = 1
    @State private var koscObrazen: Int = 6
    @State private var typObrazen: String = "Cięte"
    @State private var waga: Double = 1.0
    @State private var wlasciwosci: String = "" // Właściwości jako tekst oddzielony przecinkami
    
    private let dostepneKosci = [4, 6, 8, 10, 12, 20, 100]
    
    var isFormValid: Bool {
        !nazwa.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Podstawowe Informacje")) {
                    TextField("Nazwa broni", text: $nazwa)
                    Picker("Kategoria", selection: $kategoria) {
                        ForEach(KategoriaBroni.allCases, id: \.self) { kategoria in
                            Text(kategoria.rawValue).tag(kategoria)
                        }
                    }
                }
                
                Section(header: Text("Obrażenia")) {
                    Stepper("Ilość kości: \(iloscKosciObrazen)", value: $iloscKosciObrazen, in: 1...10)
                    Picker("Rodzaj kości", selection: $koscObrazen) {
                        ForEach(dostepneKosci, id: \.self) { kosc in
                            Text("k\(kosc)").tag(kosc)
                        }
                    }
                    TextField("Typ obrażeń", text: $typObrazen)
                }
                
                Section(header: Text("Inne Statystyki")) {
                    TextField("Koszt", text: $koszt)
                    TextField("Waga", value: $waga, format: .number)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Właściwości (oddzielone przecinkiem)")) {
                    TextField("np. Lekka, Finezyjna, Rzucana", text: $wlasciwosci, axis: .vertical)
                        .lineLimit(3...)
                }
            }
            .navigationTitle("Stwórz Własną Broń")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Zapisz") {
                        saveWeapon()
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private func saveWeapon() {
        let propertiesArray = wlasciwosci.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        
        // --- ZMIENIONA LOGIKA TWORZENIA BRONI ---
        // Używamy nowego inicjalizatora, przekazując wszystkie wartości.
        let nowaBron = Weapon(
            id: UUID().uuidString,
            nazwa: nazwa,
            kategoria: kategoria,
            koszt: koszt,
            iloscKosciObrazen: iloscKosciObrazen,
            koscObrazen: koscObrazen,
            typObrazen: typObrazen,
            waga: waga,
            wlasciwosci: propertiesArray
        )
        
        // Wstawiamy nowy obiekt do kontekstu SwiftData
        modelContext.insert(nowaBron)
    }
}
