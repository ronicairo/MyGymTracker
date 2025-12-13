import SwiftData

@Model
class Serie {
    var weight: Double
    var reps: Int

    init(weight: Double, reps: Int) {
        self.weight = weight
        self.reps = reps
    }
}
