//
//  HomeScreen.swift
//  FlickPost
//
//  Created by Tyler Watkins on 11/11/24.
//

import SwiftUI
import PhotosUI

struct HomeScreenView : View {
@ObservedObject var viewModel = PostViewModel()
@State var isDoubledTapped: Bool = false
@State var presentSearch : Bool = false
@State var selectedPost : Post? = nil
@State var photoPickerItem : PhotosPickerItem? = nil
    

    var body: some View {
        NavigationView {
                VStack {
                    List(viewModel.posts){post in
                        Text(post.username)
                        AsyncImage(url: URL(string: "\(post.imageUrl)")){Image in
                            Image
                                .image?.scaledToFit()
                        }.onTapGesture(count: 2) {
                            isDoubledTapped = true
                        }
                        HStack (spacing: 10){
                            Button (action: {
                            }){
                                Image(systemName: isDoubledTapped ? "heart.fill" : "heart")
                                    .foregroundStyle(.black)
                            }
                            Text("\(post.likes)")
                            Button (action: {}){
                                Image(systemName: "message")
                                    .foregroundStyle(.black)
                            }
                            Button (action: {}){
                                Image(systemName: "paperplane")
                                    .foregroundStyle(.black)
                            }
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
                .safeAreaInset(edge: .bottom , spacing: 10){
                    HStack (spacing:10){
                        
                        Button(action: {
                        }){
                            Image(systemName: "house")
                                .font(.system(size: 30))
                                .foregroundStyle(.black)
                                .frame(maxWidth:.infinity)
                        }
                        Button(action: {
                            presentSearch.toggle()
                        }){
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 30))
                                .foregroundStyle(.black)
                                .frame(maxWidth:.infinity)
                        }
                        PhotosPicker(selection: $photoPickerItem, label: {
                            Image(systemName: "plus.app")
                                .font(.system(size: 30))
                                .foregroundStyle(.black)
                                .frame(maxWidth:.infinity)
                        })
                        Button(action: {}){
                            Image(systemName: "person.circle")
                                .font(.system(size: 30))
                                .foregroundStyle(.black)
                                .frame(maxWidth:.infinity)
                        }
                    }.background(.thinMaterial)
                }
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
                            Image(systemName: "paperplane")
                                .foregroundStyle(.black)
                    }
                }
        }
    } .onAppear {
        viewModel.getData()
    }.sheet(isPresented: $presentSearch){
            SearchPageView()
    }
    }
}
#Preview {
    HomeScreenView()
}

