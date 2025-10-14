//
//  Landing.swift
//  MindMelt
//
//  Created by STUDENT on 9/30/25.
//


import Foundation

import SwiftUI
 
struct Landing: View {
    @StateObject private var watchlistManager = WatchlistManager()
    @State private var showSidebar = false
    
    var body: some View{
        
        ZStack{
            
            
            TabView {
                NavigationView {
                    HomeView(showSidebar: $showSidebar)
                }
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                
                WatchList()
                    .tabItem {
                        Image(systemName: "star")
                        Text("Watch List")
                    }
                
                DoneWatching()
                    .tabItem {
                        Image(systemName: "checkmark")
                        Text("Done")
                    }
            }
            .environmentObject(watchlistManager)
            .onAppear {
                watchlistManager.debugAuthStatus()
                
                Task {
                    await watchlistManager.syncWithSupabase()
                }
            }
//            .onAppear {
//                if SupabaseManager.shared.isAuthenticated {
//                    Task {
//                        await SupabaseManager.shared.watchlistManager?.syncWithSupabase()
//                    }
//                }
//            }
            .accentColor(.red)
            
            SidebarView(isShowing: $showSidebar)
               .environmentObject(watchlistManager)
        }
    }
}
 
 
#Preview {
    Landing()
}
