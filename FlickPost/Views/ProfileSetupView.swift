//
//  ProfileSetupView.swift
//  FlickPost
//
//  Created by Jephtah Opoku on 12/1/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI
import FirebaseStorage

struct ProfileSetupView: View {
    @State private var bio: String = ""
    @State private var profileImage: UIImage? = nil
    @State private var isProfileSetUp = false
    @State private var imageUrl: String = ""  // To store the URL of the uploaded image
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isImagePickerPresented = false
    @Binding var isAuthenticated: Bool

    var body: some View {
        NavigationStack{
            VStack(spacing: 20) {
                Text("Set up your profile")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
                
                TextField("Add a Bio", text: $bio)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.5))
                
                // Profile Image Picker
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Text("Select Profile Image")
                            .foregroundStyle(Color.white)
                    }
                
                // Handle image selection manually
                Button("Choose Image") {
                    self.isImagePickerPresented = true
                }
                .photosPicker(isPresented: $isImagePickerPresented, selection: $selectedItem, matching: .images, photoLibrary: .shared())
                
                if let profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .clipShape(Circle())
                        .padding()
                }
                
                Button(action: {
                    saveUserProfile()
                }) {
                    Text("Save Profile")
                        .foregroundColor(Color.white)
                        .padding()
                        .cornerRadius(5)
                }
                
                NavigationLink(destination: HomeScreenView()) {
                    Text("Skip Profile Setup")
                        .foregroundColor(Color.white)
                        .padding()
                        .cornerRadius(5)
                }
                if isProfileSetUp {
                    Text("Profile Setup Complete")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.indigo, Color.purple, Color.blue, Color.green]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .edgesIgnoringSafeArea(.all)
        }
    }

    func saveUserProfile() {
        // Check if profile image is selected
        guard let profileImage = profileImage else {
            print("No profile image selected.")
            return
        }
        
        // Upload the profile image to Firebase Storage
        uploadImageToFirebase(profileImage: profileImage) { imageUrl in
            // Now save profile information to Firestore after image upload
            let db = Firestore.firestore()
            let user = Auth.auth().currentUser
            let usersRef = db.collection("users").document(user?.uid ?? "")

            let profileData: [String: Any] = [
                "username": user?.displayName ?? "New User",
                "email": user?.email ?? "",
                "bio": bio,
                "profileImageURL": imageUrl  // Use the uploaded image URL
            ]

            usersRef.setData(profileData) { error in
                if let error = error {
                    print("Error saving user profile: \(error.localizedDescription)")
                } else {
                    print("User profile saved successfully.")
                    DispatchQueue.main.async {
                        isAuthenticated = true
                        isProfileSetUp = true
                    }
                }
            }
        }
    }

    func uploadImageToFirebase(profileImage: UIImage, completion: @escaping (String) -> Void) {
        // Upload the image to Firebase Storage
        let storage = Storage.storage()
        let storageRef = storage.reference().child("profile_images/\(UUID().uuidString).jpg")
        
        if let imageData = profileImage.jpegData(compressionQuality: 0.75) {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                }

                // Get the download URL after uploading
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                        return
                    }

                    // Return the URL of the uploaded image
                    if let imageUrl = url?.absoluteString {
                        completion(imageUrl)
                    }
                }
            }
        }
    }
}




