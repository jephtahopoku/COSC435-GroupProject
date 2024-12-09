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
            
            // Debug: Log the UID being used
            print("Attempting to fetch user profile for UID: \(uid)")
            
            db.collection("users").document(uid).getDocument { document, error in
                // Debug: Check for any errors in the fetch
                if let error = error {
                    print("❌ Error fetching user profile:")
                    print("Error Domain: \(error.localizedDescription)")
                    print("Error Code: \(error as NSError).code")
                    print("Error UserInfo: \((error as NSError).userInfo)")
                    isLoading = false
                    return
                }
                
                // Debug: Check document existence
                guard let document = document, document.exists else {
                    print("⚠️ Document does not exist for UID: \(uid)")
                    isLoading = false
                    return
                }
                
                // Debug: Print entire document data
                guard let data = document.data() else {
                    print("❌ No data found in document")
                    isLoading = false
                    return
                }
                print("📋 Document Data: \(data)")
                
                // Debug: Detailed validation of each expected field
                print("🔍 Validating document fields:")
                print("Username: \(data["username"] ?? "NIL")")
                print("Bio: \(data["bio"] ?? "NIL")")
                print("Profile Image URL: \(data["profileImageURL"] ?? "NIL")")
                print("Follower Count: \(data["followerCount"] ?? "NIL")")
                print("Following Count: \(data["followingCount"] ?? "NIL")")
                
                // Detailed type checking and optional binding
                if let username = data["username"] as? String,
                   let bio = data["bio"] as? String,
                   let profileImageURL = data["profileImageURL"] as? String,
                   let followerCount = data["followerCount"] as? Int,
                   let followingCount = data["followingCount"] as? Int {
                    
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
                    
                    print("✅ User profile successfully created")
                } else {
                    print("❌ Failed to create user profile - Type mismatch or missing fields")
                    
                    // Extra debug: Specific type mismatch information
                    if data["username"] as? String == nil { print("❗ 'username' is not a String") }
                    if data["bio"] as? String == nil { print("❗ 'bio' is not a String") }
                    if data["profileImageURL"] as? String == nil { print("❗ 'profileImageURL' is not a String") }
                    if data["followerCount"] as? Int == nil { print("❗ 'followerCount' is not an Int") }
                    if data["followingCount"] as? Int == nil { print("❗ 'followingCount' is not an Int") }
                }
                
                isLoading = false
            }
        }
    }
