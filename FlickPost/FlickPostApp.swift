//
//  FlickPostApp.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/4/24.
//



import SwiftUI
import Firebase
import FirebaseAuth

@main
struct FlickPostApp: App {
    @StateObject private var authState = AuthState()  // Track authentication state

    init() {
        FirebaseApp.configure()  // Initialize Firebase
    }

    var body: some Scene {
        WindowGroup {
            // Check if the user is authenticated and if their profile is complete
            if authState.isAuthenticated {
                if authState.isProfileComplete {
                    HomeScreenView(isAuthenticated: $authState.isAuthenticated)  // Show home screen if authenticated and profile is complete
                } else {
                    ProfileSetupView(isAuthenticated: $authState.isAuthenticated)  // Profile setup for new users
                }
            } else {
                LoginView(isAuthenticated: $authState.isAuthenticated)  // Show login view if not authenticated
            }
        }
    }
}

class AuthState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isProfileComplete = false

    init() {
        checkAuthentication()
    }

    func checkAuthentication() {
        // Clear previous session for testing/development
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true) { _, error in
            if let error = error {
                print("Error refreshing token: \(error.localizedDescription)")
            } else {
                // Now check if user is authenticated
                if let user = Auth.auth().currentUser {
                    self.isAuthenticated = true
                    print("User is authenticated at launch: \(user.email ?? "No email")")  // Debugging
                    
                    // Check if the user's profile is complete
                    self.checkUserProfile()
                } else {
                    self.isAuthenticated = false
                    self.isProfileComplete = false
                    print("No user authenticated at launch.")  // Debugging
                }
            }
        }
    }

    func checkUserProfile() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            self.isProfileComplete = false
            return
        }

        db.collection("users").document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error checking profile: \(error.localizedDescription)")
            } else {
                if let document = document, document.exists {
                    self.isProfileComplete = true  // If profile exists, set it to true
                    print("User profile is complete.")
                } else {
                    self.isProfileComplete = false  // If profile is not set, ask for setup
                    print("User profile is not complete.")
                }
            }
        }
    }
}











