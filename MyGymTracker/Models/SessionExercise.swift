import SwiftData

@Model
class SessionExercise {
    var exercise: Exercise
    var series: [Serie] = []

    init(exercise: Exercise) {
        self.exercise = exercise
    }
}
