//
//  CreatePostView.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/12/24.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct CreatePostView: View {
    @ObservedObject var postViewModel = PostViewModel()
    @State private var caption: String = ""
    @State private var comments:  [Comments] = []
    @State private var imageUrl: String = ""
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedImage: UIImage? = nil
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isActionPresented: Bool = false
    @State private var isPosted: Bool = false
    @State private var isHomePresented: Bool = false
    @State private var username : String = ""
    @State private var isCameraViewPresented : Bool = false
    @Binding var isAuthenticated: Bool

    var body: some View {
        VStack {
            Text("Create Post")
                .font(.largeTitle)
                .padding()
                .bold()
            
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
             
            Button {
                isCameraViewPresented.toggle()
            } label: {
                Text("Take A photo")
            }

            
            TextField("Post Title", text: $caption)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(5)
            
            
            Button(action: {
                if !caption.isEmpty {
                    savePost()
                    isHomePresented.toggle()
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
        .fullScreenCover(isPresented: $isHomePresented, content: {
            HomeScreenView(isAuthenticated: $isAuthenticated)
        })
        .sheet(isPresented: $isCameraViewPresented, content: {
            CameraView(selectedImage: $selectedImage)
        })
        .padding()
    }
    
    func clearPost() {
        caption = ""
        selectedImage = nil
    }
    
    func savePost() {
        
        fetchUserName()
            
        guard let postImage = selectedImage else {
            print("No Post image selected.")
            return
        }

        uploadPostToFirebase(PostImage: postImage) { imageUrl, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                // Handle error, e.g., show error message to user
                return
            }

            let db = Firestore.firestore()
            let user = Auth.auth().currentUser
            let postRef = db.collection("posts").document()

            let postData: [String: Any] = [
                "id" : postRef.documentID,
                "userId" : user?.uid ?? "",
                "username" : username,
                "caption" : caption,
                "comments": [],
                "imageUrl" : imageUrl ?? "",
                "timestamp" : Date(),
                 "likes" : 0,
                 "likedBy " : [],
                "isLiked" : false,
            ]

            postRef.setData(postData) { error in
                if let error = error {
                    print("Error saving Post:  \(error.localizedDescription)")
                    // Handle error, e.g., show error message to user
                } else {
                    print("Picute uploaded successfully.")
                    DispatchQueue.main.async {
                        isPosted = true
                        clearPost()
                    }
                }
            }
        }
    }
    
    func uploadPostToFirebase(PostImage: UIImage, completion: @escaping (String?, Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("❌ No authenticated user found")
            completion(nil, NSError(domain: "com.yourapp.error", code: 0, userInfo: ["message": "No authenticated user"]))
            return
        }
        
        print("👤 Current User UID: \(user.uid)")

        guard let imageData = PostImage.jpegData(compressionQuality: 0.75) else {
            print("❌ Failed to convert image to data")
            completion(nil, NSError(domain: "com.yourapp.error", code: 1, userInfo: ["message": "Failed to convert image to data"]))
            return
        }

        let storage = Storage.storage()
        
        let uniqueFileName = "\(UUID().uuidString).jpg"
        let storageRef = storage.reference().child("user_posts/\(user.uid)/\(uniqueFileName)")
        
        print("📤 Uploading to path: \(storageRef.fullPath)")

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("❌ Upload Error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("❌ Download URL Error: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }

                if let imageUrl = url?.absoluteString {
                    print("✅ Successfully uploaded. URL: \(imageUrl)")
                    completion(imageUrl, nil)
                } else {
                    print("❌ Failed to obtain download URL")
                    completion(nil, NSError(domain: "com.yourapp.error", code: 2, userInfo: ["message": "Failed to obtain download URL"]))
                }
            }
        }
    }
    
    func fetchUserName() {
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
                self.username = data["username"] as? String ?? "No Name"
                }
            }
        }
        

}





