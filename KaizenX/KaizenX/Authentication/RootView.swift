//
//  RootView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 30.10.2023.
//

// Afișare AuthenticationView sau SettingsView pe baza stării autentificării unui utilizator.
import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false;
    
    var body: some View {
        ZStack {
            NavigationStack {
                SettingsView(showSignInview: $showSignInView)
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
    }
}

#Preview {
    RootView()
}
