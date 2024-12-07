//
//  CreateAccountView.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/4/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CreateAccountView: View {
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var errorMessage: String = ""
    @Binding var isAuthenticated: Bool
    @ObservedObject var createAccountViewModel = CreateAccountViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .bold()

            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                TextField("Name", text: $name)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                TextField("Username", text: $username)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                ZStack {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    } else {
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }

                    HStack {
                        Spacer()
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 16)
                    }
                }
            }

            Button(action: {
                createAccount()
//                createAccountViewModel.createAccount(email: email, password: password, name: name, username: username)
            }) {
                Text("Sign Up")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }

    func createAccount() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = "Failed to create account: \(error.localizedDescription)"
                return
            }

            // User created successfully
            guard let user = authResult?.user else {
                self.errorMessage = "Failed to fetch user details."
                return
            }
            saveUserProfile(uid: user.uid)
        }
    }

    func saveUserProfile(uid: String) {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "uid": uid,
            "email": email,
            "name": name,
            "username": username,
            "bio": "Welcome to FlickPost!",
            "profileImageURL": "", 
            "postsIDs" : [],
            "followers" : [],
            "following" : [],
            "followingCount" : 0,
            "followerCount" : 0
            
        ]
        
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                self.errorMessage = "Failed to save profile: \(error.localizedDescription)"
            } else {
                DispatchQueue.main.async {
                    self.isAuthenticated = true  
                }
            }
        }
    }
}
//#Preview {
//    CreateAccountView(isAuthenticated: .constant(true),
//                      createAccountViewModel: CreateAccountViewModel())
//}






