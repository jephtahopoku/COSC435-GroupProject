//
//  PostViewModel.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/11/24.
//

import FirebaseFirestore
import FirebaseStorage

class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    func savePost(post: Post) {
        let db = Firestore.firestore()
        db.collection("posts").addDocument(data: [
            "userId": post.userId,
            "title": post.title,
            "body": post.body,
            "imageUrl": post.imageUrl,
            "timestamp": post.timestamp
        ]) { error in
            if let error = error {
                print("Error saving post: \(error.localizedDescription)")
            } else {
                print("Post saved successfully!")
            }
        }
    }
}




