import SwiftUI
import SwiftData


@main
struct MyGymTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Exercise.self,
            Session.self,
            SessionExercise.self,
            Serie.self
        ])
    }
}
