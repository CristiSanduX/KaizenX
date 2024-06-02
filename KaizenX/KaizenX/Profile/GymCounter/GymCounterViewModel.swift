import Foundation
import FirebaseFirestore
import Firebase




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
    @Published var muscleGroups: [String] = ["Piept", "Spate", "Brațe", "Picioare", "Umeri/Trapez", "Abdomen"]
    @Published var selectedMuscleGroup: String = "Piept"
    @Published var exercises: [GymExercise] = []
    
    @Published var predefinedExercises: [PredefinedExercise] = [
        PredefinedExercise(name: "Flotări", muscleGroup: "Piept", description: "Execuția flotărilor corecte implică menținerea spatelui drept și coborârea corpului până când pieptul aproape atinge solul.", gifName: "flotari"),
        PredefinedExercise(name: "Genuflexiuni", muscleGroup: "Picioare", description: "Menține spatele drept și coboară șoldurile până când coapsele sunt paralele cu solul.", gifName: "genuflexiuni"),
        PredefinedExercise(name: "Împins la piept cu bara", muscleGroup: "Piept", description: "Împinge bara în sus până când brațele sunt complet extinse și revino încet la poziția inițială.", gifName: "impins_piept_bara"),
        PredefinedExercise(name: "Tracțiuni", muscleGroup: "Spate", description: "Apucă bara cu palmele în față și trage-te în sus până când bărbia trece de bară.", gifName: "tractiuni"),
        PredefinedExercise(name: "Ridicări laterale", muscleGroup: "Umeri/Trapez", description: "Ridică ganterele lateral până la nivelul umerilor, menținând brațele drepte.", gifName: "ridicari_laterale"),
        PredefinedExercise(name: "Biceps curl cu bara", muscleGroup: "Brațe", description: "Ridică bara spre umeri, menținând coatele lipite de corp.", gifName: "biceps_curl_bara"),
        PredefinedExercise(name: "Extensii triceps la scripete", muscleGroup: "Brațe", description: "Împinge scripetele în jos până când brațele sunt complet extinse.", gifName: "extensii_triceps_scripete"),
        PredefinedExercise(name: "Fandări", muscleGroup: "Picioare", description: "Fă un pas mare înainte și coboară corpul până când genunchiul din spate aproape atinge solul.", gifName: "fandari"),
        PredefinedExercise(name: "Presa pentru picioare", muscleGroup: "Picioare", description: "Împinge platforma aparatului cu picioarele până când genunchii sunt aproape extinși.", gifName: "presa_picioare"),
        PredefinedExercise(name: "Ramat cu bara", muscleGroup: "Spate", description: "Trage bara spre abdomen, menținând spatele drept și coatele aproape de corp.", gifName: "ramat_bara"),
        PredefinedExercise(name: "Ridicări pe vârfuri", muscleGroup: "Picioare", description: "Ridică-te pe vârfuri și revino încet la poziția inițială.", gifName: "ridicari_varfuri"),
        PredefinedExercise(name: "Abdomene", muscleGroup: "Abdomen", description: "Ridică trunchiul spre genunchi, menținând picioarele fixe.", gifName: "abdomene"),
        PredefinedExercise(name: "Flexii biceps cu gantere", muscleGroup: "Brațe", description: "Ridică ganterele spre umeri, menținând coatele fixe.", gifName: "flexii_biceps_ganter"),
        PredefinedExercise(name: "Împins la umeri cu gantere", muscleGroup: "Umeri/Trapez", description: "Împinge ganterele în sus până când brațele sunt complet extinse.", gifName: "impins_umeri_ganter"),
        PredefinedExercise(name: "Plank", muscleGroup: "Abdomen", description: "Menține corpul drept și sprijinit pe antebrațe și degetele de la picioare.", gifName: "plank"),
        PredefinedExercise(name: "Crunch-uri inversate", muscleGroup: "Abdomen", description: "Ridică șoldurile de pe sol, aducând genunchii spre piept.", gifName: "crunch_inversat"),
        PredefinedExercise(name: "Pull-over cu gantera", muscleGroup: "Piept", description: "Întinde-te pe o bancă, ține gantera cu ambele mâini și ridic-o deasupra capului, apoi revino la poziția inițială.", gifName: "pull_over_gantera"),
        PredefinedExercise(name: "Îndreptări", muscleGroup: "Spate", description: "Ridică bara de la sol până când corpul este complet drept, menținând spatele drept.", gifName: "indreptari"),
        PredefinedExercise(name: "Flotări la paralele", muscleGroup: "Piept", description: "Coborâ-te până când brațele sunt la un unghi de 90 de grade, apoi împinge-te înapoi.", gifName: "flotari_paralele"),
        PredefinedExercise(name: "Ridicări de umeri cu bara", muscleGroup: "Umeri/Trapez", description: "Ridică bara prin contractarea umerilor, menținând brațele drepte.", gifName: "ridicari_umeri_bara"),
        PredefinedExercise(name: "Presa pentru umeri", muscleGroup: "Umeri/Trapez", description: "Împinge greutățile în sus până când brațele sunt complet extinse.", gifName: "presa_umeri"),
        PredefinedExercise(name: "Flexii hamstrings la aparat", muscleGroup: "Picioare", description: "Coboară platforma aparatului prin flexarea genunchilor.", gifName: "flexii_hamstrings_aparat")
    ]

    
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
                        let weight = dict["weight"] as? Int ?? 0
                        return GymExercise(name: name, muscleGroup: muscleGroup, sets: sets, repetitions: repetitions, weight: weight, date: Date())
                    }
                }
            } else {
                self.exercises = []
            }
        }
    }
}




