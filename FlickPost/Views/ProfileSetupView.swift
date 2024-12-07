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
    @State private var isHomePresented: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
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
                    
                    Button(action : {
                        isHomePresented.toggle()
                    }) {
                        Text("Skip this step")
                            .foregroundStyle(Color.white)
                            .padding()
                    }
                    if isProfileSetUp {
                        Text("Profile Setup Complete")
                            .foregroundColor(.green)
                        Button(action : {
                            isHomePresented.toggle()
                        }) {
                            Text("Next")
                                .foregroundStyle(Color.white)
                                .padding()
                        }
                    }
                }
                .padding()
                .fullScreenCover(isPresented: $isHomePresented) {
                    HomeScreenView(isAuthenticated: $isAuthenticated)
                }
                .onChange(of: selectedItem) { _, _ in
                    Task{
                        if let selectedItem,
                           let data = try? await selectedItem.loadTransferable(type: Data.self) {
                            if let image = UIImage(data: data) {
                                self.profileImage = image
                            }
                        }
                        selectedItem = nil
                    }
                }
            } .background(LinearGradient(
                gradient: Gradient(colors: [Color.indigo, Color.purple, Color.blue, Color.green]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    func saveUserProfile() {
        guard let profileImage = profileImage else {
            print("No profile image selected.")
            return
        }

        uploadProfileImageToFirebase(profileImage: profileImage) { imageUrl, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                // Handle error, e.g., show error message to user
                return
            }

            let db = Firestore.firestore()
            let user = Auth.auth().currentUser
            let usersRef = db.collection("users").document(user?.uid ?? "")

            let profileData: [String: Any] = [
                "bio": bio,
                "profileImageURL": imageUrl ?? "" // Use empty string if image upload fails
            ]

            usersRef.setData(profileData, merge: true) { error in
                if let error = error {
                    print("Error saving user profile: \(error.localizedDescription)")
                    // Handle error, e.g., show error message to user
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
    
    func uploadProfileImageToFirebase(profileImage: UIImage, completion: @escaping (String?, Error?) -> Void) {
        let user = Auth.auth().currentUser
      guard let imageData = profileImage.jpegData(compressionQuality: 0.75) else {
        completion(nil, NSError(domain: "com.yourapp.error", code: 1, userInfo: ["message": "Failed to convert image to data"]))
        return
      }

      let storage = Storage.storage()
        let storageRef = storage.reference().child("profile_images/\(user!.uid).jpg")

      storageRef.putData(imageData, metadata: nil) { metadata, error in
        if let error = error {
          completion(nil, error)
          return
        }

        storageRef.downloadURL { url, error in
          if let error = error {
            completion(nil, error)
            return
          }

          if let imageUrl = url?.absoluteString {
            completion(imageUrl, nil)
          } else {
            completion(nil, NSError(domain: "com.yourapp.error", code: 2, userInfo: ["message": "Failed to obtain download URL"]))
          }
        }
      }
    }
}




