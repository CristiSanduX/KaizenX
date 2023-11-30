//
//  SignInEmailView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 02.11.2023.
//

import SwiftUI

/// Ecranul de înregistrare care permite utilizatorilor să creeze un cont nou,
struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            // Câmpul pentru introducerea email-ului.
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            // Câmpurile pentru introducerea și confirmarea parolei.
            SecureField("Parolă...", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            SecureField("Confirmă parola...", text: $viewModel.confirmPassword)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            // Butonul de înregistrare.
            Button {
                Task {
                    let signUpSuccess = await viewModel.signUp()
                    if signUpSuccess {
                        showSignInView = false
                    }
                }
            } label: {
                Text("Creează cont")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color.darkRed)
                    .cornerRadius(12)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Creează un cont nou")
    }
}

#Preview {
    NavigationStack{
        SignUpView(showSignInView: .constant(true))
    }
}
