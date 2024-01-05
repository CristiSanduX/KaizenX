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
    
    @Published private(set) var user: DBUser? = nil
    
    // Adaugă proprietăți pentru a stoca ap consumată și obiectivul
    @Published var waterIntake: Double = 0
    let waterIntakeGoal: Double = 2000 // în mililitri, echivalent cu 2L
    
    /// Încarcă datele utilizatorului curent autentificat.
    func loadCurrentUser() async throws {
        // Obține datele utilizatorului autentificat de la AuthenticationManager.
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        
        // Preia datele utilizatorului din Firestore folosind UserManager.
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    /// Metodă pentru adăugarea cantității de apă și salvarea în Firestore.
    func addWaterIntake(amount: Double) async {
        // Adaugă cantitatea în suma totală pentru ziua curentă
        waterIntake += amount

        // Salvează progresul în Firestore pentru ziua curentă
        do {
            try await saveDailyWaterIntake(amount: amount)
        } catch {
            print("Eroare la salvarea cantității de apă: \(error)")
        }
    }
    
    
    
    /// Salvează cantitatea de apă consumată pentru ziua curentă în Firestore.
    func saveDailyWaterIntake(amount: Double) async throws {
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
        
        let dailyIntakeData = ["date": today, "intake": amount] as [String : Any]
        try await userRef.setData(dailyIntakeData, merge: true)
    }

    
    
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


    
    /// Resetarea cantității de apă la miezul nopții sau la o anumită acțiune a utilizatorului
    func resetWaterIntake() {
      waterIntake = 0
        // Actualizează stocarea persistentă dacă este necesar
    }
    
}
