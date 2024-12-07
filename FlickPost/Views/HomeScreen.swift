//
//  HomeScreen.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/11/24.
//

import SwiftUI
import FirebaseFirestore
import PhotosUI
import FirebaseAuth

struct HomeScreenView: View {
    @State private var posts: [Post] = []
    @State private var isProfilePageViewActive: Bool = false
    @State private var isMakePostActive: Bool = false
    @State private var selectedPost: Post? = nil
    @State private var isLoading = true
    @State private var imageUrl = ""
    @State private var selectedImage: PhotosPickerItem? = nil
    var body: some View {
        TabView {
                VStack {
                    Text("FlickPost")
                        .font(.title)
                        .padding()
                        .bold()
                    Divider()
                    if isLoading {
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                    
                    if posts.isEmpty {
                        Text("You do not have any post, Click the plus to make a new post")
                            .font(.headline)
                            .padding()
                            .foregroundStyle(.purple)
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
                }
                .tabItem { Image(systemName: "house") }
            SearchPageView()
                .tabItem { Image(systemName: "magnifyingglass") }
            CreatePostView()
                .tabItem { Image(systemName: "plus.app") }
            ProfilePageView()
                .tabItem { Image(systemName: "person") }
                
        }
    }

    func loadPosts() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("🚨 User not authenticated.")
            isLoading = false
            return
        }
        
        print("🔍 Attempting to fetch posts for userId: \(userId)")
        
        let db = Firestore.firestore()
        db.collection("posts")
          .whereField("userId", isEqualTo: userId)
          .getDocuments { snapshot, error in
            
            // Error handling
            if let error = error {
                print("🚨 Error fetching posts: \(error.localizedDescription)")
                self.isLoading = false
                return
            }
            
            guard let snapshot = snapshot else {
                print("🚨 No snapshot returned")
                self.isLoading = false
                return
            }
            
            // Log number of documents
            print("📄 Documents found: \(snapshot.documents.count)")
            
            let postsData = snapshot.documents.compactMap { doc -> Post? in
                
                do {
                    let post = try doc.data(as: Post.self)
                    print("✅ Decoded post: \(post)")
                    return post
                } catch {
                    print("🚨 Failed to decode post: \(error)")
                    return nil
                }
            }
            
            DispatchQueue.main.async {
                self.posts = postsData
                self.isLoading = false
                print("🎉 Total posts loaded: \(postsData.count)")
            }
        }
    }
}




