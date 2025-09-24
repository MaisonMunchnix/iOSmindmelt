//
//  RandomPickView.swift
//  Watchlist
//
//  Created by STUDENT on 9/2/25.
//

import SwiftUI

struct RandomPickView: View {
    let item: WatchlistItem?
    @EnvironmentObject var watchlistManager: WatchlistManager
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                if let item = item {
                    // Dice animation
                    Text("🎲")
                        .font(.system(size: 80))
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(.easeInOut(duration: 1.0).repeatCount(3), value: isAnimating)
                    
                    VStack(spacing: 15) {
                        Text("Your random pick:")
                            .foregroundColor(.gray)
                            .font(.headline)
                        
                        // Item card
                        VStack(spacing: 15) {
                            // Icon and title
                            HStack {
                                Image(systemName: item.type.iconName)
                                    .foregroundColor(.red)
                                    .font(.system(size: 30))
                                
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                        .foregroundColor(.black)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.leading)
                                    
                                    HStack {
                                        Text(item.type.rawValue)
                                            .foregroundColor(.gray)
                                            .font(.subheadline)
                                        
                                        Text("•")
                                            .foregroundColor(.gray)
                                        
                                        Text(item.category.rawValue)
                                            .foregroundColor(.red)
                                            .font(.subheadline)
                                    }
                                }
                                Spacer()
                            }
                            
                            // Category description
                            HStack {
                                Text(item.category.description)
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                    .italic()
                                Spacer()
                            }
                            
                            // Notes if available
                            if !item.notes.isEmpty {
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Your notes:")
                                        .foregroundColor(.black)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    
                                    Text(item.notes)
                                        .foregroundColor(.gray)
                                        .font(.body)
                                }
                            }
                            
                            // Date added
                            Divider()
                            
                            HStack {
                                Text("Added \(formattedDate(item.dateAdded))")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                Spacer()
                            }
                        }
                        .padding(20)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.red.opacity(0.3), lineWidth: 2)
                        )
                    }
                    .padding(.horizontal)
                    
                    // Action buttons
                    VStack(spacing: 15) {
                        Button(action: {
                            watchlistManager.toggleWatched(item)
                            dismiss()
                        }) {
                            Text("Mark as Watched")
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                        
                        NavigationLink(destination: WatchlistItemDetailView(item: item)) {
                            Text("View Details")
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.red, lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            getNewRandomPick()
                        }) {
                            Text("Pick Something Else")
                                .foregroundColor(.gray)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.horizontal)
                    
                } else {
                    // No items available
                    VStack(spacing: 20) {
                        Text("🎭")
                            .font(.system(size: 80))
                        
                        Text("Nothing to pick from!")
                            .foregroundColor(.black)
                            .font(.headline)
                        
                        Text("Add some items to your watchlist first, then come back for a random pick.")
                            .foregroundColor(.gray)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Go to Watchlist")
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Random Pick")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isAnimating = true
            
            // Stop animation after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                isAnimating = false
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func getNewRandomPick() {
        // This would trigger getting a new random item
        // You might want to implement this by going back and selecting again
        dismiss()
    }
}

#Preview {
    NavigationView {
        RandomPickView(
            item: WatchlistItem(
                title: "Sample Movie",
                type: .movie,
                category: .long,
                notes: "Recommended by friend"
            )
        )
        .environmentObject(WatchlistManager())
    }
}
