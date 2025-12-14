import SwiftUI
import SwiftData

struct ImportView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // On récupère tous les exercices existants pour le menu de choix
    @Query(sort: \Exercise.name) private var existingExercises: [Exercise]

    @State private var textInput: String = ""
    @State private var parsedSessions: [SessionPreview] = []
    @State private var importLog: String = ""

    var body: some View {
        NavigationView {
            VStack {
                // ZONE DE SAISIE
                VStack(alignment: .leading) {
                    Text("Colle tes notes ici (JJ/MM: Titre ... * exo...)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    TextEditor(text: $textInput)
                        .font(.system(.body, design: .monospaced))
                        .padding(5)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                        .frame(maxHeight: 150)
                    
                    Button("Analyser le texte") {
                        analyzeText()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(textInput.isEmpty)
                }
                .padding(.horizontal)

                Divider()

                // ZONE DE VALIDATION (INTERACTIVE)
                List {
                    if parsedSessions.isEmpty && !importLog.isEmpty {
                        Text(importLog).foregroundStyle(.red)
                    }
                    
                    // On utilise des Bindings ($) pour pouvoir modifier les choix
                    ForEach($parsedSessions) { $session in
                        Section(header: HStack {
                            Text(session.date.formatted(date: .numeric, time: .omitted))
                            if !session.notes.isEmpty {
                                Text("(\(session.notes))").bold()
                            }
                        }) {
                            ForEach($session.exercises) { $exo in
                                VStack(alignment: .leading, spacing: 8) {
                                    
                                    // 1. CHOIX DE L'EXERCICE CIBLE
                                    HStack {
                                        // Menu déroulant pour choisir l'exercice
                                        Picker("Exercice", selection: $exo.targetExercise) {
                                            
                                            // Option 1 : Créer un nouveau
                                            Text("🆕 Créer : \"\(exo.name)\"")
                                                .tag(Optional<Exercise>.none)
                                            
                                            Divider()
                                            
                                            // Option 2 : Liste des exercices existants
                                            ForEach(existingExercises) { dbExo in
                                                Text("🔗 Lier à : \(dbExo.name)")
                                                    .tag(Optional(dbExo))
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .labelsHidden()
                                        .tint(exo.targetExercise == nil ? .orange : .green)
                                        
                                        Spacer()
                                    }

                                    // 2. MODIFICATION DU NOM (Si on crée un nouveau)
                                    if exo.targetExercise == nil {
                                        TextField("Nom de l'exercice", text: $exo.name)
                                            .font(.subheadline)
                                            .textFieldStyle(.roundedBorder)
                                    }

                                    // 3. DESCRIPTION DES SÉRIES
                                    Text(exo.seriesDescription)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Importer & Relier")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Valider l'import") { saveToDatabase() }
                        .disabled(parsedSessions.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }

    // MARK: - Algorithme & Analyse

    private func analyzeText() {
        parsedSessions = []
        importLog = ""
        
        let lines = textInput.components(separatedBy: .newlines)
        var currentSession: SessionPreview?
        
        // Regex Header: JJ/MM: Notes
        let headerRegex = try! NSRegularExpression(pattern: #"^(\d{1,2})\/(\d{1,2})(?:[:\s]+(.*))?"#)
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }

            // 1. DÉTECTION SÉANCE
            if let match = headerRegex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)) {
                if let validSession = currentSession { parsedSessions.append(validSession) }
                
                if let dayRange = Range(match.range(at: 1), in: trimmed),
                   let monthRange = Range(match.range(at: 2), in: trimmed) {
                    
                    let day = Int(trimmed[dayRange]) ?? 1
                    let month = Int(trimmed[monthRange]) ?? 1
                    var notes = ""
                    if match.numberOfRanges > 3, let notesRange = Range(match.range(at: 3), in: trimmed) {
                        notes = String(trimmed[notesRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                    }

                    let calendar = Calendar.current
                    var components = DateComponents()
                    components.year = calendar.component(.year, from: Date())
                    components.day = day
                    components.month = month
                    let date = calendar.date(from: components) ?? Date()
                    
                    currentSession = SessionPreview(date: date, notes: notes, exercises: [])
                }
                continue
            }

            // 2. DÉTECTION EXERCICE (* Nom : Stats)
            if trimmed.starts(with: "*") {
                let content = trimmed.dropFirst().trimmingCharacters(in: .whitespaces)
                let parts = content.split(separator: ":", maxSplits: 1).map { String($0) }
                
                let name = parts[0].trimmingCharacters(in: .whitespaces)
                let statsString = parts.count > 1 ? parts[1] : ""
                
                let series = parseSeries(from: statsString)
                let description = series.map { "\($0.weight)kg x \($0.reps)" }.joined(separator: ", ")
                
                // 🧠 AUTO-MATCHING
                // On cherche tout de suite le meilleur candidat
                let bestMatch = findBestMatch(for: name, in: existingExercises)
                
                let exoPreview = ExercisePreview(
                    name: name,
                    targetExercise: bestMatch, // On pré-remplit avec le match trouvé (ou nil)
                    series: series,
                    seriesDescription: description
                )
                currentSession?.exercises.append(exoPreview)
            }
        }
        
        if let validSession = currentSession { parsedSessions.append(validSession) }
        
        if parsedSessions.isEmpty {
            importLog = "Format non reconnu. Assure-toi d'avoir 'JJ/MM' au début."
        }
    }

    // MARK: - Algorithme de recherche intelligent 🧠 (V2)

        private func findBestMatch(for name: String, in exercises: [Exercise]) -> Exercise? {
            // On nettoie l'entrée (minuscule, sans accents, sans espaces inutiles)
            let input = name.clean()
            
            // 1. CORRESPONDANCE EXACTE
            if let exact = exercises.first(where: { $0.name.clean() == input }) {
                return exact
            }

            // 2. INCLUSION (L'un dans l'autre)
            // Ça résout "Shoulder press" -> "Converging Shoulder Press"
            // Et "Pompes serrés" -> "Pompes"
            // Et "Gainage 3x45s" -> "Gainage" (si le parsing a pris les stats dans le nom)
            if let contained = exercises.first(where: { dbExo in
                let dbName = dbExo.name.clean()
                return dbName.contains(input) || input.contains(dbName)
            }) {
                return contained
            }
            
            // 3. MOTS CLÉS COMMUNS (Bag of Words)
            // Ça résout "Press chest" -> "Chest Press" (ordre inversé)
            var bestWordMatch: Exercise?
            var maxCommonWords = 0
            
            let inputWords = Set(input.components(separatedBy: .whitespaces))
            
            for exercise in exercises {
                let dbWords = Set(exercise.name.clean().components(separatedBy: .whitespaces))
                let common = inputWords.intersection(dbWords)
                
                if common.count > maxCommonWords {
                    maxCommonWords = common.count
                    bestWordMatch = exercise
                }
            }
            
            // Si on a trouvé au moins un mot significatif en commun (et que ce n'est pas juste "de" ou "le")
            if let match = bestWordMatch, maxCommonWords >= 1 {
                // Petite sécurité : il faut que ça représente une bonne partie du mot
                return match
            }

            // 4. CORRECTION FAUTES (Levenshtein) - Dernier recours
            var bestLevenshteinMatch: Exercise?
            var bestScore: Double = 1.0

            for exercise in exercises {
                let target = exercise.name.clean()
                let distance = input.levenshtein(to: target)
                let maxLength = max(input.count, target.count)
                
                if maxLength == 0 { continue }
                
                let score = Double(distance) / Double(maxLength)
                
                if score < 0.4 && score < bestScore {
                    bestScore = score
                    bestLevenshteinMatch = exercise
                }
            }
            
            return bestLevenshteinMatch
        }

    private func parseSeries(from text: String) -> [SeriePreview] {
        let segments = text.split(separator: "/")
        var results: [SeriePreview] = []
        
        for segment in segments {
            let s = String(segment).lowercased()
            if s.contains("mn") || s.contains("min") || s.contains("cal") { continue }
            
            var currentWeight: Double = 0.0
            let weightPattern = #"(\d+[.,]?\d*)\s*kg"#
            if let range = s.range(of: weightPattern, options: .regularExpression) {
                let wStr = String(s[range]).replacingOccurrences(of: "kg", with: "").replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)
                currentWeight = Double(wStr) ?? 0.0
            }
            
            let setsPattern = #"(\d+)\s*x\s*(\d+)"#
            if let regex = try? NSRegularExpression(pattern: setsPattern) {
                let nsString = s as NSString
                let matches = regex.matches(in: s, range: NSRange(location: 0, length: nsString.length))
                for match in matches {
                    let sets = Int(nsString.substring(with: match.range(at: 1))) ?? 1
                    let reps = Int(nsString.substring(with: match.range(at: 2))) ?? 0
                    for _ in 0..<sets { results.append(SeriePreview(weight: currentWeight, reps: reps)) }
                }
            }
        }
        return results
    }

    // MARK: - Sauvegarde Finale

    private func saveToDatabase() {
        for sessionPreview in parsedSessions {
            let newSession = Session(date: sessionPreview.date, notes: sessionPreview.notes)
            context.insert(newSession)
            
            for exoPreview in sessionPreview.exercises {
                
                // C'est ici qu'on utilise le choix de l'utilisateur
                let finalExercise: Exercise
                
                if let target = exoPreview.targetExercise {
                    // L'utilisateur a choisi un exercice existant
                    finalExercise = target
                } else {
                    // L'utilisateur a choisi "Créer nouveau", on prend le nom (potentiellement édité)
                    let newExo = Exercise(name: exoPreview.name, muscle: "Autre")
                    context.insert(newExo)
                    finalExercise = newExo
                }
                
                let sessionExo = SessionExercise(exercise: finalExercise)
                newSession.exercises.append(sessionExo)
                
                for serieP in exoPreview.series {
                    let serie = Serie(weight: serieP.weight, reps: serieP.reps)
                    sessionExo.series.append(serie)
                }
            }
        }
        
        try? context.save()
        dismiss()
    }
}

// MARK: - Structures Internes

struct SessionPreview: Identifiable {
    let id = UUID()
    let date: Date
    let notes: String
    var exercises: [ExercisePreview]
}

struct ExercisePreview: Identifiable {
    let id = UUID()
    var name: String // Modifiable par l'utilisateur
    var targetExercise: Exercise? // Le lien vers la base de données (modifiable via Picker)
    let series: [SeriePreview]
    let seriesDescription: String
}

struct SeriePreview {
    let weight: Double
    let reps: Int
}

// MARK: - Extension String (Distance de Levenshtein)
extension String {
    func levenshtein(to destination: String) -> Int {
        let s1 = self.lowercased().map { $0 }
        let s2 = destination.lowercased().map { $0 }
        let s1len = s1.count
        let s2len = s2.count
        if s1len == 0 { return s2len }
        if s2len == 0 { return s1len }
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: s2len + 1), count: s1len + 1)
        for i in 0...s1len { matrix[i][0] = i }
        for j in 0...s2len { matrix[0][j] = j }
        for i in 1...s1len {
            for j in 1...s2len {
                let cost = (s1[i - 1] == s2[j - 1]) ? 0 : 1
                matrix[i][j] = Swift.min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost)
            }
        }
        return matrix[s1len][s2len]
    }
}

extension String {
    // Fonction utilitaire pour nettoyer le texte avant comparaison
    func clean() -> String {
        return self.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current) // Enlève les accents (é -> e)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
