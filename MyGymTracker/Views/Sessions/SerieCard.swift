import SwiftUI

struct SerieCard: View {
    @Binding var serie: Serie
    let onDuplicate: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Champs de saisie
            TextField("Kg", value: $serie.weight, format: .number)
                .keyboardType(.decimalPad)
                .frame(width: 80)
                .serieField()

            TextField("Reps", value: $serie.reps, format: .number)
                .keyboardType(.numberPad)
                .frame(width: 80)
                .serieField()

            Spacer()

            // Bouton Dupliquer
            Button(action: onDuplicate) {
                Image(systemName: "square.on.square")
                    .foregroundColor(.orange)
            }
            .buttonStyle(.borderless) // ✅ IMPORTANT : Rend le bouton indépendant dans une List/Form

            // Bouton Supprimer
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless) // ✅ IMPORTANT
        }
    }
}
