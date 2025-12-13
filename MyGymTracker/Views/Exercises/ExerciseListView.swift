import SwiftUI
import SwiftData

struct ExerciseListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    @State private var showForm = false
    @State private var selectedExercise: Exercise?

    var body: some View {
        NavigationView {
            List {
                ForEach(exercises) { exercise in
                    Button {
                        selectedExercise = exercise
                        showForm = true
                    } label: {
                        Text(exercise.name)
                            .font(.headline)
                    }
                }
                .onDelete(perform: deleteExercise)
            }
            .navigationTitle("Exercices")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        selectedExercise = nil
                        showForm = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showForm) {
                ExerciseFormView(
                    exercise: selectedExercise
                )
            }
        }
    }

    private func deleteExercise(at offsets: IndexSet) {
        for index in offsets {
            context.delete(exercises[index])
        }
    }
}
