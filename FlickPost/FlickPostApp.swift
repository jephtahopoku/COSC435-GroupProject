//
//  FlickPostApp.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/4/24.
//


import FirebaseAuth
import SwiftUI
import Firebase

@main
struct FlickPostApp: App {
    @StateObject private var authState = AuthState()

    init() {
      
        FirebaseApp.configure()

        // Debugging to check if user is authenticated at the start
        if let user = Auth.auth().currentUser {
            print("App initialized. User is already logged in: \(user.email ?? "No email")")
        } else {
            print("App initialized. No user logged in.")
        }
    }

    var body: some Scene {
        WindowGroup {
            // Check the authentication state and navigate accordingly
            if authState.isAuthenticated {
                HomeScreenView()  // Show home screen if authenticated
            } else {
                LoginView(isAuthenticated: $authState.isAuthenticated)  // Show login screen
            }
        }
    }
}

// Define an observable object to track authentication state
class AuthState: ObservableObject {
    @Published var isAuthenticated = false

    init() {
        // Debugging to check if the user is authenticated when the app starts
        if Auth.auth().currentUser != nil {
            self.isAuthenticated = true
            print("User is authenticated at launch.")
        } else {
            self.isAuthenticated = false
            print("User is not authenticated at launch.")
        }
    }
}





