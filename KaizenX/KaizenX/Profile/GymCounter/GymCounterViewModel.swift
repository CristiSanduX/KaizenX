import Foundation
import FirebaseFirestore
import Firebase
import HealthKit

struct PredefinedExercise: Identifiable {
    var id = UUID()
    var name: String
    var muscleGroup: String
    var description: String
    var gifName: String
}

struct GymExercise: Identifiable, Codable {
    var id = UUID().uuidString // This ensures every new exercise gets a unique ID
    var name: String
    var muscleGroup: String
    var sets: Int
    var repetitions: Int
    var weight: Int
    var date: Date
    var description: String = ""
    var imageName: String = ""
}

class GymCounterViewModel: ObservableObject {
    @Published var muscleGroups: [String] = ["Piept", "Spate", "Biceps","Triceps", "Picioare", "Umeri/Trapez", "Abdomen"]
    @Published var selectedMuscleGroup: String = "Piept"
    @Published var exercises: [GymExercise] = []
    @Published var predefinedExercises: [PredefinedExercise] = []
    @Published var workouts: [HKWorkout] = []
    @Published var workoutsForSelectedDate: [HKWorkout] = []

    private var db = Firestore.firestore()
    private let userId: String = Auth.auth().currentUser?.uid ?? ""

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    init() {
        fetchPredefinedExercises()
    }

    func requestAuthorization() {
        HealthKitManager.shared.requestAuthorization2 { success in
            if success {
                self.fetchWorkouts()
            } else {
                print("HealthKit authorization failed")
            }
        }
    }

    func fetchWorkouts() {
        HealthKitManager.shared.fetchWorkouts { workouts in
            DispatchQueue.main.async {
                self.workouts = workouts
                self.fetchWorkoutsForDate(Date())
            }
        }
    }

    func fetchWorkoutsForDate(_ date: Date) {
        let calendar = Calendar.current
        let selectedDay = calendar.startOfDay(for: date)
        workoutsForSelectedDate = workouts.filter {
            let workoutDay = calendar.startOfDay(for: $0.startDate)
            return workoutDay == selectedDay
        }
    }

    func addExercise(_ exercise: GymExercise, on date: Date) {
        guard let userId = Auth.auth().currentUser?.uid, !userId.isEmpty else { return }

        let dateString = dateFormatter.string(from: date)
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

    func fetchExercisesForDate(_ date: Date) {
        let dateString = dateFormatter.string(from: date)
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
                        let weight = dict["weight"] as? Int ?? 0
                        return GymExercise(name: name, muscleGroup: muscleGroup, sets: sets, repetitions: repetitions, weight: weight, date: date)
                    }
                } else {
                    self.exercises = []
                }
            } else {
                self.exercises = []
            }
        }
    }

    func fetchPredefinedExercises() {
        db.collection("predefined_exercises").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
            } else {
                if let querySnapshot = querySnapshot {
                    self.predefinedExercises = querySnapshot.documents.map { doc in
                        let data = doc.data()
                        let name = data["name"] as? String ?? "Unknown"
                        let muscleGroup = data["muscleGroup"] as? String ?? "Unknown"
                        let description = data["description"] as? String ?? ""
                        let gifName = data["gifName"] as? String ?? ""
                        return PredefinedExercise(name: name, muscleGroup: muscleGroup, description: description, gifName: gifName)
                    }
                }
            }
        }
    }
}
