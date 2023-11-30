//
//  RootView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 25.11.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/// Structura pentru modelul utilizatorului din baza de date.
struct DBUser {
    let userId: String
    let email: String?
    var photoURL: String?
    let dateCreated: Date?
}

/// `UserManager` gestionează operațiunile legate de utilizatorii aplicației în baza de date Firestore.
final class UserManager {
    
    /// Singleton instance pentru acces global.
    static let shared = UserManager()
    
    /// Constructorul privat previne instantierea directă.
    private init() {}
    
    /// Creează un nou document utilizator în Firestore dacă acesta nu există.
    /// - Parameter auth: Modelul cu datele de autentificare ale utilizatorului.
    func createNewUser(auth: AuthDataResultModel) async throws {
        
        let userRef = Firestore.firestore().collection("users").document(auth.uid)
        let document = try await userRef.getDocument()
        
        if !document.exists {
            
            // Inițializarea dicționarului care va stoca datele utilizatorului pentru Firestore.
            var userData: [String:Any] = [
                "user_id": auth.uid, // Identificatorul unic al utilizatorului.
                "date_created": Timestamp(),
            ]
            
            // Adaugă email-ul utilizatorului dacă este disponibil.
            if let email = auth.email {
                userData["email"] = email
            }
            
            // Adaugă URL-ul foto al utilizatorului dacă este disponibil.
            if let photoURL = auth.photoURL {
                userData["photo_url"] = photoURL
            }
            
            // Încercăm să salvăm datele utilizatorului în Firestore în colecția 'users'.
            try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
        }
    }
    
    /// Preia informațiile utilizatorului din Firestore.
    /// - Parameter userId: Identificatorul unic al utilizatorului.
    /// - Returns: O instanță `DBUser` cu datele utilizatorului.
    func getUser(userId: String) async throws -> DBUser{
        let snapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
        
        guard let data = snapshot.data(), let userId = data["user_id"] as? String else{
            throw URLError(.badServerResponse)
        }
        
        let email = data["email"] as? String
        let photoURL = data["photo_url"] as? String
        let dateCreated = data["date_created"] as? Date
        
        return DBUser(userId: userId, email: email, photoURL: photoURL, dateCreated: dateCreated)
    }
}
