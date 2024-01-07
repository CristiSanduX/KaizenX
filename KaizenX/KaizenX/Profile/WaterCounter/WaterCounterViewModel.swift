//
//  WaterCounterViewModel.swift
//  KaizenX
//
//  Created by Cristi Sandu on 23.12.2023.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

@MainActor
final class WaterCounterViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil // Datele utilizatorului curent.
    @Published var waterIntake: Double = 0 // Cantitatea de apă consumată.
    let waterIntakeGoal: Double = 2000 // Obiectivul zilnic de hidratare în mililitri.
    
    /// Încarcă datele utilizatorului curent autentificat.
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    /// Adaugă cantitatea de apă la totalul zilnic.
    func addWaterIntake(amount: Double) async {
        waterIntake += amount
    }
    
    /// Salvează cantitatea totală de apă consumată pentru ziua curentă în Firestore.
    func saveDailyWaterIntake(amount: Double) async throws {
        guard let userId = self.user?.userId else { return }
        
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd"
        let todayString = dateFormatter.string(from: today)
        
        let dailyIntakeRef = Firestore.firestore()
                           .collection("users")
                           .document(userId)
                           .collection("daily_intakes")
                           .document(todayString)
        
        let document = try await dailyIntakeRef.getDocument()
        if let data = document.data(), let currentIntake = data["intake"] as? Double {
            let updatedIntake = currentIntake + amount
            let dailyIntakeData: [String: Any] = ["date": today, "intake": updatedIntake]
            try await dailyIntakeRef.setData(dailyIntakeData, merge: true)
        } else {
            let dailyIntakeData: [String: Any] = ["date": today, "intake": amount]
            try await dailyIntakeRef.setData(dailyIntakeData)
        }
    }
    
    /// Verifică și resetează cantitatea de apă la miezul nopții.
    func checkAndResetWaterIntake() async throws {
        guard let userId = self.user?.userId else { return }
        let userRef = Firestore.firestore().collection("users").document(userId)
        let document = try await userRef.getDocument()

        if let data = document.data(), let lastReset = data["lastResetDate"] as? Timestamp {
            let lastResetDate = lastReset.dateValue()
            let currentDate = Date()

            if !Calendar.current.isDate(lastResetDate, inSameDayAs: currentDate) {
                waterIntake = 0
            }
        }
    }

    /// Încarcă cantitatea de apă consumată pentru ziua curentă.
    func loadTodayWaterIntake() async throws {
        guard let userId = self.user?.userId else { return }
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd"
        let todayString = dateFormatter.string(from: today)
        
        let userRef = Firestore.firestore()
                       .collection("users")
                       .document(userId)
                       .collection("daily_intakes")
                       .document(todayString)
        
        let document = try await userRef.getDocument()
        if let data = document.data(), let waterIntakeValue = data["intake"] as? Double {
            self.waterIntake = waterIntakeValue
        }
    }
}
