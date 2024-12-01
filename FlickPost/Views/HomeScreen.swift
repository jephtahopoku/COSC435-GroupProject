//
//  HomeScreen.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/11/24.
//

import SwiftUI
import FirebaseFirestore

struct HomeScreenView: View {
    @State private var posts: [Post] = []
    @State private var isProfilePageViewActive: Bool = false
    @State private var selectedPost: Post? = nil
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                }
                List(posts) { post in
                    VStack(alignment: .leading) {
                        Text(post.username).font(.headline)

                  
                        AsyncImage(url: URL(string: post.imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            case .success(let image):
                                image.resizable().scaledToFit()
                                    .frame(height: 200)
                            case .failure:
                                Text("Failed to load image")
                                    .foregroundColor(.red)
                            @unknown default:
                                EmptyView()
                            }
                        }

                        Text(post.title).font(.body)
                        Text(post.body).font(.subheadline)
                    }
                    .onTapGesture {
                        selectedPost = post
                        isProfilePageViewActive.toggle()
                    }
                }
                .onAppear {
                    loadPosts()
                }
                .sheet(isPresented: $isProfilePageViewActive) {
                    ProfilePageView()
                }
            }
            .navigationTitle("FlickPost")
            .navigationBarItems(trailing: Button(action: {
    
            }) {
                Text("Profile")
            })
        }
    }

   
    func loadPosts() {
        let db = Firestore.firestore()
        db.collection("posts").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else { return }
            
          
            let postsData = snapshot.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            
         
            for (index, var post) in postsData.enumerated() {
                let userId = post.userId
                db.collection("users").document(userId).getDocument { userSnapshot, error in
                    if let error = error {
                        print("Error fetching user: \(error.localizedDescription)")
                        return
                    }
                    if let userSnapshot = userSnapshot, let userData = userSnapshot.data() {
                  
                        post.username = userData["username"] as? String ?? "Unknown User"
                    }
                    
              
                    if index == postsData.count - 1 {
                        self.posts = postsData
                        self.isLoading = false
                    }
                }
            }
        }
    }
}



