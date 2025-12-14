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
                Section("Infos") {
                    // 🆕 Si c'est un modèle, on demande le NOM. Sinon la DATE.
                    if session.isTemplate {
                        TextField("Nom du modèle (ex: Pectoraux)", text: $session.name)
                            .font(.headline)
                    } else {
                        DatePicker("Date", selection: $session.date, displayedComponents: .date)
                    }
                    
                    TextField("Notes", text: $session.notes)
                }

                Section("Exercices") {
                    if session.exercises.isEmpty {
                        Text("Ajoutez vos exercices types ici")
                            .foregroundStyle(.secondary)
                            .italic()
                    } else {
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
            .navigationTitle(session.isTemplate ? "Éditer le modèle" : (isNew ? "Nouvelle séance" : "Modifier séance"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") { dismiss() }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { cancel() }
                }
            }
            .onAppear {
                if isNew { context.insert(session) }
            }
        }
    }

    private func addExercise() {
        guard let first = exercises.first else { return }
        let newSessionExercise = SessionExercise(exercise: first)
        withAnimation { session.exercises.append(newSessionExercise) }
    }

    private func deleteExercise(at offsets: IndexSet) {
        withAnimation { session.exercises.remove(atOffsets: offsets) }
    }

    private func cancel() {
        if isNew { context.delete(session) }
        dismiss()
    }
}
