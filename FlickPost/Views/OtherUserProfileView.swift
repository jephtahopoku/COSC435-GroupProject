//
//  OtherUserProfileView.swift
//  FlickPost
//
//  Created by Dominick Winningham on 12/9/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct OtherUserProfileView: View {
    @State private var user: User? = nil
    @State private var isLoading: Bool = true
    var uid: String  // Passed from the SearchPageView to identify the user
    
    var body: some View {
        VStack {
            if let user = user {
                // Profile Image
                if let url = URL(string: user.profileImage), !user.profileImage.isEmpty {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 100, height: 100)
                    } placeholder: {
                        Circle().fill(Color.gray).frame(width: 100, height: 100)
                    }
                } else {
                    // Default image if no profile image exists
                    Circle().fill(Color.gray).frame(width: 100, height: 100)
                }
                
                // Username and Bio
                Text(user.username)
                    .font(.headline)
                    .padding(.top, 10)
                Text(user.bio)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
                
                // follower/following count
                HStack {
                    Text("\(user.followerCount) followers")
                        .font(.subheadline)
                    Text("\(user.followingCount) following")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 5)
                
                Spacer()
            } else {
                ProgressView()
            }
        }
        .onAppear {
            fetchUserProfile()
        }
        .navigationTitle("Profile")
        .padding()
    }
    
    func fetchUserProfile() {
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                print("Error fetching user profile: \(error.localizedDescription)")
                isLoading = false
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                if let username = data?["username"] as? String,
                   let bio = data?["bio"] as? String,
                   let profileImageURL = data?["profileImageURL"] as? String,
                   let followerCount = data?["followerCount"] as? Int,
                   let followingCount = data?["followingCount"] as? Int {
                    self.user = User(
                        id: String(uid.hashValue),
                        bio: bio,
                        username: username,
                        password: "", // Optional field, not used here
                        profileImage: profileImageURL,
                        followers: [], // Not used here
                        following: [], // Not used here
                        followerCount: followerCount,
                        followingCount: followingCount,
                        posts: [], // Not used here
                        postsIDs: [] // Not used here
                    )
                }
            }
            isLoading = false
        }
    }
}
 
