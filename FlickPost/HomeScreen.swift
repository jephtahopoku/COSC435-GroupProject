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
                VStack {
                    List(viewModel.posts){post in
                        Text(post.username)
                        AsyncImage(url: URL(string: "\(post.imageUrl)")){Image in
                            Image
                                .image?.scaledToFit()
                        }
                        HStack {
                            Button (action: {}){
                                Image(systemName: "heart")
                                    .foregroundStyle(.black)
                            }
                            Text("\(post.likes)")
                        }
                    Text("\(post.username) \(post.title)")
                            .font(.subheadline)
                            .bold()
                    }
                    .listStyle(PlainListStyle())
                    .listRowInsets(EdgeInsets())
                }
                .background(
                    LinearGradient (
                    gradient: Gradient(colors: [Color.indigo, Color.purple, Color.blue, Color.green]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .edgesIgnoringSafeArea(.all)
                    )
                .navigationTitle("FlickPost")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {}) {
                            Image(systemName: "heart")
                                .foregroundStyle(.black)
                }
            }
                    ToolbarItem(placement: .topBarTrailing){
                        Button(action: {}){
                            Image(systemName: "message")
                                .foregroundStyle(.black)
                        }
                    }
        }
        }
        .onAppear {
            viewModel.getData()
                }
            }
    }
#Preview {
    HomeScreenView()
}

