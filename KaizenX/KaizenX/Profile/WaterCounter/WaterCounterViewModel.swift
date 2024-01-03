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
    
    /// Metodă pentru adăugarea cantității de apă
    func addWaterIntake(amount: Double) async {
        waterIntake += amount
        // Salvează progresul în Firestore
        try? await saveWaterIntakeToFirestore()
    }
    
    /// Salvează progresul de hidratare în Firestore
    private func saveWaterIntakeToFirestore() async throws {
        guard let userId = self.user?.userId else { return }
        let userRef = Firestore.firestore().collection("users").document(userId)
        try await userRef.setData(["waterIntake": waterIntake, "lastResetDate": Timestamp(date: Date())], merge: true)
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
                try await saveWaterIntakeToFirestore()
            }
        }
    }

    
    /// Metodă  pentru încărcarea `waterIntake` din Firestore
    func loadWaterIntake() async throws {
        guard let userId = self.user?.userId else { return }
        let userRef = Firestore.firestore().collection("users").document(userId)
        
        let document = try await userRef.getDocument()
        if let data = document.data(), let waterIntakeValue = data["waterIntake"] as? Double {
            self.waterIntake = waterIntakeValue
        } else {
            // Dacă nu există valoare salvată, setați waterIntake la 0
            self.waterIntake = 0
        }
    }


    
    /// Resetarea cantității de apă la miezul nopții sau la o anumită acțiune a utilizatorului
    func resetWaterIntake() {
      waterIntake = 0
        // Actualizează stocarea persistentă dacă este necesar
    }
    
}
