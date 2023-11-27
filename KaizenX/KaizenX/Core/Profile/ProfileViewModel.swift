//
//  ProfileViewModel.swift
//  KaizenX
//
//  Created by Cristi Sandu on 26.11.2023.
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
    
    /// Încarcă datele utilizatorului curent autentificat.
    func loadCurrentUser() async throws {
        // Obține datele utilizatorului autentificat de la AuthenticationManager.
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        
        // Preia datele utilizatorului din Firestore folosind UserManager.
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
}



extension ProfileViewModel {

    func uploadImageToStorage(_ image: UIImage) async throws {
        guard let imageData = image.jpegData(compressionQuality: 0.5),
              let userId = self.user?.userId else {
            throw NSError(domain: "com.kaizenX", code: -1, userInfo: [NSLocalizedDescriptionKey: "Nu s-a putut prelua informațiile utilizatorului sau converti imaginea."])
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
    
    func updateUserPhotoURL(_ url: URL, userId: String) async throws {
        let userRef = Firestore.firestore().collection("users").document(userId)
        try await userRef.setData(["photo_url": url.absoluteString], merge: true)
    }
}
