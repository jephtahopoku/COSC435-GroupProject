//
//  UploadImageView.swift
//  FlickPost
//
//  Created by Jephtah Opoku on 11/30/24.
//

import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseAuth

struct UploadImageView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    var body: some View {
        VStack {
            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                
            }
            HStack {
                Button  {
                
                } label: {
                    Text("Next")
                }

            }
            .onChange(of: selectedItem) { newItem, _ in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                        uploadImageToFirebase(imageData: data)
                    }
                }
            }
        }
    }

    func uploadImageToFirebase(imageData: Data) {
        let currentUser = Auth.auth().currentUser!
        let storage = Storage.storage()
        let storageRef = storage.reference().child("user_posts/\(UUID().uuidString).jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }

            storageRef.downloadURL { (url, error) in
                if let url = url {
                    print("Image uploaded successfully! URL: \(url)")
//                    imageUrl = url.absoluteString 
                }
            }
        }
    }
}




