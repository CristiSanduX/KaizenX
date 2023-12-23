//
//  RootView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 30.10.2023.
//

import SwiftUI

/// `RootView` decide care view să fie afișat în funcție de starea de autentificare a utilizatorului.
/// Afișează `ProfileView` dacă utilizatorul este autentificat sau `SignInEmailView` în caz contrar.
struct RootView: View {
    
    // Proprietatea @State urmărește dacă ecranul de autentificare trebuie afișat.
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack {
            if !showSignInView {
                NavigationStack {
                    MainView()
                }
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                SignInEmailView(showSignInView: $showSignInView)
            }
        }
    }
}

#Preview {
    RootView()
}
