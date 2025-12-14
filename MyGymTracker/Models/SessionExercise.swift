import SwiftData

@Model
class SessionExercise {
    var exercise: Exercise
    @Relationship(deleteRule: .cascade) var series: [Serie] = [] // 🆕 Cascade

    init(exercise: Exercise) {
        self.exercise = exercise
    }
}
