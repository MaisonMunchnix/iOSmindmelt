//
//  FilteredListView.swift
//  MindMelt
//
//  Created by STUDENT on 9/30/25.
//

//
import SwiftUI

struct FilteredListView: View {
    let items: [WatchlistItem]
    let title: String
    @EnvironmentObject var watchlistManager: WatchlistManager
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                if items.isEmpty {
                    // Empty State
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "list.bullet")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No \(title.lowercased()) items")
                            .foregroundColor(.black)
                            .font(.headline)
                        
                        Text("Add some content to your watchlist and categorize it as '\(title)' to see it here!")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                } else {
                    // List of Items
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(items) { item in
                                NavigationLink(destination: WatchlistItemDetailView(item: item)) {
                                    FilteredItemRow(item: item)
                                        .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.top)
                    }
                    
                    // Stats at bottom
                    VStack {
                        Divider()
                        
                        HStack {
                            Text("\(items.count) item\(items.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(title)
                                .font(.caption)
                                .foregroundColor(.red)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                    }
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
    }
}

// Row component for filtered lists
struct FilteredItemRow: View {
    let item: WatchlistItem
    @EnvironmentObject var watchlistManager: WatchlistManager
    
    var body: some View {
        HStack {
            // Icon based on content type
            Image(systemName: item.type.iconName)
                .foregroundColor(.red)
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.title3)
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                HStack {
                    Text(item.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text(item.category.description)
                        .font(.caption)
                        .foregroundColor(.red)
                    
                    if !item.notes.isEmpty {
                        Text("•")
                            .foregroundColor(.gray)
                        
                        Text("Has notes")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                // Date added
                Text("Added \(timeAgo(item.dateAdded))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Quick action button
            Button(action: {
                watchlistManager.toggleWatched(item)
            }) {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func timeAgo(_ date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: date, to: now)
        
        if let days = components.day, days > 0 {
            return "\(days) day\(days == 1 ? "" : "s") ago"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else {
            return "Just now"
        }
    }
}

#Preview {
    NavigationView {
        FilteredListView(
            items: [
                WatchlistItem(title: "Sample Movie", type: .movie, category: .long),
                WatchlistItem(title: "Quick Video", type: .youtubeVideo, category: .quick)
            ],
            title: "Quick Watch"
        )
        .environmentObject(WatchlistManager())
    }
}
