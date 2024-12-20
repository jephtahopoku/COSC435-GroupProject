//
//  UserViewModel.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/13/24.
//

struct User : Codable, Identifiable {
    let id: String
    let bio: String
    let name: String
    let username: String
    let password : String
    let profileImage: String
    let followers : [String]
    let following : [String]
    var followerCount : Int
    var followingCount : Int
    let posts : [Post]
    let postsIDs : [String]
}
