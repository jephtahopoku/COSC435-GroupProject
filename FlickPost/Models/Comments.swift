//
//  Comments.swift
//  FlickPost
//
//  Created by Tyler Watkins on 12/7/24.
//

import Foundation

struct Comments : Codable, Identifiable {
    let id : Int
    let author : User
    let content : String
    let created : Date
}
