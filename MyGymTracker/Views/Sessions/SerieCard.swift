import SwiftUI

struct SerieCard: View {
    @Binding var serie: Serie
    let onDuplicate: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 8) {

            HStack(spacing: 12) {
                TextField("Kg", value: $serie.weight, format: .number)
                    .keyboardType(.decimalPad)
                    .frame(width: 80)
                    .serieField()

                TextField("Reps", value: $serie.reps, format: .number)
                    .keyboardType(.numberPad)
                    .frame(width: 80)
                    .serieField()

                Spacer()

                Button(action: onDuplicate) {
                    Image(systemName: "square.on.square")
                        .foregroundColor(.orange)
                }

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
            }
        }
    }
}
