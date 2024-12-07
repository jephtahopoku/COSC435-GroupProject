//
//  CreatePostView.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/12/24.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct CreatePostView: View {
    @ObservedObject var postViewModel = PostViewModel()
    @State private var title: String = ""
    @State private var postBody: String = ""
    @State private var imageUrl: String = ""
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedImage: UIImage? = nil
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isActionPresented: Bool = false
    let currentUserID = Auth.auth().currentUser?.uid
    let currentUserName = Auth.auth().currentUser?.displayName

    var body: some View {
        VStack {
           
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            } else {
                VStack {
                    Image(systemName: "photo.on.rectangle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            
            PhotosPicker(selection: $selectedItem, matching: .images , photoLibrary: PHPhotoLibrary.shared()) {
                Text(selectedImage == nil ? "Select a Photo" : "Change Photo")
            }
            
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
                        userId: currentUserID!,
                        title: title,
                        body: postBody,
                        imageUrl: imageUrl,
                        timestamp: Date(),
                        username: currentUserName!
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
        .onChange(of: selectedItem) { _, _ in
            Task{
                if let selectedItem,
                   let data = try? await selectedItem.loadTransferable(type: Data.self) {
                    if let image = UIImage(data: data) {
                        self.selectedImage = image
                    }
                }
                selectedItem = nil
            }
        }
        .padding()
    }
}




