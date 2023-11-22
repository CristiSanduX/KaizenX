//
//  SettingsView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 30.10.2023.
//



import SwiftUI



struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInview: Bool
    var body: some View {
        List {
            Button("Log out") {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInview = true
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button(role: .destructive) {
                Task {
                    do {
                        try await viewModel.deleteAccount()
                        showSignInview = true
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
            viewModel.loadAuthProviders()
        }
        .navigationTitle("Settings")
    }
}


#Preview {
    NavigationStack {
        SettingsView(showSignInview: .constant(false))
    }
}
