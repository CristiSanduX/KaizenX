//
//  SignInEmailView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 25.10.2023.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct SignInEmailView: View {
    
    // Instanțiem clasa
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    var body: some View {
        VStack {
            TextField("Email...",text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            HStack {
                if viewModel.isPasswordVisible {
                    TextField("Password...", text: $viewModel.password)
                } else {
                    SecureField("Password...", text: $viewModel.password)
                        
                }
                
                Button(action: {
                    viewModel.isPasswordVisible.toggle()
                }, label: {
                    Image(systemName: viewModel.isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                })
            }
            .padding()
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)

            
            Button {
                Task {
                    do {
                        try await viewModel.signIn()
                        showSignInView = false
                        return
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color.darkRed)
                    .cornerRadius(12)
            }
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                }
            }

            
            NavigationLink(destination: SignUpView(showSignInView: $showSignInView)) {
                            Text("Nu ai cont? Creează unul nou")
                        }
                        .padding(.top, 20)
            
            Spacer()
            
        }
        .padding()
        .navigationTitle("Logare")
    }
}

#Preview {
    NavigationStack{
        SignInEmailView(showSignInView: .constant(true))
    }
}
