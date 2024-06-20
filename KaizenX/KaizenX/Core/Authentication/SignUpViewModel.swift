
//
//  SignUpViewModel.swift
//  KaizenX
//
//  Created by Cristi Sandu pe 22.11.2023.
//

import Foundation
import FirebaseAuth

/// ViewModel care susține logica pentru SignUpView
@MainActor
final class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isPasswordVisible = false
    @Published var isEmailValid = true
    @Published var isPasswordValid = true
    @Published var doPasswordsMatch = true
    @Published var errorMessage: String?
    
    /// Încearcă să creeze un cont nou cu email-ul și parola introduse
    func signUp() async -> Bool {
        print("signUp - început")
        guard validateInputs() else {
            return false
        }
        
        do {
            // Încearcă să creeze un utilizator nou în AuthenticationManager
            let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
            // Dacă a reușit crearea, înregistrează utilizatorul nou în UserManager
            try await UserManager.shared.createNewUser(auth: authDataResult)
            // Trimite email de verificare
            try await sendEmailVerification()
            return true
        } catch {
            errorMessage = handleAuthError(error)
            return false
        }
    }
    
    /// Trimite email de verificare
    private func sendEmailVerification() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.sendEmailVerification()
    }
    
    /// Validează formatul email-ului
    func validateEmail() {
        isEmailValid = email.contains("@") && email.contains(".")
    }
    
    /// Validează lungimea parolei
    func validatePassword() {
        isPasswordValid = password.count >= 6
    }
    
    /// Validează dacă parolele coincid
    func validateConfirmPassword() {
        doPasswordsMatch = password == confirmPassword
    }
    
    /// Validează toate input-urile
    private func validateInputs() -> Bool {
        validateEmail()
        validatePassword()
        validateConfirmPassword()
        
        if email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            errorMessage = "E-mail, parolă sau confirmarea parolei lipsesc."
            return false
        }
        
        if !isEmailValid || !isPasswordValid || !doPasswordsMatch {
            errorMessage = "Vă rugăm să corectați erorile."
            return false
        }
        
        return true
    }
    
    /// Gestionarea erorilor de autentificare
    private func handleAuthError(_ error: Error) -> String {
        if let authError = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: authError.code) {
            switch errorCode {
            case .invalidEmail:
                return "Adresa de e-mail este invalidă."
            case .emailAlreadyInUse:
                return "Această adresă de e-mail este deja folosită."
            case .weakPassword:
                return "Parola trebuie să aibă cel puțin 6 caractere."
            default:
                return "A apărut o eroare neașteptată. Vă rugăm să încercați din nou."
            }
        }
        return "A apărut o eroare necunoscută. Vă rugăm să încercați din nou."
    }
}
