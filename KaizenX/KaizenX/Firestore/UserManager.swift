import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBUser {
    let userId: String
    let email: String?
    var photoURL: String?
    let dateCreated: Date?
}

/// `UserManager` este un singleton care gestionează operațiunile legate de utilizatorii aplicației în Firestore.
final class UserManager {
    
    /// Singleton instance pentru acces global.
    static let shared = UserManager()
    
    /// Constructorul privat previne instantierea directă și asigură că `UserManager` rămâne un singleton.
    private init() {}
    
    /// Creează un nou document utilizator în Firestore cu datele furnizate de modelul `AuthDataResultModel`.
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
