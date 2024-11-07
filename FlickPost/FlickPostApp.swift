//
//  FlickPostApp.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/4/24.
//

import SwiftUI
import Firebase

@main
struct FlickPostApp: App {
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
