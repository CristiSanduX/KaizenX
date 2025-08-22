//
//  SignInEmailViewModel.swift
//  KaizenX
//
//  Created by Cristi Sandu on 22.11.2023.
//

import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit

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
    private var currentNonce: String?

    @MainActor
    func signInWithApple() async {
        do {
            let helper = SignInWithAppleHelper()
            let (idToken, appleCred, nonce) = try await helper.start()

            let credential = OAuthProvider.appleCredential(
                withIDToken: idToken,        // String din ASAuthorizationAppleIDCredential.identityToken
                rawNonce: nonce,             // nonce-ul tău
                fullName: appleCred.fullName // poți da nil dacă nu-ți trebuie numele
            )

            let result = try await Auth.auth().signIn(with: credential)
            let authModel = AuthDataResultModel(user: result.user)
            try? await UserManager.shared.createNewUser(auth: authModel)

            isSignedIn = true
            errorMessage = nil
        } catch {
            isSignedIn = false
            errorMessage = error.localizedDescription
        }
    }


        // MARK: - Nonce helpers
        private func sha256(_ input: String) -> String {
            let inputData = Data(input.utf8)
            let hashed = SHA256.hash(data: inputData)
            return hashed.compactMap { String(format: "%02x", $0) }.joined()
        }
        private func randomNonceString(length: Int = 32) -> String {
            let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
            var result = ""; var remaining = length
            while remaining > 0 {
                var bytes = [UInt8](repeating: 0, count: 16)
                let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
                if status != errSecSuccess { fatalError("Unable to generate nonce") }
                bytes.forEach { byte in
                    if remaining == 0 { return }
                    if byte < charset.count { result.append(charset[Int(byte)]); remaining -= 1 }
                }
            }
            return result
        }
    
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
        if let authError = error as NSError?, let errorCode = AuthErrorCode(rawValue: authError.code) {
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


// mic bridge pt ASAuthorizationControllerDelegate
final class ASAuthorizationDelegateBridge: NSObject, ASAuthorizationControllerDelegate {
    private let onToken: (String) -> Void
    init(onToken: @escaping (String) -> Void) { self.onToken = onToken }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8) else { return }
        onToken(idToken)
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("SIWA error:", error.localizedDescription)
    }
}


final class SignInWithAppleHelper: NSObject,
  ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

  private var continuation: CheckedContinuation<(String, ASAuthorizationAppleIDCredential, String), Error>?
  private var currentNonce: String?

  func start() async throws -> (String, ASAuthorizationAppleIDCredential, String) {
    let nonce = randomNonceString()
    currentNonce = nonce

    let req = ASAuthorizationAppleIDProvider().createRequest()
    req.requestedScopes = [.fullName, .email]
    req.nonce = sha256(nonce)

    let controller = ASAuthorizationController(authorizationRequests: [req])
    controller.delegate = self
    controller.presentationContextProvider = self

    return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<(String, ASAuthorizationAppleIDCredential, String), Error>) in
      self.continuation = cont
      controller.performRequests()
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    guard let cred = authorization.credential as? ASAuthorizationAppleIDCredential,
          let tokenData = cred.identityToken,
          let idToken = String(data: tokenData, encoding: .utf8),
          let nonce = currentNonce else {
      continuation?.resume(throwing: NSError(domain: "SIWA", code: -1))
      return
    }
    continuation?.resume(returning: (idToken, cred, nonce))
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    continuation?.resume(throwing: error)
  }

  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    // ancoră sigură pentru iOS 15+
    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let win = scene.windows.first(where: { $0.isKeyWindow }) { return win }
    return ASPresentationAnchor()
  }

    // MARK: - Nonce utils
    private func sha256(_ input: String) -> String {
        let hashed = SHA256.hash(data: Data(input.utf8))
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    private func randomNonceString(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""; var remaining = length
        while remaining > 0 {
            var bytes = [UInt8](repeating: 0, count: 16)
            _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
            for b in bytes where remaining > 0 {
                if b < charset.count { result.append(charset[Int(b)]); remaining -= 1 }
            }
        }
        return result
    }
}
