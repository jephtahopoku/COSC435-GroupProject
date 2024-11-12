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
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
               
               URLSession.shared.dataTask(with: url) { data, response, error in
                   if let data = data {
                       if let decodedPosts = try? JSONDecoder().decode([Post].self, from: data) {
                           DispatchQueue.main.async {
                               self.posts = decodedPosts
                           }
                       }
                   }
               }.resume()
       }
}
