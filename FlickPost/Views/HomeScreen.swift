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
    @State private var isRefreshing = true
    @State private var showingMoreOptions: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @Binding var isAuthenticated: Bool

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
                    Text("You do not have any posts, Click the plus to make a new post")
                        .font(.headline)
                        .padding()
                        .foregroundStyle(.purple)
                }

                List($posts) { $post in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(post.username).font(.headline)
                                .bold()
                                .padding(.leading)
                                .onTapGesture {
                                    selectedPost = post
                                    isProfilePageViewActive.toggle()
                                }
                            Spacer()

                            Button {
                                showingMoreOptions = true
                            } label: {
                                Image(systemName: "ellipsis").font(.headline)
                                    .foregroundStyle(.black)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .confirmationDialog("Options", isPresented: $showingMoreOptions, titleVisibility: .visible) {
                                Button("Delete Post", role: .destructive) {
                                    showDeleteConfirm = true
                                }
                                Button("Cancel", role: .cancel) {}
                            }
                            .alert("Delete Posts", isPresented: $showDeleteConfirm) {
                                Button("Delete", role: .destructive) {
                                    deletePost(post: post)
                                }
                                Button("Cancel", role: .cancel) {}
                            } message: {
                                Text("Are you sure you want to delete this post?")
                            }
                        }
                        AsyncImage(url: URL(string: post.imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .aspectRatio(1, contentMode: .fit)
                            case .failure:
                                Text("Failed to load image")
                                    .foregroundColor(.red)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    VStack(alignment: .leading) {
                        HStack(spacing: 20) {
                            Button {
                                toggleLike(post: &post)
                            } label: {
                                Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                    .foregroundStyle(post.isLiked ? .red : .black)
                                    .imageScale(.large)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Text("\(post.likes) likes").font(.headline)

                            Spacer()
                        }
                        HStack {
                            Text(post.username).font(.headline)
                                .onTapGesture {
                                    selectedPost = post
                                    isProfilePageViewActive.toggle()
                                }
                            Text(post.caption).font(.body)
                        }
                        Text(post.timestamp, style: .date).font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
                .onAppear {
                    loadPosts()
                }
            }
            .tabItem { Image(systemName: "house") }
            SearchPageView()
                .tabItem { Image(systemName: "magnifyingglass") }
            CreatePostView(isAuthenticated: $isAuthenticated)
                .tabItem { Image(systemName: "plus.app") }
            ProfilePageView(isAuthenticated: $isAuthenticated)
                .tabItem { Image(systemName: "person") }
        }
        .sheet(isPresented: $isProfilePageViewActive, content: {
            ProfilePageView(isAuthenticated: $isAuthenticated)
        })
        .refreshable {
            refreshPosts()
        }
    }

    func toggleLike(post: inout Post) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }

        let db = Firestore.firestore()
        let postRef = db.collection("posts").document(post.id)

        post.isLiked.toggle()
        post.likes += post.isLiked ? 1 : -1

        // Update Firestore
        postRef.updateData([
            "likes": post.likes,
            "likedBy": post.isLiked
                ? FieldValue.arrayUnion([currentUserId])
                : FieldValue.arrayRemove([currentUserId])
        ]) { error in
            if let error = error {
                print("Error updating likes: \(error.localizedDescription)")
            } else {
                print("Post like status updated.")
            }
        }
    }

    func refreshPosts() {
        isRefreshing = true
        loadPosts()
        isRefreshing = false
    }

    func deletePost(post: Post) {
        let db = Firestore.firestore()

        db.collection("posts").document(post.id).delete { error in
            if let error = error {
                print("Error deleting post: \(error)")
            }
        }
        loadPosts()
    }

    func loadPosts() {
        let db = Firestore.firestore()
        db.collection("posts").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
                self.isLoading = false
                return
            }

            guard let documents = snapshot?.documents else {
                print("No posts found.")
                self.isLoading = false
                return
            }

            let postsData = documents.compactMap { doc -> Post? in
                do {
                    var post = try doc.data(as: Post.self)
                    post.isLiked = post.likedBy.contains(Auth.auth().currentUser?.uid ?? "")
                    return post
                } catch {
                    print("Error decoding post: \(error)")
                    return nil
                }
            }

            DispatchQueue.main.async {
                self.posts = postsData
                self.isLoading = false
            }
        }
    }
}






