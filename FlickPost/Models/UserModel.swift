//
//  UserViewModel.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/13/24.
//

struct User : Codable, Identifiable {
    let id: Int
    let username: String
    let password : String
    let profileImage: String
    let followers : [User]
    let following : [User]
    let posts : [Post]
}
