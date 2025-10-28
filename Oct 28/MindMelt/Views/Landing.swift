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
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showSidebar = false
    
    var body: some View{
        ZStack{
            themeManager.backgroundColor.ignoresSafeArea()
            
            TabView {
                NavigationView {
                    HomeView(showSidebar: $showSidebar)
                }
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                
                SearchAndFilterView()
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
            .environmentObject(themeManager)
            .onAppear {
                watchlistManager.debugAuthStatus()
                
                Task {
                    await watchlistManager.syncWithSupabase()
                }
            }
            .accentColor(.red)
            
            SidebarView(isShowing: $showSidebar)
               .environmentObject(watchlistManager)
               .environmentObject(themeManager)
        }
    }
}
 
#Preview {
    Landing()
        .environmentObject(ThemeManager.shared)
}

//import Foundation
//
//import SwiftUI
// 
//struct Landing: View {
//    @StateObject private var watchlistManager = WatchlistManager()
//    @State private var showSidebar = false
//    
//    var body: some View{
//        
//        ZStack{
//            
//            
//            TabView {
//                NavigationView {
//                    HomeView(showSidebar: $showSidebar)
//                }
//                .tabItem {
//                    Image(systemName: "house")
//                    Text("Home")
//                }
//                
//                SearchAndFilterView()
//                    .tabItem {
//                        Image(systemName: "star")
//                        Text("Watch List")
//                    }
//                
//                DoneWatching()
//                    .tabItem {
//                        Image(systemName: "checkmark")
//                        Text("Done")
//                    }
//            }
//            .environmentObject(watchlistManager)
//            .onAppear {
//                watchlistManager.debugAuthStatus()
//                
//                Task {
//                    await watchlistManager.syncWithSupabase()
//                }
//            }
//            .accentColor(.red)
//            
//            SidebarView(isShowing: $showSidebar)
//               .environmentObject(watchlistManager)
//        }
//    }
//}
// 
// 
//#Preview {
//    Landing()
//}
