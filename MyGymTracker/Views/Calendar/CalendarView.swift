import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query(sort: \Session.date) var sessions: [Session]
    @State private var selectedDate = Date()

    private var daysInMonth: [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let monthStart = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start)?.start
        else { return [] }

        return (0..<42).compactMap { calendar.date(byAdding: .day, value: $0, to: monthStart) }
    }

    var body: some View {
        VStack(spacing: 16) {

            // 🔼 Mois + navigation
            HStack {
                Button { selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)! } label: {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text(selectedDate.formatted(.dateTime.year().month()))
                    .font(.title2.bold())

                Spacer()

                Button { selectedDate = Calendar.current.date(byAdding: .month, value: +1, to: selectedDate)! } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            // 📆 Grille des jours
            let columns = Array(repeating: GridItem(.flexible()), count: 7)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(daysInMonth, id: \.self) { day in
                    CalendarDayCell(
                        date: day,
                        isSelected: Calendar.current.isDate(day, inSameDayAs: selectedDate),
                        hasSession: sessions.contains { Calendar.current.isDate($0.date, inSameDayAs: day) }
                    )
                    .onTapGesture {
                        selectedDate = day
                    }
                }
            }
            .padding(.horizontal)

            Divider().padding(.horizontal)

            // 📋 Séances pour la date sélectionnée
            ScrollView {
                let todaysSessions = sessions.filter {
                    Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
                }

                if todaysSessions.isEmpty {
                    Text("Aucune séance ce jour.")
                        .foregroundStyle(.secondary)
                        .padding(.top, 20)
                } else {
                    VStack(spacing: 12) {
                        ForEach(todaysSessions) { session in
                            NavigationLink {
                                SessionDetailView(session: session)
                            } label: {
                                SessionCardSmall(session: session)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Calendrier")
    }
}

struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let hasSession: Bool

    var body: some View {
        let dayNumber = Calendar.current.component(.day, from: date)

        Text("\(dayNumber)")
            .font(.headline)
            .frame(width: 36, height: 36)
            .background(
                Circle().fill(
                    hasSession
                    ? (isSelected ? Color.green : Color.green.opacity(0.4))
                    : (isSelected ? Color.gray.opacity(0.3) : Color.clear)
                )
            )
            .overlay(
                Circle()
                    .stroke(hasSession ? Color.green : Color.clear, lineWidth: 2)
            )
            .foregroundColor(
                isSelected && hasSession ? .white :
                isSelected ? .primary :
                .primary
            )
    }
}


struct SessionCardSmall: View {
    let session: Session
    
    var body: some View {
        HStack {
            Image(systemName: "dumbbell")
                .foregroundStyle(.orange)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text(session.date.formatted(date: .long, time: .omitted))
                    .font(.headline)
                
                Text("\(session.exercises.count) exercice(s)")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(radius: 2, y: 2)
    }
}
