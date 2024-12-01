import FirebaseAuth
import FirebaseFirestore

class CreateAccountViewModel: ObservableObject {
    @Published var isUserCreated = false
    @Published var errorMessage = ""

    func createAccount(email: String, password: String, username: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
            
                let db = Firestore.firestore()
                db.collection("users").document(result!.user.uid).setData([
                    "username": username,
                    "email": email,
                    "profileImageUrl": "", 
                    "followers": [],
                    "following": []
                ]) { error in
                    if let error = error {
                        self.errorMessage = "Error saving user data: \(error.localizedDescription)"
                    } else {
                        self.isUserCreated = true
                    }
                }
            }
        }
    }
}


