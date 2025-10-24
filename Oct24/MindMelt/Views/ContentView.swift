//
//  ContentView.swift
//  MindMelt
//
//  Created by Enriquez on 9/22/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var supabase = SupabaseManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        if supabase.isAuthenticated {
            NavigationView {
                Landing()
                    .navigationBarHidden(true)
            }
            .environmentObject(themeManager)
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        } else {
            Login()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
}
//
//import SwiftUI
//
//struct ContentView: View {
//    @StateObject private var supabase = SupabaseManager.shared
//    
//    var body: some View {
//        if supabase.isAuthenticated {
//            NavigationView {
//                Landing()
//                    .navigationBarHidden(true) 
//            }
//        } else {
//            Login()
//        }
//    }
//}

