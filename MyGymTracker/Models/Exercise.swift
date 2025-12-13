import SwiftData

@Model
class Exercise {
    var name: String
    var muscle: String
    var notes: String
    var exercisesSessions: [SessionExercise] = []

    init(name: String, muscle: String, notes: String = "") {
        self.name = name
        self.muscle = muscle
        self.notes = notes
    }
}
