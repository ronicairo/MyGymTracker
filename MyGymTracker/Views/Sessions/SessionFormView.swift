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
                    if session.exercises.isEmpty {
                        Text("Aucun exercice ajouté")
                            .foregroundStyle(.secondary)
                            .italic()
                    } else {
                        // On boucle directement sur les objets SessionExercise
                        ForEach(session.exercises) { sessionExercise in
                            SessionExerciseRow(sessionExercise: sessionExercise,
                                               exercises: exercises)
                        }
                        .onDelete(perform: deleteExercise)
                    }

                    Button {
                        addExercise()
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
                        cancel()
                    }
                }
            }
            .onAppear {
                // 💡 CRUCIAL : Si c'est une nouvelle session, on l'insère tout de suite
                // pour que SwiftData gère correctement les relations avec les exercices.
                if isNew {
                    context.insert(session)
                }
            }
        }
    }

    // MARK: - Actions

    private func addExercise() {
        guard let firstExercise = exercises.first else { return }
        
        let newSessionExercise = SessionExercise(exercise: firstExercise)
        
        // Comme 'session' est déjà dans le contexte (grâce au .onAppear),
        // l'ajout se fait proprement sans casser les liens.
        withAnimation {
            session.exercises.append(newSessionExercise)
        }
    }

    private func deleteExercise(at offsets: IndexSet) {
        withAnimation {
            session.exercises.remove(atOffsets: offsets)
        }
    }

    private func save() {
        // Rien de spécial à faire, SwiftData a déjà tout enregistré en temps réel.
        // On ferme juste la vue.
        dismiss()
    }

    private func cancel() {
        // Si c'était une nouvelle séance et qu'on annule, il faut la supprimer
        // car on l'a insérée au début (.onAppear).
        if isNew {
            context.delete(session)
        }
        dismiss()
    }
}
