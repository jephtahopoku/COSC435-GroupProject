//
//  CreateAccountView.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/4/24.
//

import SwiftUI

struct CreateAccountView: View {
    @State private var emailOrPhone: String = ""
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer().frame(height: 20)
                
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
                    // Handle account creation logic here
                }) {
                    Text("Create Account")
                        .foregroundColor(.white)
                        .padding()
                }
                
                Spacer()
            }
            .background(
                LinearGradient (
                    gradient: Gradient(colors: [Color.indigo, Color.purple, Color.blue, Color.green]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
//            .background(Color.white)
//            .edgesIgnoringSafeArea(.all)
        }
    }
}


#Preview {
    CreateAccountView()
}
