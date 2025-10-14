//
//  ContentView.swift
//  MindMelt
//
//  Created by Enriquez on 9/22/25.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var supabase = SupabaseManager.shared
    
    var body: some View {
        if supabase.isAuthenticated {
            NavigationView {
                Landing()
                    .navigationBarHidden(true) 
            }
        } else {
            Login()
        }
    }
}

