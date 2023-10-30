//
//  SettingsView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 30.10.2023.
//



import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    func signOut() throws{
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws{
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else{
            throw URLError(.fileDoesNotExist)
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
}

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
        }
        .navigationTitle("Settings")
    }
}


#Preview {
    NavigationStack {
        SettingsView(showSignInview: .constant(false))
    }
}
