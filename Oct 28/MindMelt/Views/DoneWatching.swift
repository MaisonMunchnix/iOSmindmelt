//
//  DoneWatching.swift
//  MindMelt
//
//  Created by STUDENT on 9/30/25.
//

import SwiftUI

struct DoneWatching: View {
    @EnvironmentObject var watchlistManager: WatchlistManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var watchedItems: [WatchlistItem] {
        watchlistManager.items.filter { $0.isWatched }
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    HStack {
                        Image("mm")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        
                        Text("Done Watching")
                            .foregroundColor(themeManager.primaryTextColor)
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
                    .foregroundColor(themeManager.borderColor)
                
                // Content Area
                if watchedItems.isEmpty {
                    // Empty State
                    VStack {
                        Spacer()
                        
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(themeManager.secondaryTextColor)
                        
                        Text("No completed items")
                            .foregroundColor(themeManager.primaryTextColor)
                            .font(.headline)
                            .padding(.top)
                        
                        Text("Items you mark as watched will appear here")
                            .foregroundColor(themeManager.secondaryTextColor)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                } else {
                    // watched items
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
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            // Checkmark icon
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(themeManager.secondaryTextColor)
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.title3)
                    .foregroundColor(themeManager.primaryTextColor)
                    .lineLimit(2)
                    .strikethrough() // Shows it's completed
                
                HStack {
                    Text(item.type.rawValue)
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                    
                    Text("•")
                        .foregroundColor(themeManager.secondaryTextColor)
                    
                    Text(item.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.red)
                    
                    Text("•")
                        .foregroundColor(themeManager.secondaryTextColor)
                    
                    Text("Watched")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                if !item.notes.isEmpty {
                    Text(item.notes)
                        .font(.caption2)
                        .foregroundColor(themeManager.secondaryTextColor)
                        .lineLimit(1)
                }
                
                // Date watched (using dateAdded as proxy since we don't have dateWatched)
                Text("Completed on \(formattedDate(item.dateAdded))")
                    .font(.caption2)
                    .foregroundColor(themeManager.secondaryTextColor)
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
                    .foregroundColor(themeManager.secondaryTextColor)
                    .font(.title2)
            }

        }
        .padding()
        .background(themeManager.cardBackgroundColor)
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
