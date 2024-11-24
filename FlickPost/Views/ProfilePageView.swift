import SwiftUI

struct ProfilePageView: View {
    @State private var selectedAccount: String = "MyAccount" //Store account name
    @State private var accounts: [String] = ["MyAccount", "WorkAccount", "TravelAccount"]
    @State private var postCount: Int = 21 //Store # of posts
    @State private var followerCount: Int = 120 //Store # of followers
    @State private var followingCount: Int = 75 //Store # of following
    @State private var isEditProfilePresented: Bool = false
    @State private var posts: [String] = Array(repeating: "Sample Post", count: 21)
    
    @State private var profileName: String = "Dominick" // Store profile name
    @State private var profileBio: String = "Sports🏀⚽️" // Store profile bio

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // Header Section
                HStack {
                    // Dropdown for account selection
                    Menu {
                        ForEach(accounts, id: \.self) { account in
                            Button(action: {
                                selectedAccount = account
                            }) {
                                Text(account)
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedAccount)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.black)
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.black)
                        }
                    }
                    
                    Spacer()
                    
                    // "+" button to create a post
                    Button(action: {
                        print("Create post tapped")
                        // Implement post creation functionality
                    }) {
                        Image(systemName: "plus.square")
                            .font(.title)
                            .foregroundStyle(.black)
                    }
                }
                .padding(.horizontal)
                
                // Profile Info
                HStack(spacing: 16) {
                    // Profile Picture
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text("U")
                                .font(.title)
                                .foregroundColor(.white)
                        )
                        .padding(.trailing)
                    
                    VStack {
                        Text("\(postCount)")
                            .font(.system(size: 16))
                        Text("Posts")
                            .font(.system(size: 16))
                    }
                    
                    VStack{
                        Text("\(followerCount)")
                            .font(.system(size: 16))
                        Text("Followers")
                            .font(.system(size: 16))
                    }
                    
                    VStack{
                        Text("\(followingCount)")
                            .font(.system(size: 16))
                        Text("Following")
                            .font(.system(size: 16))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                // Name and Bio below the profile picture
                VStack(alignment: .leading, spacing: 8) {
                    Text(profileName) // Display the profile name
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(profileBio) // Display the bio
                        .font(.body)
                        .foregroundColor(.black)
                }
                .padding(.horizontal)

                // Edit Profile Button
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
                    EditProfileView(selectedAccount: $selectedAccount,
                                     profileName: $profileName,
                                     profileBio: $profileBio)
                }
                
                Divider()
                
                // Posts Section
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
                            ForEach(posts.indices, id: \.self) { index in
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 100)
                                    .overlay(
                                        Text(posts[index])
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
        }
    }
}

#Preview {
    ProfilePageView()
}
