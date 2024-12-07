//
//  PostViewModel.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/11/24.
//

import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var PostImage : UIImage? = nil
    @Published var PostImageURL : String? = nil
    
    
    
    func uploadPostToFirebase(PostImage : UIImage, completion: @escaping (String?, Error?) -> Void) {
        let user = Auth.auth().currentUser
        guard let imageData = PostImage.jpegData(compressionQuality: 0.75) else {
        completion(nil, NSError(domain: "com.yourapp.error", code: 1, userInfo: ["message": "Failed to convert image to data"]))
        return
      }

      let storage = Storage.storage()
        let storageRef = storage.reference().child("user_posts/\(user!.uid).jpg")

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
    
    func savePost(post: Post) {
        
        guard let postImage = PostImage else {
            print("Error uploading image: No image URL")
            return
        }
        
        uploadPostToFirebase(PostImage: postImage) { PostImageURL, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                // Handle error, e.g., show error message to user
                return
            }
        }
        
        let db = Firestore.firestore()
        db.collection("posts").addDocument(data: [
            "userId": post.userId,
            "username" : post.username,
            "title": post.title,
            "body": post.body,
            "imageUrl": post.imageUrl,
            "timestamp": post.timestamp,
            "likes" : post.likes,
            "likedBy" : [post.likedBy]
        ]) { error in
            if let error = error {
                print("Error saving post: \(error.localizedDescription)")
            } else {
                print("Post saved successfully!")
            }
        }
    }
}




