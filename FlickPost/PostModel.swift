//
//  PostModel.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/11/24.
//

import SwiftUI

struct Post : Codable, Identifiable {
    var id: UUID = UUID()
    let username: String
    let image: String
    let caption: String
    let timestamp: Date
}
