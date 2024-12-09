//
//  ProfileOptionsView.swift
//  FlickPost
//
//  Created by Dominick Winningham on 12/6/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileOptionsView: View {
    @State private var savedPosts: [String] = []
    @State private var likedPosts: [String] = []
    @Binding var isAuthenticated: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Options")) {
                    Button("Logout") {
                        logout()
                    }
                        .foregroundColor(.red)
                    }
                }
                .navigationBarItems(leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.black)
                    }
                })
                .navigationTitle("Account Options")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    
    func fetchSavedPosts() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("savedPosts").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching saved posts: \(error.localizedDescription)")
            } else {
                savedPosts = snapshot?.documents.compactMap { $0["title"] as? String } ?? []
            }
        }
    }
    
    func fetchLikedPosts() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("likedPosts").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching liked posts: \(error.localizedDescription)")
            } else {
                likedPosts = snapshot?.documents.compactMap { $0["title"] as? String } ?? []
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
//            presentationMode.wrappedValue.dismiss()
            //needs further implementation logs out after leaving the app it doesn't push user to the login page when it is pressed
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

