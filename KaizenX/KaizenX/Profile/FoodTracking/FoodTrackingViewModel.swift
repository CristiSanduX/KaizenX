//
//  FoodTrackingViewModel.swift
//  KaizenX
//
//  Created by Cristi Sandu on 17.01.2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct FoodEntry: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var calories: Int
    var protein: Int
    var carbs: Int
    var fats: Int
    var saturatedFats: Int
    var glucides: Int
    var fibers: Int
}

@MainActor
class FoodTrackingViewModel: ObservableObject {
    @Published var foods: [FoodEntry] = []
    @Published var totalCalories: Int = 0
    @Published var totalProtein: Int = 0
    @Published var totalCarbs: Int = 0
    @Published var totalFats: Int = 0
    @Published var totalSaturatedFats: Int = 0
    @Published var totalGlucides: Int = 0
    @Published var totalFibers: Int = 0

    private var db = Firestore.firestore()
    private let userId = Auth.auth().currentUser?.uid ?? ""

    func fetchDailyFoodEntries(for date: String) async {
        guard !userId.isEmpty else { return }

        let foodRef = db.collection("users").document(userId).collection("daily_food_entries").document(date)

        do {
            let snapshot = try await foodRef.getDocument()
            if let data = snapshot.data() {
                self.totalCalories = data["total_calories"] as? Int ?? 0
                self.totalProtein = data["total_protein"] as? Int ?? 0
                self.totalCarbs = data["total_carbs"] as? Int ?? 0
                self.totalFats = data["total_fats"] as? Int ?? 0
                self.totalSaturatedFats = data["total_saturated_fats"] as? Int ?? 0
                self.totalGlucides = data["total_glucides"] as? Int ?? 0
                self.totalFibers = data["total_fibers"] as? Int ?? 0

                if let foodList = data["foods"] as? [[String: Any]] {
                    self.foods = foodList.map { dict in
                        FoodEntry(
                            id: dict["id"] as? String ?? UUID().uuidString,
                            name: dict["name"] as? String ?? "",
                            calories: dict["calories"] as? Int ?? 0,
                            protein: dict["protein"] as? Int ?? 0,
                            carbs: dict["carbs"] as? Int ?? 0,
                            fats: dict["fats"] as? Int ?? 0,
                            saturatedFats: dict["saturated_fats"] as? Int ?? 0,
                            glucides: dict["glucides"] as? Int ?? 0,
                            fibers: dict["fibers"] as? Int ?? 0
                        )
                    }
                }
            }
        } catch {
            print("Eroare la încărcarea alimentelor: \(error.localizedDescription)")
        }
    }

    func addFoodEntry(_ food: FoodEntry, for date: String) async {
        guard !userId.isEmpty else { return }

        let foodRef = db.collection("users").document(userId).collection("daily_food_entries").document(date)

        do {
            try await db.runTransaction { transaction, errorPointer in
                let snapshot: DocumentSnapshot
                do {
                    snapshot = try transaction.getDocument(foodRef)
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }

                var existingFoods = snapshot.data()?["foods"] as? [[String: Any]] ?? []
                
                let newFoodData: [String: Any] = [
                    "id": food.id,
                    "name": food.name,
                    "calories": food.calories,
                    "protein": food.protein,
                    "carbs": food.carbs,
                    "fats": food.fats,
                    "saturated_fats": food.saturatedFats,
                    "glucides": food.glucides,
                    "fibers": food.fibers
                ]
                existingFoods.append(newFoodData)

                let updatedData: [String: Any] = [
                    "foods": existingFoods,
                    "total_calories": (snapshot.data()?["total_calories"] as? Int ?? 0) + food.calories,
                    "total_protein": (snapshot.data()?["total_protein"] as? Int ?? 0) + food.protein,
                    "total_carbs": (snapshot.data()?["total_carbs"] as? Int ?? 0) + food.carbs,
                    "total_fats": (snapshot.data()?["total_fats"] as? Int ?? 0) + food.fats,
                    "total_saturated_fats": (snapshot.data()?["total_saturated_fats"] as? Int ?? 0) + food.saturatedFats,
                    "total_glucides": (snapshot.data()?["total_glucides"] as? Int ?? 0) + food.glucides,
                    "total_fibers": (snapshot.data()?["total_fibers"] as? Int ?? 0) + food.fibers
                ]

                transaction.setData(updatedData, forDocument: foodRef, merge: true)
                return nil
            }
            await fetchDailyFoodEntries(for: date)
        } catch {
            print("Eroare la adăugarea alimentului: \(error.localizedDescription)")
        }
    }

    
}
