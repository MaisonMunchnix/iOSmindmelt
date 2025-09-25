//
//  DoneWatching.swift
//  MindMelt
//
//  Created by Kyla Enriquez on 9/22/25.
//
import SwiftUI

struct DoneWatching: View {
    @EnvironmentObject var watchlistManager: WatchlistManager
    
    var watchedItems: [WatchlistItem] {
        watchlistManager.items.filter { $0.isWatched }
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    HStack {
                        Image("mm")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        
                        Text("Done Watching")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        clearAllWatchedItems()
                    }) {
                        Text("Clear")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(.black)
                
                // Content Area
                if watchedItems.isEmpty {
                    // Empty State
                    VStack {
                        Spacer()
                        
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No completed items")
                            .foregroundColor(.black)
                            .font(.headline)
                            .padding(.top)
                        
                        Text("Items you mark as watched will appear here")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                } else {
                    // List of Watched Items
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(watchedItems) { item in
                                WatchedItemRow(item: item)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }
                }
            }
        }
    }
    
    private func clearAllWatchedItems() {
        let watchedItems = watchlistManager.items.filter { $0.isWatched }
        for item in watchedItems {
            watchlistManager.deleteItem(item)
        }
    }
}

// Row component specifically for watched items
struct WatchedItemRow: View {
    let item: WatchlistItem
    @EnvironmentObject var watchlistManager: WatchlistManager
    
    var body: some View {
        HStack {
            // Checkmark icon
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.title3)
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .strikethrough() // Shows it's completed
                
                HStack {
                    Text(item.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text(item.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.red)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text("Watched")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                if !item.notes.isEmpty {
                    Text(item.notes)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                // Date watched (using dateAdded as proxy since we don't have dateWatched)
                Text("Completed on \(formattedDate(item.dateAdded))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Options menu
            Menu {
                Button(action: {
                    // Mark as unwatched (move back to watchlist)
                    watchlistManager.toggleWatched(item)
                }) {
                    Label("Mark as Unwatched", systemImage: "arrow.uturn.backward")
                }
                
                Button(action: {
                    // Delete completely
                    watchlistManager.deleteItem(item)
                }) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.gray)
                    .font(.title2)
            }

        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    DoneWatching()
        .environmentObject(WatchlistManager())
}
