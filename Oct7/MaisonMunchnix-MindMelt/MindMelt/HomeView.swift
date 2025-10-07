//
//  HomeView.swift
//  MindMelt
//
//  Created by STUDENT on 9/30/25.
//


import Foundation
import SwiftUI

struct HomeView: View {
    @StateObject private var supabase = SupabaseManager.shared
    
    @State var showingQuickWatch = false
    @State var showingBingeWatch = false
    @State var showingRandomPick = false
    
    @EnvironmentObject var watchlistManager: WatchlistManager
//    @State var randomItem: WatchlistItem?
    
    @State private var showSidebar = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                
                HStack {
                    HStack {
                        Image("mm")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        
                        Text("M I N D M E L T")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            showSidebar = true
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.red)
                            .font(.title2)
                            .padding(.horizontal)
                    }


                }
               
                
                Spacer()
                
                Text("Ready to watch something?")
                    .foregroundColor(.black)
                    .font(.system(size: 18, weight: .bold, design: .default))
                
                HStack(spacing: 20){
                    StatCard(number: "\(watchlistManager.items.filter{!$0.isWatched}.count)", label: "Unwatched")
                    
                    StatCard(number: "\(watchlistManager.getQuickItems().count)", label:"Quick")
                    
                    StatCard(number: "\(watchlistManager.getBingeItems().count)", label:"Binge")
                }
                
                Spacer(minLength: 20)
                
                VStack(spacing: 15){
                    
                    Button(action: { showingQuickWatch = true }) {
                        HomeButtonContent(
                            icon: "clock.fill",
                            title: "Quick Watch",
                            subtitle: "Under 30 mins • \(watchlistManager.getQuickItems().count)",
                            color: .red
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingQuickWatch) {
                        NavigationView {
                            FilteredListView(
                                items: watchlistManager.getQuickItems(),
                                title: "Quick Watch"
                            )
                        }
                    }
                    
                    
                    
                    Button(action: { showingBingeWatch = true }) {
                        HomeButtonContent(
                            icon: "tv.fill",
                            title: "Binge Ready",
                            subtitle: "Movies and long content • \(watchlistManager.getBingeItems().count)",
                            color: .red
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingBingeWatch) {
                        NavigationView {
                            FilteredListView(
                                items: watchlistManager.getBingeItems(),
                                title: "Binge Ready"
                            )
                        }
                    }
                    
                    
                    Button(action: { showingRandomPick = true }) {
                        HomeButtonContent(
                            icon: "shuffle",
                            title: "Surprise me",
                            subtitle: "Random pick from watchlist",
                            color: .red
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingRandomPick) {
                        NavigationView {
                            RandomPickView(
                                item: watchlistManager.getRandomItem()
                            )
                        }
                    }
                }
                
                Spacer()
            }
            
            SidebarView(isShowing: $showSidebar).environmentObject(watchlistManager)
        }
    }
}

struct StatCard: View{
    let number : String
    let label : String
    
    var body : some View {
        VStack(spacing: 4){
            
            Text(number)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.red)
            
            
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            
        }
        .frame(width: 80, height: 60)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}



struct HomeButtonContent: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        
        HStack(spacing: 15){
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .clipShape(Circle())
                
            
            VStack(alignment: .leading, spacing: 4){
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.title3)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        
    }
}

private func logOut(){
    Task{
        do{
            try await SupabaseManager.shared.signout()
            print("User signed out")
        }catch{
            print("Signout error.")
        }
    }
}


#Preview {
    HomeView()
        .environmentObject(WatchlistManager())
}
