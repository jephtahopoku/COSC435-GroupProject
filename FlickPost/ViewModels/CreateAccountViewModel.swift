import FirebaseAuth
import FirebaseFirestore

class CreateAccountViewModel: ObservableObject {
    @Published var isUserCreated = false
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var name : String = ""
    @Published var isPasswordVisible: Bool = false
    @Published var errorMessage: String = ""
    @Published var isAuthenticated: Bool = false
    
    func createAccount(email: String, password:String, name:String, username:String){
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = "Failed to create account: \(error.localizedDescription)"
                return
            }

            // User created successfully
            guard let user = authResult?.user else {
                self.errorMessage = "Failed to fetch user details."
                return
            }

            saveUserProfile(uid: user.uid, email: user.email!, name: self.name, username: self.username)
        }
        func saveUserProfile(uid: String, email:String, name:String, username:String) {
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "uid": uid,
                "email": email,
                "name": name,
                "username": username,
                "bio": "Welcome to FlickPost!",
                "profileImageURL": ""  // Placeholder for profile image
            ]

            db.collection("users").document(uid).setData(userData) { error in
                if let error = error {
                    self.errorMessage = "Failed to save profile: \(error.localizedDescription)"
                } else {
                    DispatchQueue.main.async {
                        self.isAuthenticated = true
                    }
                }
            }
        }
    }


//    func createAccount(email: String, password: String, username: String) {
//        Auth.auth().createUser(withEmail: email, password: password) { result, error in
//            if let error = error {
//                self.errorMessage = error.localizedDescription
//            } else {
//            
//                let db = Firestore.firestore()
//                db.collection("users").document(result!.user.uid).setData([
//                    "username": username,
//                    "email": email,
//                    "profileImageUrl": "", 
//                    "followers": [],
//                    "following": []
//                ]) { error in
//                    if let error = error {
//                        self.errorMessage = "Error saving user data: \(error.localizedDescription)"
//                    } else {
//                        self.isUserCreated = true
//                    }
//                }
//            }
//        }
//    }
}


