//
//  CreatePostView.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/12/24.
//

import SwiftUI

struct CreatePostView: View {
    @ObservedObject var postViewModel = PostViewModel()
    @State private var title: String = ""
    @State private var postBody: String = ""
    @State private var imageUrl: String = ""
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        VStack {
            TextField("Post Title", text: $title)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(5)
            
            TextField("Post Body", text: $postBody)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(5)
            
            Button(action: {
               
                if !title.isEmpty && !postBody.isEmpty {
                    let newPost = Post(
                        id: UUID().uuidString,
                        userId: "UserID",
                        title: title,
                        body: postBody,
                        imageUrl: imageUrl,
                        timestamp: Date(),
                        username: "Username"
                    )
                    postViewModel.savePost(post: newPost)
                }
            }) {
                Text("Save Post")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
            
          
        }
        .padding()
    }
}




