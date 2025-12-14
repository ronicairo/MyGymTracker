import SwiftData
import Foundation

@Model
class Session {
    var date: Date
    var name: String = ""        // 🆕 Nom du modèle (ex: "Leg Day")
    var notes: String = ""
    var isTemplate: Bool = false // 🆕 Vrai si c'est un modèle
    
    // ⚠️ IMPORTANT : .cascade permet de supprimer les exercices quand on supprime la séance
    @Relationship(deleteRule: .cascade)
    var exercises: [SessionExercise] = []

    init(date: Date, notes: String = "", name: String = "", isTemplate: Bool = false) {
        self.date = date
        self.notes = notes
        self.name = name
        self.isTemplate = isTemplate
    }
    
    // Fonction pour copier un modèle en une vraie séance
    func duplicateAsRealSession() -> Session {
        let newSession = Session(date: Date(), notes: self.notes) // On reprend la note mais pas le nom/template
        
        for oldExo in self.exercises {
            // On copie l'exercice
            let newExo = SessionExercise(exercise: oldExo.exercise)
            
            // On copie chaque série (poids/reps cibles)
            for oldSerie in oldExo.series {
                let newSerie = Serie(weight: oldSerie.weight, reps: oldSerie.reps)
                newExo.series.append(newSerie)
            }
            newSession.exercises.append(newExo)
        }
        return newSession
    }
}
