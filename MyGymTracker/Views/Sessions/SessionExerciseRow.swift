import SwiftUI
import SwiftData

struct SessionExerciseRow: View {
    @Binding var sessionExercise: SessionExercise
    let exercises: [Exercise]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // 🏋️ Exercice
            VStack(alignment: .leading, spacing: 6) {
                Text("Exercice")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Picker("Exercice", selection: $sessionExercise.exercise) {
                    ForEach(exercises) { ex in
                        Text(ex.name).tag(ex)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // 🔁 Séries
            VStack(spacing: 12) {
                ForEach(sessionExercise.series.indices, id: \.self) { index in
                    let binding = $sessionExercise.series[index]

                    SerieCard(
                        serie: binding,
                        onDuplicate: {
                            let copied = Serie(
                                weight: binding.wrappedValue.weight,
                                reps: binding.wrappedValue.reps
                            )

                            sessionExercise.series.insert(copied, at: index + 1)
                        },
                        onDelete: {
                            sessionExercise.series.remove(at: index)
                        }
                    )
                }
            }

            // ➕ Ajouter série
            Button {
                sessionExercise.series.append(Serie(weight: 0, reps: 0))
            } label: {
                Label("Ajouter une série", systemImage: "plus.circle.fill")
                    .foregroundColor(.orange)
                    .font(.headline)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }
}
