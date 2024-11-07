//
//  LoginView.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/4/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView : View {
    @State var username: String = ""
    @State var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @ObservedObject var viewModel = LoginViewModel()
  var body: some View {
      NavigationView{
        ScrollView{
          Spacer(minLength: 30)
          Text("FlickPost")
              .padding(.all)
              .font(.system(size: 40, weight: .bold, design: .serif))
              .bold()
              .foregroundStyle(Color(.white))
          VStack(spacing: 30){
              TextField("Username", text: $username)
                  .padding(.all)
                  .foregroundStyle(Color(.black))
                  .background(Color.white)
                  .cornerRadius(5)
                  .padding(.horizontal)
              ZStack{
                  if isPasswordVisible{
                      TextField("Password", text: $password)
                          .padding(.all)
                          .foregroundStyle(Color(hex: "#333333"))
                          .background(Color.white)
                          .cornerRadius(5)
                          .padding(.horizontal)
                      
                  } else {
                      SecureField("Password", text: $password)
                          .padding(.all)
                          .foregroundStyle(Color(hex: "#333333"))
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
              
              HStack {
                  Button(action:{}){
                      Text("Login")
                          .foregroundStyle(Color(.white))
                          .padding(.all)
                  }
                  NavigationLink(destination: CreateAccountView(), label: {
                      Text("Register")
                          .foregroundStyle(Color(.white))
                          .padding(.all)
                  })
              }
          }
        }
          .background(
            LinearGradient (
                gradient: Gradient(colors: [Color.indigo, Color.purple, Color.blue, Color.green]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
          )
        }
      }
    }

#Preview {
    LoginView()
}
