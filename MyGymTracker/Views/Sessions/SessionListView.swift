import SwiftUI
import SwiftData

struct SessionListView: View {
    @Environment(\.modelContext) private var context
    
    // 1. On récupère les vraies séances
    @Query(filter: #Predicate<Session> { $0.isTemplate == false }, sort: \Session.date, order: .reverse)
    private var sessions: [Session]
    
    // 2. On récupère aussi les templates pour le menu
    @Query(filter: #Predicate<Session> { $0.isTemplate == true }, sort: \Session.name)
    private var templates: [Session]

    @State private var sessionToEdit: Session?
    @State private var showImport = false

    var body: some View {
        NavigationView {
            List {
                ForEach(sessions) { session in
                    NavigationLink {
                        SessionDetailView(session: session)
                    } label: {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(session.date.formatted(date: .long, time: .omitted))
                                    .font(.headline)
                                if !session.notes.isEmpty {
                                    Text("(\(session.notes))")
                                        .foregroundStyle(.secondary)
                                        .font(.subheadline)
                                }
                            }
                            Text("\(session.exercises.count) exercice(s)")
                                .foregroundColor(.secondary)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) { context.delete(session) } label: { Label("Supprimer", systemImage: "trash") }
                        Button { sessionToEdit = session } label: { Label("Modifier", systemImage: "pencil") }.tint(.blue)
                    }
                }
            }
            .navigationTitle("Séances")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showImport = true } label: { Image(systemName: "square.and.arrow.down").foregroundColor(.blue) }
                }

                ToolbarItem(placement: .primaryAction) {
                    // 3. MENU DE CRÉATION
                    Menu {
                        // Option A : Séance Vide
                        Button {
                            sessionToEdit = Session(date: Date())
                        } label: {
                            Label("Nouvelle séance vide", systemImage: "square.and.pencil")
                        }
                        
                        Divider()
                        
                        // Option B : Depuis un modèle
                        if templates.isEmpty {
                            Text("Aucun modèle disponible")
                        } else {
                            ForEach(templates) { template in
                                Button {
                                    createSessionFrom(template)
                                } label: {
                                    Label(template.name, systemImage: "doc.on.doc")
                                }
                            }
                        }
                        
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.orange)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showImport) { ImportView() }
            .sheet(item: $sessionToEdit) { session in
                SessionFormView(session: session, isNew: session.modelContext == nil)
            }
        }
    }
    
    // Logique pour copier le modèle
    private func createSessionFrom(_ template: Session) {
        // On utilise la fonction qu'on a créée dans Session.swift
        let newSession = template.duplicateAsRealSession()
        
        // On ouvre directement le formulaire avec cette nouvelle séance pré-remplie
        sessionToEdit = newSession
    }
}
