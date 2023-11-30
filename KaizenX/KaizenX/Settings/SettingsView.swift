//
//  SettingsView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 30.10.2023.
//

import SwiftUI

/// SettingsView reprezintă ecranul de setări unde utilizatorii pot modifica detaliile contului și se pot deconecta.
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInview: Bool  // Această variabilă decide dacă ecranul de autentificare trebuie afișat.
    
    var body: some View {
        List {
            Button("Log out") {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInview = true  // Deconectează utilizatorul și afișează ecranul de autentificare.
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button(role: .destructive) {
                Task {
                    do {
                        try await viewModel.deleteAccount()
                        showSignInview = true  // Șterge contul și afișează ecranul de autentificare.
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Ștergere cont")
            }
            
            
            if viewModel.authProviders.contains(.email) {
                
                Section {
                    Button("Reset password") {
                        Task {
                            do {
                                try await viewModel.resetPassword()
                                print("Password reset!")
                            } catch {
                                print(error)
                            }
                        }
                    }
                    
                    Button("Update password") {
                        Task {
                            do {
                                try await viewModel.updatePassword()
                                print("Password update!")
                            } catch {
                                print(error)
                            }
                        }
                    }
                    Button("Update email") {
                        Task {
                            do {
                                try await viewModel.updateEmail()
                                print("Email update!")
                            } catch {
                                print(error)
                            }
                        }
                    }
                } header: {
                    Text("Email functions")
                }
            }
        }
        .onAppear {
            viewModel.loadAuthProviders() // Încarcă furnizorii de autentificare la apariția view-ului.
        }
        .navigationTitle("Settings")
    }
}


#Preview {
    NavigationStack {
        SettingsView(showSignInview: .constant(false))
    }
}
