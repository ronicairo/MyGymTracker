import SwiftData

@Model
class SessionExercise {
    var exercise: Exercise
    var series: [Serie] = []
    
    // Ajout de la relation inverse (Optionnel mais recommandé)
    @Relationship(inverse: \Session.exercises)
    var session: Session?

    init(exercise: Exercise) {
        self.exercise = exercise
    }
}
