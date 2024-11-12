//
//  PostViewModel.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/11/24.
//

import SwiftUI

class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading : Bool = false
    
    func getData() {
        isLoading = true
        guard let url = URL(string: "https://randomuser.me/api/?results=25")else {return}
        
        URLSession.shared.dataTask(with: url) {data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else { return }
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode([Post].self, from: data)
                    DispatchQueue.main.async {
                        self.posts = decodedData
                        self.isLoading = false
                    }
                } catch{
                    print("Error Decoding JSON \(error.localizedDescription)")
                }
            }
            
        }.resume()
    }
}
