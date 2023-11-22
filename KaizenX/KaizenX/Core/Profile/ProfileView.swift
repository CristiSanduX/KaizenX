//
//  ProfileView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 22.11.2023.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user:AuthDataResultModel? = nil
    
    func loadCurrentUser() throws {
        self.user = try
        AuthenticationManager.shared.getAuthenticatedUser()
    }
    
}

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInview: Bool
    
    var body: some View {
        List{
            if let user = viewModel.user {
                Text("UserID: \(user.uid)")
            }
        }
        .onAppear {
           try? viewModel.loadCurrentUser()
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView(showSignInview: $showSignInview)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
                    
            }
        }
    }
}

#Preview {
    NavigationStack{
        ProfileView(showSignInview: .constant(false))
    }
}
