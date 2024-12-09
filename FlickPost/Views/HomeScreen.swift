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
    @State private var isCommentsActive: Bool = false
    @State private var isMakePostActive: Bool = false
    @State private var selectedPost: Post? = nil
    @State private var isLoading = true
    @State private var imageUrl = ""
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var likeAnimation = false
    
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
                    Text("You do not have any post, Click the plus to make a new post")
                        .font(.headline)
                        .padding()
                        .foregroundStyle(.purple)
                }
                List($posts) { post in
                    VStack(alignment: .leading) {
                        Text(post.username.wrappedValue).font(.headline)
                            .bold()
                            .padding(.leading)
                            .onTapGesture {
                                selectedPost = post.wrappedValue
                                isProfilePageViewActive.toggle()
                            }
                        AsyncImage(url: URL(string: post.imageUrl.wrappedValue)) { phase in
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
                    VStack (alignment: .leading){
                        HStack (spacing: 20){
                            Button {
                                if let index = posts.firstIndex(where: { $0.id == post.id }) {
                                        posts[index].isLiked.toggle()
                                        posts[index].likes += posts[index].isLiked ? 1 : -1
                                    }
                            } label: {
                                Image(systemName: post.isLiked.wrappedValue ?  "heart.fill" : "heart")
                                    .foregroundStyle(post.isLiked.wrappedValue ? .red : .black)
                                    .imageScale(.large)
                            }
                            Text("\(post.likes.wrappedValue) likes ").font(.headline)
                            Button {
                                selectedPost = post.wrappedValue
                            } label: {
                                Image(systemName: "message")
                                    .foregroundStyle(.black)
                                    .imageScale(.large)
                            }
                            Spacer()
                            
                        }
                        HStack {
                            Text(post.username.wrappedValue).font(.headline)
                                .onTapGesture {
                                    selectedPost = post.wrappedValue
                                    isProfilePageViewActive.toggle()
                                }
                            Text(post.caption.wrappedValue).font(.body)
                        }
                        Text(post.timestamp.wrappedValue, style: .date).font(.caption)
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
            
        }.sheet(isPresented: $isProfilePageViewActive, content: { ProfilePageView(isAuthenticated:$isAuthenticated) })
            .sheet(isPresented: $isCommentsActive) {
                CommentsView(post: $selectedPost)
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




