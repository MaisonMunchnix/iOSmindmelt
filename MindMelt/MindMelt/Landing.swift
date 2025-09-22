//
//  Landing.swift
//  MindMelt
//
//  Created by Kyla Enriquez on 9/22/25.
//

import Foundation

import SwiftUI
 
struct Landing: View {
    @StateObject private var watchlistManager = WatchlistManager()
    var body: some View{
        
        ZStack{
            TabView{
                HomeView()
                    .tabItem{
                            Image(systemName: "house")
                            Text("Home")
                        }
                
                WatchList()
                    .tabItem{
                        Image(systemName: "star")
                        Text("Watch List")
                    }
                
                DoneWatching()
                    .tabItem{
                        Image(systemName: "checkmark")
                        Text("Done")
                    }
            }
            .environmentObject(watchlistManager)
            .onAppear {
                if SupabaseManager.shared.isAuthenticated {
                    Task {
                        await SupabaseManager.shared.watchlistManager?.syncWithSupabase()
                    }
                }
            }            .accentColor(.red)
        }
    }
}
 
 
#Preview {
    Landing()
}
