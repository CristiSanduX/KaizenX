//
//  AuthenticationManager.swift
//  KaizenX
//
//  Created by Cristi Sandu on 27.10.2023.
//

import Foundation
import FirebaseAuth

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init() { }
    
    func createUser(email: String, password: String) async throws {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
    }
}
