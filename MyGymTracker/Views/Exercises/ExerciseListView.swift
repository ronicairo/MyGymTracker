import SwiftUI
import SwiftData

struct ExerciseListView: View {
    @State private var searchText = ""
    @State private var sortOption = SortOption.name
    @State private var showForm = false
    @State private var selectedExercise: Exercise?

    // Enum pour gérer les options de tri proprement
    enum SortOption: String, CaseIterable, Identifiable {
        case name = "Nom"
        case muscle = "Muscle"
        
        var id: Self { self }
    }

    var body: some View {
        NavigationView {
            // On passe les critères à la sous-vue qui gère la @Query
            ExerciseListContent(
                searchString: searchText,
                sortOption: sortOption,
                onSelect: { exercise in
                    selectedExercise = exercise
                    showForm = true
                }
            )
            .searchable(text: $searchText, prompt: "Rechercher (nom, muscle)...")
            .navigationTitle("Exercices")
            .toolbar {
                // 🔽 Menu de tri
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Trier par", selection: $sortOption) {
                            ForEach(SortOption.allCases) { option in
                                Label(option.rawValue, systemImage: option == .name ? "textformat" : "figure.strengthtraining.traditional")
                                    .tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .foregroundColor(.orange)
                    }
                }

                // ➕ Bouton Ajouter
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
                ExerciseFormView(exercise: selectedExercise)
            }
        }
    }
}

// 📦 SOUS-VUE pour gérer la requête dynamique
struct ExerciseListContent: View {
    @Environment(\.modelContext) private var context
    @Query private var exercises: [Exercise]
    let onSelect: (Exercise) -> Void

    init(searchString: String, sortOption: ExerciseListView.SortOption, onSelect: @escaping (Exercise) -> Void) {
        self.onSelect = onSelect

        // ⚙️ Construction du prédicat de recherche
        let predicate = #Predicate<Exercise> { ex in
            if searchString.isEmpty {
                return true
            } else {
                return ex.name.localizedStandardContains(searchString) ||
                       ex.muscle.localizedStandardContains(searchString)
            }
        }

        // ⚙️ Définition du tri
        let sortDescriptor: SortDescriptor<Exercise>
        switch sortOption {
        case .name:
            sortDescriptor = SortDescriptor(\Exercise.name)
        case .muscle:
            sortDescriptor = SortDescriptor(\Exercise.muscle)
        }

        // Initialisation de la Query
        _exercises = Query(filter: predicate, sort: [sortDescriptor])
    }

    var body: some View {
        List {
            ForEach(exercises) { exercise in
                Button {
                    onSelect(exercise)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(exercise.name)
                                .font(.headline)
                            
                            if !exercise.muscle.isEmpty {
                                Text(exercise.muscle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                    }
                }
                .foregroundStyle(.primary) // Garde le texte noir/blanc même dans un bouton
            }
            .onDelete(perform: deleteExercise)
        }
        .overlay {
            if exercises.isEmpty {
                ContentUnavailableView(
                    "Aucun exercice",
                    systemImage: "dumbbell",
                    description: Text("Essayez de modifier votre recherche ou ajoutez un nouvel exercice.")
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
