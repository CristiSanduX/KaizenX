//
//  AuthenticationView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 25.10.2023.
//

import SwiftUI

struct AuthenticationView: View {
    @Binding var showSignInView: Bool
    var body: some View {
        VStack {
            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sign in with email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color.darkRed)
                    .cornerRadius(12)
            }

            Spacer() // Împinge NavigationLink-ul în partea de sus a ecranului
        }
        .padding()
        .navigationTitle("Sign in")

    }
    
}

#Preview {
    NavigationStack {
        AuthenticationView(showSignInView: .constant(false))
    }
    
}
