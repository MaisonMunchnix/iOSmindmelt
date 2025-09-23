//
//  ContentView.swift
//  MindMelt
//
//  Created by STUDENT on 9/15/25.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var supabase = SupabaseManager.shared
    
    var body: some View {
        if supabase.isAuthenticated {
            Landing()
        } else {
            Login()
        }
    }
}

#Preview {
    ContentView()
}
 
