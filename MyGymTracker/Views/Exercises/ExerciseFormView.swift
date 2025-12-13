import SwiftUI
import SwiftData

struct ExerciseFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var exercise: Exercise?   // ✅ optionnel

    @State private var name: String = ""
    @State private var muscle: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Exercice") {
                    TextField("Nom", text: $name)
                    TextField("Muscle", text: $muscle)
                }
            }
            .navigationTitle(exercise == nil ? "Nouvel exercice" : "Modifier exercice")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        save()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let exercise {
                    name = exercise.name
                    muscle = exercise.muscle
                }
            }
        }
    }

    private func save() {
        if let exercise {
            // ✏️ Modification
            exercise.name = name
            exercise.muscle = muscle
        } else {
            // ➕ Création
            let newExercise = Exercise(name: name, muscle: muscle)
            context.insert(newExercise)
        }

        dismiss()
    }
}
