//
//  LoginViewModel.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/6/24.
//

import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var errorMessage: String = ""
    @Published var isLoggedIn: Bool = false
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = "Error logging in: \(error.localizedDescription)"
                self.isLoggedIn = false
            } else {
                self.isLoggedIn = true
                self.errorMessage = ""
                print("User logged in successfully!")
            }
        }
    }
}

