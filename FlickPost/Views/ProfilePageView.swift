import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct ProfilePageView: View {
    @State private var selectedAccount: String = "MyAccount"
    @State private var postCount: Int = 0
    @State private var followerCount: Int = 0
    @State private var followingCount: Int = 0
    @State private var profileName: String = "Loading..."
    @State private var profileBio: String = "Loading..."
    @State private var profileImageUrl: String = ""
    @State private var posts: [String] = []
    @State private var isEditProfilePresented: Bool = false
    @State private var isLoading: Bool = true
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                
                HStack {
                    Text(selectedAccount)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        
                    }) {
                        Image(systemName: "plus.square")
                            .font(.title)
                            .foregroundStyle(.black)
                    }
                }
                .padding(.horizontal)
                
                
                HStack(spacing: 16) {
                    
                    AsyncImage(url: URL(string: profileImageUrl)) { image in
                        image.resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 80, height: 80)
                    } placeholder: {
                        Image(systemName: "person")
                            .font(.system(size: 40))
                            .frame(width: 80, height: 80)
                        
                    }
                    .padding(.trailing)
                    
                    VStack {
                        Text("\(postCount)")
                            .font(.system(size: 16))
                        Text("Posts")
                            .font(.system(size: 16))
                    }
                    
                    VStack {
                        Text("\(followerCount)")
                            .font(.system(size: 16))
                        Text("Followers")
                            .font(.system(size: 16))
                    }
                    
                    VStack {
                        Text("\(followingCount)")
                            .font(.system(size: 16))
                        Text("Following")
                            .font(.system(size: 16))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(profileName)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(profileBio)
                        .font(.body)
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                
                
                Button(action: {
                    isEditProfilePresented = true
                }) {
                    Text("Edit Profile")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                .sheet(isPresented: $isEditProfilePresented) {
                    
                    EditProfileView(selectedAccount: $selectedAccount, profileName: $profileName, profileBio: $profileBio)
                }
                
                Divider()
                
                
                if posts.isEmpty {
                    VStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No Posts Yet")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) {
                            ForEach(posts, id: \.self) { post in
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 100)
                                    .overlay(
                                        Text(post)
                                            .font(.caption)
                                    )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .onAppear {
                fetchUserProfile()
            }
        }
    }
    
    
    
    func fetchUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching profile: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No profile data found for user \(userId).")
                return
            }
            
            DispatchQueue.main.async {
                self.profileName = data["username"] as? String ?? "No Name"
                self.profileBio = data["bio"] as? String ?? "No Bio"
                if let imageUrl = data["profileImageURL"] as? String {
                    profileImageUrl = imageUrl
                    print("Profile Image URL: \(profileImageUrl)")
                } else {
                    print("No profile image URL found.")
                }
                
                
                
                fetchUserPosts(userId: userId)
                fetchFollowerData(userId: userId)
            }
        }
        
        
        
        func fetchUserPosts(userId: String) {
            let db = Firestore.firestore()
            
            db.collection("posts").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching posts: \(error.localizedDescription)")
                } else {
                    posts = snapshot?.documents.compactMap { $0["title"] as? String } ?? []
                    postCount = posts.count
                    isLoading = false
                }
            }
        }
        
        
        func fetchFollowerData(userId: String) {
            let db = Firestore.firestore()
            
            
            db.collection("users").document(userId).collection("followers").getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching followers: \(error.localizedDescription)")
                } else {
                    followerCount = snapshot?.documents.count ?? 0
                }
            }
            
            
            db.collection("users").document(userId).collection("following").getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching following: \(error.localizedDescription)")
                } else {
                    followingCount = snapshot?.documents.count ?? 0
                }
            }
        }
    }
}

#Preview {
    ProfilePageView()
}



