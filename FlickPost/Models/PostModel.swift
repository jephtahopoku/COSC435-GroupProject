//
//  PostModel.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/11/24.
//

import Foundation

struct Post: Identifiable, Codable {
    var id: String
    var userId: String
    var username: String
    var title: String
    var body: String
    var imageUrl: String
    var timestamp: Date
    var likes : Int
    var likedBy : [String]
    
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)
            self.userId = try container.decode(String.self, forKey: .userId)
            self.username = try container.decode(String.self, forKey: .username)
            self.title = try container.decode(String.self, forKey: .title)
            self.body = try container.decode(String.self, forKey: .body)
            self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
            self.timestamp = try container.decode(Date.self, forKey: .timestamp)
            self.likes = try container.decode(Int.self, forKey: .likes)
            self.likedBy = try container.decodeIfPresent([String].self, forKey: .likedBy) ?? [] // Default to empty array if nil
        }
}

