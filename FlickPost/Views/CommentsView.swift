//
//  CommentsView.swift
//  FlickPost
//
//  Created by Tyler Watkins on 12/7/24.
//

import Foundation
import SwiftUI

struct CommentsView : View {
    @Binding var post : Post?
    var body : some View {
        VStack {
            Text("Comments")
                .font(.title)
        }
    }
}
