//
//  LoginViewModel.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/6/24.
//

import SwiftUI
import Firebase
import FirebaseAuth


class LoginViewModel: ObservableObject {
    @Published var email : String = ""
    @Published var password : String = ""
    func Login(email: String , password: String) {
        Auth.auth().signIn(withEmail: email, password: password){ result, error in
            if let error {
                print(error.localizedDescription)
            }
            
        }
    }
}
