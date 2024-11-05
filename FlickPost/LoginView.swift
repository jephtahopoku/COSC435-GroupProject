//
//  LoginView.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/4/24.
//

import SwiftUI

struct LoginView : View {
    @State var username: String = ""
    @State var password: String = ""
  var body: some View {
      ScrollView{
          Spacer(minLength: 30)
          Text("FlickPost")
              .padding(.all)
              .font(.system(size: 40, weight: .bold))
              .bold()
              .foregroundStyle(Color(hex: "#333333"))
          
          VStack(spacing: 30){
              TextField("Username", text: $username)
                  .padding(.all)
                  .foregroundStyle(Color(hex: "#333333"))
                  .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(hex: "#007AFF"))
                  )
              TextField("Password", text: $password)
                  .padding(.all)
                  .foregroundStyle(Color(hex: "#333333"))
                  .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(hex: "#007AFF"))
                  )
              HStack{
                  Button(action:{}){
                      Text("Login")
                          .foregroundStyle(Color(hex: "#A29BFE"))
                          .padding(.all)
                  }
                  NavigationLink(destination: CreateAccountView(), label: {
                      Text("Register")
                          .foregroundStyle(Color(hex: "#A29BFE"))
                          .padding(.all)
                  })
              }
          }
      }
      .background(Color(hex: "#F8F8F8"))
          
      }
    }

#Preview {
    LoginView()
}
