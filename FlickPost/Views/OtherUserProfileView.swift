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
    @State private var isFollowing: Bool = false
    var uid: String  // Passed from the SearchPageView to identify the user
    
    var body: some View {
        VStack (alignment: .leading, spacing: 16) {
            if let user = user {
                
                HStack{
                    //Username
                    Text(user.username)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.black)
                        .padding()
                }
                
                HStack {
                    //profile image
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
                    
                    
                    // follower/following count
                    VStack {
                        Text("\(user.followerCount)")
                            .font(.system(size: 16))
                        Text("Followers")
                            .font(.system(size: 16))
                    }
                    
                    VStack{
                        Text("\(user.followingCount)")
                            .font(.system(size: 16))
                        Text("Following")
                            .font(.system(size: 16))
                    }
                    
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8){
                    // Username and Bio
                    Text(user.bio)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 5)
                }
                .padding(.horizontal)
                
                Button(action: {
                    isFollowing ? unfollowUser(targetUserID: uid) : follow(targetUserID: uid)
                }) {
                    Text(isFollowing ? "Unfollow" : "Follow")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFollowing ? Color.white : Color.blue)
                        .cornerRadius(8)
                        .foregroundColor(.black)
                }.padding(.horizontal)
                
                Spacer()
            } else {
                ProgressView()
            }
        }
        .onAppear {
            fetchUserProfile()
        }
        .padding()
    }
    
    func fetchUserProfile() {
        let db = Firestore.firestore()
        
        
        print("Attempting to fetch user profile for UID: \(uid)")
        
        db.collection("users").document(uid).getDocument { document, error in
            
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
    func follow (targetUserID : String){
        let currentUserID = Auth.auth().currentUser?.uid ?? ""
        
        isFollowing.toggle()
        
        let db = Firestore.firestore()
        
        let currentUserRef = db.collection("users").document(currentUserID)
        let targetUserRef = db.collection("users").document(uid)
        
        
        let batch = db.batch()
        
        batch.updateData([
            "following": isFollowing
            ? FieldValue.arrayUnion([uid])
            : FieldValue.arrayRemove([uid]),
            "followingCount": isFollowing ? (user?.followerCount ?? 0) + 1 : (user?.followerCount ?? 0) - 1
        ], forDocument: currentUserRef)
        
        batch.updateData([
            "followers": isFollowing
            ? FieldValue.arrayUnion([currentUserID])
            : FieldValue.arrayRemove([currentUserID]),
            "followerCount": isFollowing ? (user?.followerCount ?? 0) + 1 : (user?.followerCount ?? 0) - 1
        ], forDocument: targetUserRef)
        
        batch.commit()
        
    }
    
    func unfollowUser(targetUserID: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        let currentUserRef = Firestore.firestore().collection("users").document(currentUserID)
        let targetUserRef = Firestore.firestore().collection("users").document(targetUserID)
        
        let batch = Firestore.firestore().batch()
        
        // Remove from current user's following list
        batch.updateData([
            "following": FieldValue.arrayRemove([targetUserID]),
            "followingCount": FieldValue.increment(Int64(-1))
        ], forDocument: currentUserRef)
        
        // Remove from target user's followers list
        batch.updateData([
            "followers": FieldValue.arrayRemove([currentUserID]),
            "followerCount": FieldValue.increment(Int64(-1))
        ], forDocument: targetUserRef)
        
        batch.commit { error in
            if let error = error {
                print("Error unfollowing user: \(error.localizedDescription)")
            }
        }
        
        
        func checkFollowStatus() {
            let currentUserID = Auth.auth().currentUser?.uid ?? ""
            let db = Firestore.firestore()
            db.collection("users").document(currentUserID).getDocument { snapshot, error in
                guard let data = snapshot?.data() else { return }
                self.isFollowing = (data["following"] as? [String] ?? []).contains(self.uid)
            }
        }
        
    }
}
