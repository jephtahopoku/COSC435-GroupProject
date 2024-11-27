//
//  EditProfileView.swift
//  FlickPost
//
//  Created by Dominick Winningham on 11/22/24.
//

import SwiftUI

struct EditProfileView: View {
    @Binding var selectedAccount: String
    @Binding var profileName: String // Bind profile name
    @Binding var profileBio: String // Bind profile bio
    @State private var newUsername: String = ""
    @State private var newName: String = ""
    @State private var newBio: String = ""
    @Environment(\.presentationMode) var presentationMode // Environment variable for dismissing the view

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Profile")) {
                    // Username
                    TextField("Username", text: $newUsername)
                    // Name
                    TextField("Name", text: $newName)
                    // Bio
                    TextField("Bio", text: $newBio)
                    Button("Update Profile Picture") {
                        print("Update profile picture tapped")//For testing
                        // Add functionality for updating profile picture
                    }
                }
                Section {
                    Button("Save Changes") {
                        // Save the changes
                        selectedAccount = newUsername.isEmpty ? selectedAccount : newUsername
                        profileName = newName.isEmpty ? profileName : newName
                        profileBio = newBio.isEmpty ? profileBio : newBio
                        presentationMode.wrappedValue.dismiss() // Dismiss after saving
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss() // Dismiss when close is tapped
                    }
                }
            }
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(selectedAccount: .constant("MyAccount"),
                         profileName: .constant("John Doe"),
                         profileBio: .constant("Food lover and traveler"))
    }
}


