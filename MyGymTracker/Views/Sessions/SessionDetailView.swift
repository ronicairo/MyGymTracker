import SwiftUI
import SwiftData

struct SessionDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Bindable var session: Session

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                Text(session.date.formatted(date: .long, time: .omitted))
                    .font(.title.bold())

                ForEach(session.exercises) { se in
                    ExerciseCardView(se: se)
                }
            }
            .padding()
        }
        .navigationTitle("Séance")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SessionFormView(session: session, isNew: false)
                } label: {
                    Image(systemName: "pencil")
                }
            }

            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    context.delete(session)
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
    }
}
