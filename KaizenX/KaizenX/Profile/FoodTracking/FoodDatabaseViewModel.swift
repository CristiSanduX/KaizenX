//
//  FoodDatabaseViewModel.swift
//  KaizenX
//
//  Created by Cristi Sandu on 17.01.2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct FoodItem: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    var name: String
    var caloriesPer100g: Double
    var proteinPer100g: Double
    var carbsPer100g: Double
    var fatsPer100g: Double
    var saturatedFatsPer100g: Double
    var glucidesPer100g: Double
    var fibersPer100g: Double
}


@MainActor
class FoodDatabaseViewModel: ObservableObject {
    @Published var savedFoods: [FoodItem] = []
    
    private var db = Firestore.firestore()
    private let userId = Auth.auth().currentUser?.uid ?? ""

    func fetchSavedFoods() async {
        guard !userId.isEmpty else { return }
        let foodsRef = db.collection("users").document(userId).collection("saved_foods")

        do {
            let snapshot = try await foodsRef.getDocuments()
            self.savedFoods = snapshot.documents.compactMap { doc in
                try? doc.data(as: FoodItem.self)
            }
        } catch {
            print("Eroare la încărcarea produselor: \(error.localizedDescription)")
        }
    }

    func addNewFood(_ food: FoodItem) async {
        guard !userId.isEmpty else {
            print("❌ Eroare: User ID gol!")
            return
        }

        let foodRef = db.collection("users").document(userId).collection("saved_foods").document(food.id ?? UUID().uuidString)

        let foodData: [String: Any] = [
            "name": food.name,
            "caloriesPer100g": food.caloriesPer100g.rounded(toPlaces: 1),
            "proteinPer100g": food.proteinPer100g.rounded(toPlaces: 1),
            "carbsPer100g": food.carbsPer100g.rounded(toPlaces: 1),
            "fatsPer100g": food.fatsPer100g.rounded(toPlaces: 1),
            "saturatedFatsPer100g": food.saturatedFatsPer100g.rounded(toPlaces: 1),
            "glucidesPer100g": food.glucidesPer100g.rounded(toPlaces: 1),
            "fibersPer100g": food.fibersPer100g.rounded(toPlaces: 1)
        ]

        do {
            try await foodRef.setData(foodData)
            print("✅ Produs salvat cu succes în Firestore!")
            await fetchSavedFoods()
        } catch {
            print("❌ Eroare Firestore: \(error.localizedDescription)")
        }
    }


}
