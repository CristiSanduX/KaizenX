//
//  SignInEmailViewModel.swift
//  KaizenX
//
//  Created by Cristi Sandu pe 22.11.2023.
//

import Foundation
import FirebaseAuth

/// ViewModel-ul pentru SignInEmailView, gestionează logica de autentificare prin email și Google
@MainActor  // Asigură că actualizările UI se fac pe thread-ul principal
final class SignInEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isPasswordVisible = false  // Controlează vizibilitatea textului în câmpul parolei
    @Published var isEmailValid = true  // Controlează validitatea email-ului
    @Published var isPasswordValid = true  // Controlează validitatea parolei
    @Published var errorMessage: String?  // Mesajul de eroare pentru autentificare
    @Published var showResetPasswordAlert = false  // Controlează afișarea alertei pentru resetarea parolei
    @Published var isSignedIn = false  // Controlează starea autentificării utilizatorului
    
    /// Încearcă să autentifice utilizatorul cu email-ul și parola introduse
    func signIn() async {
        print("signIn - început")
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "E-mail sau parolă lipsă"
            return
        }
        
        do {
            try await AuthenticationManager.shared.signInUser(email: email, password: password)
            isSignedIn = true  // Setăm starea autentificării la true dacă autentificarea reușește
        } catch {
            errorMessage = handleAuthError(error)
            isSignedIn = false  // Setăm starea autentificării la false dacă există o eroare
        }
    }
    
    /// Încearcă să autentifice utilizatorul prin Google și să creeze un nou utilizator în baza de date, dacă este necesar
    func signInGoogle() async {
        do {
            let helper = SignInGoogleHelper()
            let tokens = try await helper.signIn()
            let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
            try await UserManager.shared.createNewUser(auth: authDataResult)
            isSignedIn = true 
        } catch {
            errorMessage = handleAuthError(error)
            isSignedIn = false
        }
    }
    
    /// Validează formatul email-ului
    func validateEmail() {
        isEmailValid = email.contains("@") && email.contains(".")
    }
    
    /// Validează lungimea parolei
    func validatePassword() {
        isPasswordValid = password.count >= 6
    }
    
    /// Trimite o cerere de resetare a parolei
    func resetPassword() async {
        guard !email.isEmpty else {
            errorMessage = "Introduceți adresa de e-mail."
            return
        }
        
        do {
            try await AuthenticationManager.shared.resetPassword(email: email)
            errorMessage = "E-mail-ul de resetare a parolei trimis."
        } catch {
            errorMessage = handleAuthError(error)
        }
    }
    
    /// Gestionarea erorilor de autentificare
    private func handleAuthError(_ error: Error) -> String {
        if let authError = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: authError.code) {
            switch errorCode {
            case .invalidEmail:
                return "Adresa de e-mail este invalidă."
            case .wrongPassword:
                return "Parola introdusă este incorectă."
            case .userNotFound:
                return "Nu există un utilizator cu această adresă de e-mail."
            case .userDisabled:
                return "Acest cont a fost dezactivat."
            case .emailAlreadyInUse:
                return "Această adresă de e-mail este deja folosită."
            case .weakPassword:
                return "Parola trebuie să aibă cel puțin 6 caractere."
            case .tooManyRequests:
                return "Prea multe încercări de autentificare. Vă rugăm să încercați din nou mai târziu."
            default:
                return "A apărut o eroare neașteptată. Vă rugăm să încercați din nou."
            }
        }
        return "A apărut o eroare necunoscută. Vă rugăm să încercați din nou."
    }
}
