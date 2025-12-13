import SwiftUI
import SwiftData

struct ExerciseCardView: View {
    let se: SessionExercise

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // 🏋️ Nom de l’exercice
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundStyle(.orange)
                    .font(.title3)

                Text(se.exercise.name)
                    .font(.headline)

                Spacer()
            }

            // 🔁 Séries
            VStack(spacing: 8) {
                ForEach(se.series) { serie in
                    HStack {
                        Text("\(Int(serie.weight)) kg")
                            .font(.headline)
                            .foregroundStyle(.orange)

                        Spacer()

                        Text("\(serie.reps) reps")
                            .foregroundColor(.secondary)
                    }
                    Divider()
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
    }
}
