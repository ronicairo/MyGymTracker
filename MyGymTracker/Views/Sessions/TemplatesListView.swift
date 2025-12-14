import SwiftUI
import SwiftData

struct TemplatesListView: View {
    @Environment(\.modelContext) private var context
    
    // On ne récupère QUE les sessions qui sont des templates
    @Query(filter: #Predicate<Session> { $0.isTemplate == true }, sort: \Session.name)
    private var templates: [Session]

    @State private var templateToEdit: Session?

    var body: some View {
        NavigationView {
            List {
                if templates.isEmpty {
                    Text("Aucun modèle prédéfini.")
                        .foregroundStyle(.secondary)
                }
                
                ForEach(templates) { template in
                    Button {
                        templateToEdit = template
                    } label: {
                        VStack(alignment: .leading) {
                            Text(template.name.isEmpty ? "Modèle sans nom" : template.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("\(template.exercises.count) exercice(s)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteTemplate)
            }
            .navigationTitle("Mes Modèles")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // Création d'un nouveau modèle
                        templateToEdit = Session(date: Date(), isTemplate: true)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $templateToEdit) { template in
                SessionFormView(session: template, isNew: template.modelContext == nil)
            }
        }
    }

    private func deleteTemplate(at offsets: IndexSet) {
        for index in offsets {
            context.delete(templates[index])
        }
    }
}
