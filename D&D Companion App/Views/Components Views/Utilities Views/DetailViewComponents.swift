import SwiftUI

// Widok dla całej sekcji (nagłówek + tło)
struct DetailSectionView<Content: View>: View {
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
            .padding(16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
}

// Widok dla pojedynczego wiersza (etykieta + wartość)
struct DetailRowView: View {
    let label: String
    let value: String

    var body: some View {
        VStack {
            HStack {
                Text(label)
                Spacer()
                Text(value)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.vertical, 4)
            Divider().padding(.leading, -16).padding(.trailing, -16)
        }
    }
}
