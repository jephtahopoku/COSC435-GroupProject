import SwiftUI
import FirebaseFirestore

struct SearchPageView: View {
   @State private var searchString: String = ""
   @State private var searchResults: [User] = []
   @State private var isLoading: Bool = false

   var body: some View {
       NavigationView {
           VStack {
               if isLoading {
                   ProgressView()
                       .padding()
               } else {
                   if searchResults.isEmpty && !searchString.isEmpty {
                       Text("No users found")
                           .foregroundColor(.gray)
                           .padding()
                   } else {
                       resultsList
                   }
               }
           }
           .navigationTitle("Search Users")
           .searchable(text: $searchString, prompt: "Search for users...")
           .onChange(of: searchString) {
               performSearch()
           }
       }
   }


   var resultsList: some View {
       List(searchResults, id: \.id) { user in
           NavigationLink(
               destination: OtherUserProfileView(uid: user.id)
           ) {
               resultRow(user: user)
           }
       }
       .listStyle(PlainListStyle())
   }


   @ViewBuilder
   func resultRow(user: User) -> some View {
       HStack {
           profileImage(for: user)
           VStack(alignment: .leading) {
               Text(user.username)
                   .font(.headline)
               Text("\(user.followerCount) followers")
                   .foregroundColor(.secondary)
           }
       }
   }


   @ViewBuilder
   func profileImage(for user: User) -> some View {
       if let url = URL(string: user.profileImage) {
           AsyncImage(url: url) { image in
               image.resizable()
                   .scaledToFit()
                   .clipShape(Circle())
                   .frame(width: 50, height: 50)
           } placeholder: {
               Circle()
                   .fill(Color.gray)
                   .frame(width: 50, height: 50)
           }
       } else {
           Circle()
               .fill(Color.gray)
               .frame(width: 50, height: 50)
       }
   }

 
   private func performSearch() {
       guard !searchString.isEmpty else {
           searchResults = []
           return
       }

       isLoading = true
       let db = Firestore.firestore()

  
       db.collection("users")
           .whereField("username", isGreaterThanOrEqualTo: searchString)
           .whereField("username", isLessThanOrEqualTo: searchString + "\u{f8ff}")
           .getDocuments { snapshot, error in
               isLoading = false
               if let error = error {
                   print("Error fetching search results: \(error.localizedDescription)")
                   return
               }

               guard let documents = snapshot?.documents else {
                   searchResults = []
                   return
               }

               searchResults = documents.compactMap { doc -> User? in
                   guard let username = doc["username"] as? String,
                         let bio = doc["bio"] as? String,
                         let name = doc["name"] as? String,
                         let profileImageURL = doc["profileImageURL"] as? String,
                         let followerCount = doc["followerCount"] as? Int,
                         let followingCount = doc["followingCount"] as? Int,
                         let uid = doc["uid"] as? String else {
                       return nil
                   }

                   return User(
                       id: String(uid.hashValue),
                       bio: bio,
                       username: username,
                       password: "", // Optional field
                       profileImage: profileImageURL,
                       followers: [], // Not used here
                       following: [], // Not used here
                       followerCount: followerCount,
                       followingCount: followingCount,
                       posts: [], // Not used here
                       postsIDs: [] // Not used here
                   )
               }
           }
   }

}

#Preview {
   SearchPageView()
}
