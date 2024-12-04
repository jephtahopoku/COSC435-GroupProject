//
//  UploadImageView.swift
//  FlickPost
//
//  Created by Jephtah Opoku on 11/30/24.
//

import SwiftUI
import PhotosUI
import FirebaseStorage

struct UploadImageView: View {
    @Binding var imageUrl: String?
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    var body: some View {
        VStack {
            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
            }
            .onChange(of: selectedItem) { newItem, _ in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                        uploadImageToFirebase(imageData: data)
                    }
                }
            }

            if let imageUrl = imageUrl {
                Text("Uploaded image URL: \(imageUrl)")
                    .padding()
            }
        }
    }

    func uploadImageToFirebase(imageData: Data) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("profile_images/\(UUID().uuidString).jpg")

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
                    imageUrl = url.absoluteString 
                }
            }
        }
    }
}




