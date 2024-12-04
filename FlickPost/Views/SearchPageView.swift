//
//  SearchPageView.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/12/24.
//

import SwiftUI

struct SearchPageView : View {
    @State var SearchString : String = ""
    var body: some View{
        TabView {
            Text ("Search Page")
        }
        .searchable(text: $SearchString)
    }
}

#Preview {
    SearchPageView()
}
