import SwiftUI
import SwiftData

struct SessionListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]

    @State private var showForm = false
    @State private var selectedSession: Session?

    var body: some View {
        NavigationView {
            List {
                ForEach(sessions) { session in
                    NavigationLink {
                        SessionDetailView(session: session)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(session.date.formatted(date: .long, time: .omitted))
                                .font(.headline)

                            Text("\(session.exercises.count) exercice(s)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteSession)
            }
            .navigationTitle("Séances")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        selectedSession = nil
                        showForm = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showForm) {
                SessionFormView(
                    session: selectedSession ?? Session(date: Date()),
                    isNew: selectedSession == nil
                )
            }
        }
    }

    private func deleteSession(at offsets: IndexSet) {
        for index in offsets {
            context.delete(sessions[index])
        }
    }
}
