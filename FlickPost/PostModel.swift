//
//  PostModel.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/11/24.
//

import SwiftUI

struct Post : Codable, Identifiable {
        let id: Int
        let userId: Int
        let title: String
        let body: String
        
        // Additional Instagram-like properties
        var imageUrl: String {
            "https://picsum.photos/id/\(id)/400/400"
        }
        var likes: Int {
            Int.random(in: 100...10000)
        }
        var username: String {
            "user_\(userId)"
        }
}
