//
//  WatchList.swift
//  Watchlist
//
//  Created by STUDENT on 9/2/25.
//



import Foundation
import SwiftUI

struct WatchList: View {
    @State var showAdd = false
    @EnvironmentObject var watchlistManager: WatchlistManager
    
    var unwatchedItems: [WatchlistItem] {
        watchlistManager.items.filter { !$0.isWatched }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                VStack {
                    // Header
                    HStack {
                        HStack {
                            Image("mm")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                            
                            Text("Watch List")
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                        }
                        .padding()
                        
                        Spacer()
                        
                        Text("Edit").foregroundColor(.red).padding()
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .foregroundColor(.white)
                    
                    // Content Area
                    if unwatchedItems.isEmpty {
                        // Empty State
                        VStack {
                            Spacer()
                            
                            Text("Your watchlist is empty")
                                .foregroundColor(.black)
                                .font(.headline)
                            
                            Text("Add some content to get started!")
                                .foregroundColor(.gray)
                                .font(.caption)
                            
                            Spacer()
                        }
                    } else {
                        // List of Items
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(unwatchedItems) { item in
                                    NavigationLink(destination: WatchlistItemDetailView(item: item)) {
                                        WatchlistItemRow(item: item)
                                            .padding(.horizontal)
                                    }
                                    .buttonStyle(PlainButtonStyle()) // Prevents blue highlight
                                }
                            }
                            .padding(.top)
                        }
                    }
                    
                    // Add Button
                    VStack {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                showAdd = true
                            }, label: {
                                Text("+")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .padding()
                                    .padding(.horizontal)
                                    .background(Color.red)
                                    .cornerRadius(100)
                            })
                            
                            NavigationLink(destination: AddView(), isActive: $showAdd) {
                                EmptyView()
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// Row component to display each watchlist item
struct WatchlistItemRow: View {
    let item: WatchlistItem
    @EnvironmentObject var watchlistManager: WatchlistManager
    
    var body: some View {
        HStack {
            if let thumbnailURL = item.thumbnailURL, let url = URL(string: thumbnailURL) {
                AsyncImage(url: url) { image in
                    image.resizable()
                         .scaledToFit()
                         .frame(width: 50, height: 50)
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                }
            } else {
                Image(systemName: "film")
                    .foregroundColor(.red)
                    .frame(width: 50, height: 50)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                HStack {
                    Text(item.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text(item.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                if !item.notes.isEmpty {
                    Text(item.notes)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Button(action: {
                watchlistManager.toggleWatched(item)
            }) {
                Image(systemName: item.isWatched ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.red)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}


// Detail View for individual watchlist items
struct WatchlistItemDetailView: View {
    let item: WatchlistItem
    @EnvironmentObject var watchlistManager: WatchlistManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    // Thumbnail Image from YouTube (if available)
                    if let thumbnailUrl = item.thumbnailURL, let url = URL(string: thumbnailUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                 .scaledToFit()
                                 .frame(width: 300, height: 250)
                        } placeholder: {
                            ProgressView()
                        }
                        .padding(.horizontal)
                    }
                    
                    
                    HStack {
                        
                        Image(systemName: item.type.iconName)
                            .foregroundColor(.red)
                            .font(.system(size: 40))
                        
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                            
                            HStack {
                                Text(item.type.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text("•")
                                    .foregroundColor(.gray)
                                
                                Text(item.category.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    
                    Divider()
                    
                    // Details section
                    VStack(alignment: .leading, spacing: 15) {
                        // Date added
                        DetailRow(title: "Date Added", value: formattedDate(item.dateAdded))
                        
                        // Category description
                        DetailRow(title: "Category", value: "\(item.category.rawValue) (\(item.category.description))")
                        
                        // Notes section
                        if !item.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Notes")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Text(item.notes)
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        
                        // YouTube ID if available
                        if let youtubeID = item.youtubeID, !youtubeID.isEmpty {
                            DetailRow(title: "YouTube ID", value: youtubeID)
                        }
                        
                        // Status
                        DetailRow(title: "Status", value: item.isWatched ? "✅ Watched" : "⏱️ Not Watched")
                    }
                    .padding()
                    
                    Spacer(minLength: 100)
                }
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        watchlistManager.toggleWatched(item)
                    }) {
                        HStack {
                            Image(systemName: item.isWatched ? "arrow.uturn.backward" : "checkmark.circle")
                            Text(item.isWatched ? "Mark as Unwatched" : "Mark as Watched")
                        }
                    }
                    
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete")
                        }
                    }
                    .foregroundColor(.red)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.red)
                }
            }
        }
        .alert("Delete Item", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                watchlistManager.deleteItem(item)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete '\(item.title)'? This action cannot be undone.")
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}



// Helper view for detail rows
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            
            Text(value)
                .font(.body)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    WatchList()
        .environmentObject(WatchlistManager())
}
