//
//  EditProfileView.swift
//  FlickPost
//
//  Created by Dominick Winningham on 11/22/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

struct EditProfileView: View {
    @Binding var selectedAccount: String
    @Binding var profileName: String
    @Binding var profileBio: String
    @State private var newUsername: String = ""
    @State private var newName: String = ""
    @State private var newBio: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Profile")) {
           
                    TextField("Username", text: $newUsername)
            
                    TextField("Name", text: $newName)
          
                    TextField("Bio", text: $newBio)
                    
   
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        Text("Update Profile Picture")
                    }
                  
                    .onAppear {
                   
                        if let selectedItem = selectedItem {
                            loadImage(from: selectedItem)
                        }
                    }
                }
                
                Section {
                    Button("Save Changes") {
                        saveProfileChanges()
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
 
    func loadImage(from item: PhotosPickerItem) {
        Task {
            do {
   
                let data = try await item.loadTransferable(type: Data.self)
                if let imageData = data, let uiImage = UIImage(data: imageData) {
                    selectedImage = uiImage
                }
            } catch {
                print("Failed to load selected item: \(error)")
            }
        }
    }
    

    func saveProfileChanges() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

       
        var updateData: [String: Any] = [
            "username": newUsername.isEmpty ? profileName : newUsername,
            "bio": newBio.isEmpty ? profileBio : newBio
        ]

        if let selectedImage = selectedImage {
            uploadProfileImage(image: selectedImage) { imageUrl in
                updateData["profileImage"] = imageUrl
        
                db.collection("users").document(userId).updateData(updateData) { error in
                    if let error = error {
                        print("Error updating profile: \(error.localizedDescription)")
                    } else {
                        print("Profile updated successfully!")
                        profileName = newUsername.isEmpty ? profileName : newUsername
                        profileBio = newBio.isEmpty ? profileBio : newBio
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        } else {
 
            db.collection("users").document(userId).updateData(updateData) { error in
                if let error = error {
                    print("Error updating profile: \(error.localizedDescription)")
                } else {
                    print("Profile updated successfully!")
                    profileName = newUsername.isEmpty ? profileName : newUsername
                    profileBio = newBio.isEmpty ? profileBio : newBio
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
  
    func uploadProfileImage(image: UIImage, completion: @escaping (String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("profile_images/\(UUID().uuidString).jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        imageRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
            } else {
                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                    } else if let url = url {
                        completion(url.absoluteString) 
                    }
                }
            }
        }
    }
}











