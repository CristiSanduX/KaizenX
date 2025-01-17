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
    var id: String = UUID().uuidString
    var name: String
    var caloriesPer100g: Int
    var proteinPer100g: Int
    var carbsPer100g: Int
    var fatsPer100g: Int
    var saturatedFatsPer100g: Int
    var glucidesPer100g: Int
    var fibersPer100g: Int
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
        guard !userId.isEmpty else { return }
        let foodRef = db.collection("users").document(userId).collection("saved_foods").document(food.id)

        do {
            try await foodRef.setData(from: food)
            await fetchSavedFoods()
        } catch {
            print("Eroare la adăugarea produsului: \(error.localizedDescription)")
        }
    }
}
