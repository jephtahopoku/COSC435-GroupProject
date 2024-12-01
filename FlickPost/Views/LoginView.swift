//
//  LoginView.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/4/24.
//
import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State var username: String = ""
    @State var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var errorMessage: String = ""
    @Binding var isAuthenticated: Bool

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    Text("FlickPost")
                        .padding(.all)
                        .font(.system(size: 40, weight: .bold, design: .serif))
                        .foregroundColor(.white)

                    TextField("Username", text: $username)
                        .padding(.all)
                        .background(Color.white)
                        .cornerRadius(5)
                        .padding(.horizontal)

                    ZStack {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                                .padding(.all)
                                .background(Color.white)
                                .cornerRadius(5)
                                .padding(.horizontal)
                        } else {
                            SecureField("Password", text: $password)
                                .padding(.all)
                                .background(Color.white)
                                .cornerRadius(5)
                                .padding(.horizontal)
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

                    Button(action: {
                        loginUser()
                    }) {
                        Text("Login")
                            .foregroundColor(.white)
                            .padding(.all)
                            .background(Color.blue)
                            .cornerRadius(5)
                    }

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }

                 
                    NavigationLink(destination: CreateAccountView(isAuthenticated: $isAuthenticated)) {
                        Text("Don't have an account? Create one")
                            .foregroundColor(.blue)
                            .padding(.top, 20)
                    }
                }
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
    }

    func loginUser() {
        Auth.auth().signIn(withEmail: username, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
        
                isAuthenticated = true  
            }
        }
    }
}








