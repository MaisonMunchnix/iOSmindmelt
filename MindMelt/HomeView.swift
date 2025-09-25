//
//  HomeView.swift
//  MindMelt
//
//  Created by Kyla Enriquez on 9/22/25.
//



import Foundation
import SwiftUI

struct HomeView: View {
    @StateObject private var supabase = SupabaseManager.shared
    
    @State var showingQuickWatch = false
    @State var showingBingeWatch = false
    @State var showingRandomPick = false
    
    @EnvironmentObject var watchlistManager: WatchlistManager
    @State var randomItem: WatchlistItem?
    
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
                        logOut()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
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
                    
                    HomeButton(
                        icon: "clock.fill",
                        title: "Quick Watch",
                        subtitle: "Under 30 mins . \(watchlistManager.getQuickItems().count)",
                        color: .red
                    ){
                        showingQuickWatch = true
                    }
                    
                    
                    HomeButton(
                        icon: "tv.fill",
                        title: "Binge Ready",
                        subtitle: "Movies and long content . \(watchlistManager.getBingeItems().count)",
                        color: .red
                    ){
                        showingQuickWatch = true
                    }
                    
                    
                    HomeButton(
                        icon: "shuffle",
                        title: "Surprise Me",
                        subtitle: "Random pick from watchlist",
                        color: .red
                    ){
                        randomItem = watchlistManager.getRandomItem()
                        showingQuickWatch = true
                    }
                    
                    
                }
                
                
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



struct HomeButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action){
            HStack(spacing: 15){
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height:50)
                    .background(color)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4){
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
                
                
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .buttonStyle(PlainButtonStyle())
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
