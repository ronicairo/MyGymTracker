import SwiftUI
import SwiftData

struct SessionExerciseRow: View {
    @Bindable var sessionExercise: SessionExercise
    let exercises: [Exercise]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // 🏋️ HEADER : Sélecteur d'exercice
            HStack {
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(.orange)
                    .font(.title3)
                
                Picker("Exercice", selection: $sessionExercise.exercise) {
                    ForEach(exercises) { ex in
                        Text(ex.name).tag(ex)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .tint(.primary)
                
                Spacer()
            }
            .padding(.bottom, 4)

            // 📋 TABLEAU DES SÉRIES (En-têtes)
            if !sessionExercise.series.isEmpty {
                HStack {
                    Text("Poids (kg)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: 80, alignment: .center)
                    
                    Text("Reps")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: 80, alignment: .center)
                    
                    Spacer()
                }
                .padding(.horizontal, 4)
            }

            // Liste des séries
            VStack(spacing: 8) {
                ForEach($sessionExercise.series) { $serie in
                    SerieCard(
                        serie: $serie,
                        onDuplicate: { duplicate(serie) },
                        onDelete: { delete(serie) }
                    )
                }
            }

            // ➕ BOUTON AJOUTER
            Button {
                withAnimation {
                    addSerie()
                }
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Ajouter une série")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .foregroundColor(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.borderless) // ✅ IMPORTANT : Pour qu'il fonctionne dans le Form
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }

    // MARK: - Logique

    private func addSerie() {
        let lastWeight = sessionExercise.series.last?.weight ?? 0
        let lastReps = sessionExercise.series.last?.reps ?? 0
        
        let newSerie = Serie(weight: lastWeight, reps: lastReps)
        sessionExercise.series.append(newSerie)
    }

    private func duplicate(_ serie: Serie) {
        guard let index = sessionExercise.series.firstIndex(where: { $0.id == serie.id }) else { return }
        
        let newSerie = Serie(weight: serie.weight, reps: serie.reps)
        
        withAnimation {
            sessionExercise.series.insert(newSerie, at: index + 1)
        }
    }

    private func delete(_ serie: Serie) {
        if let index = sessionExercise.series.firstIndex(where: { $0.id == serie.id }) {
            withAnimation {
                _ = sessionExercise.series.remove(at: index)
            }
        }
    }
}
