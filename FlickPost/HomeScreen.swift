//
//  HomeScreen.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/11/24.
//

import SwiftUI

struct HomeScreenView : View {
@ObservedObject var viewModel = PostViewModel()
    var body: some View {
        NavigationView {
            ScrollView{
                List (viewModel.posts){post in
                    Text(post.username)
                    }
                }
                    .navigationTitle("FlickPost")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {}) {
                                Image(systemName: "heart")
                                    .foregroundStyle(.black)
                            }
                        }
                    }
        } .onAppear{
            viewModel.getData()
        }
        }
        
    }


#Preview {
    HomeScreenView()
}

