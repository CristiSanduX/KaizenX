//
//  ProfileViewModel.swift
//  KaizenX
//
//  Created by Cristi Sandu on 22.11.2023.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

/// ViewModel pentru ProfileView. Gestionează încărcarea și stocarea datelor profilului utilizatorului.
@MainActor
final class ProfileViewModel: ObservableObject {
    
    // Proprietatea Published stochează datele utilizatorului. Aceasta este accesibilă doar pentru citire în afara clasei.
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var steps: Double = 0
    
    // Adaugă proprietăți pentru a stoca apa consumată și obiectivul
    @Published var waterIntake: Double = 0
    let waterIntakeGoal: Double = 2000 // în mililitri, echivalent cu 2L
    
    /// Încarcă datele utilizatorului curent autentificat.
    func loadCurrentUser() async throws {
        // Obține datele utilizatorului autentificat de la AuthenticationManager.
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        
        // Preia datele utilizatorului din Firestore folosind UserManager.
        let user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        self.user = user
    }
    
    /// Solicită autorizația și încarcă numărul de pași de la HealthKit.
    func loadSteps() {
        HealthKitManager.shared.requestAuthorization { [weak self] success in
            guard success else { return }
            HealthKitManager.shared.fetchSteps { steps in
                DispatchQueue.main.async {
                    self?.steps = steps
                }
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
    
    /// Încarcă o imagine nouă în Firebase Storage și actualizează Firestore.
    func uploadImageToStorage(_ image: UIImage) async throws {
        guard let imageData = image.jpegData(compressionQuality: 0.5),
              let userId = self.user?.userId else {
            throw NSError(domain: "com.kaizenX", code: -1, userInfo: [NSLocalizedDescriptionKey: "Nu s-au putut prelua informațiile utilizatorului sau converti imaginea."])
        }
        
        let storageRef = Storage.storage().reference(withPath: "user_photos/\(userId).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Încarcă imaginea în Firebase Storage
        let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        // Preia URL-ul noii imagini încărcate
        let newPhotoURL = try await storageRef.downloadURL()
        // Actualizează Firestore cu noul URL al imaginii
        try await updateUserPhotoURL(newPhotoURL, userId: userId)
        // Actualizează UI-ul cu noul URL al imaginii
        DispatchQueue.main.async {
            self.user?.photoURL = newPhotoURL.absoluteString
        }
    }
    
    /// Actualizează URL-ul fotografiei utilizatorului în Firestore.
    func updateUserPhotoURL(_ url: URL, userId: String) async throws {
        let userRef = Firestore.firestore().collection("users").document(userId)
        try await userRef.setData(["photo_url": url.absoluteString], merge: true)
    }
}
