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
        }
        .navigationTitle("Settings")
    }
}


#Preview {
    NavigationStack {
        SettingsView(showSignInview: .constant(false))
    }
}
