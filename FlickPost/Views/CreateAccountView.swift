//
//  CreateAccountView.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/4/24.
//

import SwiftUI
import FirebaseAuth

struct CreateAccountView: View {
    @State private var emailOrPhone: String = ""
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var errorMessage: String = ""
    @Binding var isAuthenticated: Bool  

    var body: some View {
        VStack(spacing: 30) {
            Text("FlickPost")
                .font(.system(size: 40, weight: .bold, design: .serif))
                .foregroundColor(.white)
            Text("Create an account to get started.")
                .foregroundColor(.white)

            VStack(spacing: 15) {
                TextField("Email or Phone Number", text: $emailOrPhone)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.5))

                TextField("Name", text: $name)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.5))

                TextField("Username", text: $username)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.5))

                ZStack {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(5)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.5))
                    } else {
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(5)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.5))
                    }

                    HStack {
                        Spacer()
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 20)
                    }
                }
            }
            .padding(.horizontal, 16)

            Button(action: {
                createAccount()
            }) {
                Text("Create Account")
                    .foregroundColor(.white)
                    .padding()
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.indigo, Color.purple, Color.blue, Color.green]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
    }

    func createAccount() {
        Auth.auth().createUser(withEmail: emailOrPhone, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                print("Account created successfully.")  // Debugging
                signInUser()  // Sign in the user immediately after account creation
            }
        }
    }

    func signInUser() {
        // Sign the user in after account creation
        Auth.auth().signIn(withEmail: emailOrPhone, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                print("User signed in successfully.")  // Debugging
                // Successfully signed in, update isAuthenticated
                DispatchQueue.main.async {
                    isAuthenticated = true
                    print("isAuthenticated set to true.")  // Debugging
                }
            }
        }
    }
}





