//
//  HomeScreen.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/11/24.
//

import SwiftUI
import FirebaseFirestore
import PhotosUI

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

            self.posts = postsData
            self.isLoading = false  // Finished loading posts
        }
    }
}




