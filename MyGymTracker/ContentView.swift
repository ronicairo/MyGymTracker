import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SessionListView()
                .tabItem {
                    Label("Séances", systemImage: "calendar")
                }
            
            // 🆕 Nouvel onglet pour gérer les modèles
            TemplatesListView()
                .tabItem {
                    Label("Modèles", systemImage: "list.bullet.clipboard")
                }

            ExerciseListView()
                .tabItem {
                    Label("Exercices", systemImage: "dumbbell")
                }

            CalendarView()
                .tabItem {
                    Label("Calendrier", systemImage: "calendar.circle")
                }
        }
    }
}
