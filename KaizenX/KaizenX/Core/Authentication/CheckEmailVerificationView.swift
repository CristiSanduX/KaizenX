//
//  CheckEmailVerificationView.swift
//  KaizenX
//
//  Created by Cristi Sandu pe 20.06.2024.
//

import SwiftUI
import FirebaseAuth

/// Ecranul pentru verificarea email-ului
struct CheckEmailVerificationView: View {
    @State private var isEmailVerified = false
    @State private var errorMessage: String?
    @Binding var showSignInView: Bool 
    
    var body: some View {
        VStack {
            if isEmailVerified {
                Text("E-mail verificat!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding(.bottom, 20)
                Text("Veți fi redirecționat către pagina principală...")
                    .font(.body)
                    .foregroundColor(.gray)
            } else {
                Text("Verificați email-ul")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.bottom, 20)

                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    Task {
                        await checkEmailVerification()
                    }
                }) {
                    Text("Am verificat, continuă")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.darkRed)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
        }
        .padding()
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .onAppear {
            Task {
                await checkEmailVerification()
            }
        }
    }
    
    private func checkEmailVerification() async {
        do {
            try await Auth.auth().currentUser?.reload()
            if Auth.auth().currentUser?.isEmailVerified == true {
                isEmailVerified = true
                // Așteaptă 2 secunde înainte de redirecționare
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    // Redirecționare către pagina principală
                    showSignInView = false
                }
            } else {
                errorMessage = "Adresa de email nu a fost verificată încă. Vă rugăm să verificați din nou."
            }
        } catch {
            errorMessage = "A apărut o eroare la verificarea adresei de email: \(error.localizedDescription)"
        }
    }
}

#Preview {
    CheckEmailVerificationView(showSignInView: .constant(true))
}
