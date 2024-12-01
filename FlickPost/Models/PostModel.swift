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
    var title: String
    var body: String
    var imageUrl: String
    var timestamp: Date
    var username: String 
}

