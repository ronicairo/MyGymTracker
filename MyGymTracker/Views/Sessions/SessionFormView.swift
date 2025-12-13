import SwiftUI
import SwiftData

struct SessionFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    @Bindable var session: Session
    let isNew: Bool

    var body: some View {
        NavigationView {
            Form {

                // 📅 Date
                Section("Date") {
                    DatePicker("Date", selection: $session.date, displayedComponents: .date)
                }

                // 🏋️ Exercices
                Section("Exercices") {
                    ForEach($session.exercises) { $sessionExercise in
                        SessionExerciseRow(sessionExercise: $sessionExercise,
                                           exercises: exercises)
                    }

                    Button {
                        if let first = exercises.first {
                            session.exercises.append(
                                SessionExercise(exercise: first)
                            )
                        }
                    } label: {
                        Label("Ajouter un exercice", systemImage: "plus.circle")
                            .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle(isNew ? "Nouvelle séance" : "Modifier séance")
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
        }
    }

    private func save() {
        if isNew {
            context.insert(session)
        }
        dismiss()
    }
}
