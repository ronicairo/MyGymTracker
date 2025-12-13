import SwiftData
import Foundation

@Model
class Session {
    var date: Date
    var exercises: [SessionExercise] = []

    init(date: Date) {
        self.date = date
    }
}
