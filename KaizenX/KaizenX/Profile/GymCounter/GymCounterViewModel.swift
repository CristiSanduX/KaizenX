import Foundation
import FirebaseFirestore
import Firebase

class GymCounterViewModel: ObservableObject {
    @Published var muscleGroups: [String] = ["Piept", "Spate", "Brațe", "Picioare", "Umeri/Trapez", "Abdomen"]
    @Published var selectedMuscleGroup: String = "Piept"
    @Published var exercises: [GymExercise] = []
    
    private var db = Firestore.firestore()
    private let userId: String = Auth.auth().currentUser?.uid ?? ""
    
    
    func addExercise(_ exercise: GymExercise, on date: Date) {
        guard let userId = Auth.auth().currentUser?.uid, !userId.isEmpty else { return }
        
        let dateString = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        let workoutRef = db.collection("users").document(userId).collection("daily_workouts").document(dateString)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let workoutDocument: DocumentSnapshot
            do {
                try workoutDocument = transaction.getDocument(workoutRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            var exercisesFromDB: [[String: Any]]
            if workoutDocument.exists {
                exercisesFromDB = workoutDocument.data()?["exercises"] as? [[String: Any]] ?? []
            } else {
                // Dacă documentul nu există, inițializează lista de exerciții
                exercisesFromDB = []
            }
            
            let newExerciseData: [String: Any] = [
                "name": exercise.name,
                "muscleGroup": exercise.muscleGroup,
                "sets": exercise.sets,
                "repetitions": exercise.repetitions,
                "weight": exercise.weight
            ]
            exercisesFromDB.append(newExerciseData)
            
            // Dacă documentul nu există, setează-l pentru prima dată
            if workoutDocument.exists {
                transaction.updateData(["exercises": exercisesFromDB], forDocument: workoutRef)
            } else {
                transaction.setData(["exercises": exercisesFromDB], forDocument: workoutRef)
            }
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("Error writing exercise to Firestore: \(error.localizedDescription)")
            } else {
                print("Exercise successfully added!")
                self.fetchExercisesForDate(date)
            }
        }
    }

    
    // Funcția pentru preluarea exercițiilor de la o dată specificată
    func fetchExercisesForDate(_ date: Date) {
        let dateString = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        guard let userId = Auth.auth().currentUser?.uid, !userId.isEmpty else { return }

        let workoutRef = db.collection("users").document(userId).collection("daily_workouts").document(dateString)

        workoutRef.getDocument { (documentSnapshot, error) in
            if let document = documentSnapshot, document.exists {
                let data = document.data() ?? [:]
                if let exercisesData = data["exercises"] as? [[String: Any]] {
                    self.exercises = exercisesData.map { dict in
                        let name = dict["name"] as? String ?? "Unknown"
                        let muscleGroup = dict["muscleGroup"] as? String ?? "Unknown"
                        let sets = dict["sets"] as? Int ?? 0
                        let repetitions = dict["repetitions"] as? Int ?? 0
                        let weight = dict["weight"] as? Double ?? 0.0
                        return GymExercise(name: name, muscleGroup: muscleGroup, sets: sets, repetitions: repetitions, weight: weight, date: Date()) // Date is not used here
                    }
                }
            } else {
                self.exercises = []
            }
        }
    }
}

struct GymExercise: Identifiable, Codable {
    var id = UUID().uuidString // This ensures every new exercise gets a unique ID
    var name: String
    var muscleGroup: String
    var sets: Int
    var repetitions: Int
    var weight: Double
    var date: Date
}
