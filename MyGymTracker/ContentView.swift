import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ExerciseListView()
                .tabItem {
                    Label("Exercices", systemImage: "dumbbell")
                }

            SessionListView()
                .tabItem {
                    Label("Séances", systemImage: "calendar")
                }

            CalendarView()
                .tabItem {
                    Label("Calendrier", systemImage: "calendar.circle")
                }
        }
    }
}
