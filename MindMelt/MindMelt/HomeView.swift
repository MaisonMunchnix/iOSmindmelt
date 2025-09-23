//
//  HomeView.swift
//  Watchlist
//
//  Created by STUDENT on 9/2/25.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @State var showingQuickWatch = false
    @State var showingBingeWatch = false
    @State var showingRandomPick = false
    
    @EnvironmentObject var watchlistManager: WatchlistManager
    @State var randomItem: WatchlistItem?
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: {
                        print("Button tapped")
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .padding(.horizontal)
                    }
                }

                Spacer()
                
                Text("Ready to watch something?")
                    .foregroundColor(.black)
                    .font(.system(size: 18, weight: .bold, design: .default))
                
                Button(action: {
                    showingQuickWatch = true
                }, label: {
                    Text("Quick watch")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .padding()
                        .padding(.horizontal)
                        .background(Color.red)
                        .cornerRadius(13)
                })
                
                Button(action: {
                    showingBingeWatch = true
                }, label: {
                    Text("Binge watch")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .padding()
                        .padding(.horizontal)
                        .background(Color.red)
                        .cornerRadius(13)
                })
                
                Button(action: {
                    randomItem = watchlistManager.getRandomItem()
                    showingRandomPick = true
                }, label: {
                    Text("Random Pick")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .padding()
                        .padding(.horizontal)
                        .background(Color.red)
                        .cornerRadius(13)
                })
                
                // Navigation Links
                NavigationLink(
                    destination: RandomPickView(item: randomItem),
                    isActive: $showingRandomPick
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: FilteredListView(
                        items: watchlistManager.getBingeItems(),
                        title: "Binge Ready"
                    ),
                    isActive: $showingBingeWatch
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: FilteredListView(
                        items: watchlistManager.getQuickItems(),
                        title: "Quick Watch"
                    ),
                    isActive: $showingQuickWatch
                ) {
                    EmptyView()
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(WatchlistManager())
}
