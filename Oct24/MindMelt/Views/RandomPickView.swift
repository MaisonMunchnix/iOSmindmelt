//
//  RandomPickView.swift
//  MindMelt
//

import SwiftUI

struct RandomPickView: View {
    @EnvironmentObject var watchlistManager: WatchlistManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var recommendation: (item: WatchlistItem?, reason: String?) = (nil, nil)
    @State private var isLoading = false
    @State private var isAnimating = false
    
    
    //for user mood
    @State private var showMoodPicker = true
    @State private var selectedMood: String?
    
    var body: some View {
        if showMoodPicker {
            MoodPickerView(selectedMood: $selectedMood) {
                showMoodPicker = false
                getAIRecommendation(mood: selectedMood)
            }
        } else {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    if isLoading {
                        // AI loading
                        VStack(spacing: 20) {
                            HStack(spacing: 8) {
                                ForEach(0..<3) { index in
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 12, height: 12)
                                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                                        .animation(
                                            .easeInOut(duration: 0.6)
                                            .repeatForever()
                                            .delay(Double(index) * 0.2),
                                            value: isAnimating
                                        )
                                }
                            }
                            .onAppear { isAnimating = true }
                            
                            Text("🤖 AI is analyzing...")
                                .foregroundColor(.black)
                                .font(.headline)
                            
                            VStack(spacing: 8) {
                                Text("• Reviewing your watch history")
                                Text("• Considering time of day")
                                Text("• Finding the perfect match")
                            }
                            .foregroundColor(.gray)
                            .font(.caption)
                        }
                        
                    } else if let item = recommendation.item {
                        // AI Recommendation Result
                        ScrollView {
                            VStack(spacing: 20) {
                                Text("✨")
                                    .font(.system(size: 60))
                                
                                Text("AI Recommends")
                                    .foregroundColor(.gray)
                                    .font(.headline)
                                
                                // Item card
                                VStack(spacing: 15) {
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
                                                Text("•")
                                                    .foregroundColor(.gray)
                                                Text(item.category.rawValue)
                                                    .foregroundColor(.red)
                                            }
                                            .font(.subheadline)
                                        }
                                        Spacer()
                                    }
                                    
                                    // AI Reasoning - THIS IS NEW
                                    // AI Reasoning
                                    if let reason = recommendation.reason, !reason.isEmpty {
                                        Divider()
                                        HStack(alignment: .top, spacing: 8) {
                                            Image(systemName: "brain")
                                                .foregroundColor(.blue)
                                                .font(.caption)
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Why this recommendation:")
                                                    .font(.caption2)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.gray)
                                                Text(reason)
                                                    .foregroundColor(.gray)
                                                    .font(.caption)
                                                    .italic()
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                            Spacer()
                                        }
                                    }
                                    
                                    // Notes
                                    if !item.notes.isEmpty {
                                        Divider()
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("Your notes:")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                            Text(item.notes)
                                                .font(.body)
                                                .foregroundColor(.gray)
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
                                .padding(.horizontal)
                                
                                // Action buttons
                                VStack(spacing: 15) {
                                    Button(action: {
                                        watchlistManager.toggleWatched(item)
                                        dismiss()
                                    }) {
                                        Text("Perfect! Mark as Watched")
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.green)
                                            .cornerRadius(10)
                                    }
                                    
                                    NavigationLink(destination: WatchlistItemDetailView(item: item)) {
                                        Text("View Details")
                                            .foregroundColor(.red)
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
                                        getNewRecommendation()
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.clockwise")
                                            Text("Get Different Recommendation")
                                        }
                                        .foregroundColor(.red)
                                        .fontWeight(.semibold)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 30)
                            }
                        }
                        
                    } else {
                        // Empty state
                        VStack(spacing: 20) {
                            Text("🎭")
                                .font(.system(size: 80))
                            
                            Text("Nothing to recommend!")
                                .foregroundColor(.black)
                                .font(.headline)
                            
                            Text("Add some items to your watchlist first, then come back for an AI recommendation.")
                                .foregroundColor(.gray)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button("Go to Watchlist") {
                                dismiss()
                            }
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("AI Pick")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // ADD THIS FUNCTION - Calls WatchlistManager's AI recommendation
    private func getAIRecommendation(mood: String? = nil) {
        print("🔍 RandomPickView: Received mood: \(mood ?? "nil")")

        isLoading = true
        
        Task {
            let result = await watchlistManager.getAIRecommendation(mood: mood)
            
            await MainActor.run {
                recommendation = result
                isLoading = false
                isAnimating = false
            }
        }
    }
    
    // ADD THIS FUNCTION - Gets a new recommendation
    private func getNewRecommendation() {
        recommendation = (nil, nil)
        getAIRecommendation(mood: selectedMood)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct MoodPickerView: View {
    @Binding var selectedMood: String?
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How are you feeling?")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                MoodButton(emoji: "😌", title: "Relaxed", mood: "relaxed", selectedMood: $selectedMood)
                MoodButton(emoji: "⚡️", title: "Energetic", mood: "energetic", selectedMood: $selectedMood)
                MoodButton(emoji: "🧠", title: "Want to Learn", mood: "learn", selectedMood: $selectedMood)
                MoodButton(emoji: "😴", title: "Bored", mood: "bored", selectedMood: $selectedMood)
                
                // Continue button - only enabled when a mood is selected
                Button(action: {
                    onContinue()  // Proceed to AI recommendation
                }) {
                    Text("Continue")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedMood != nil ? Color.blue : Color.gray.opacity(0.5))
                        .cornerRadius(10)
                }
                .disabled(selectedMood == nil)  // Disable if no mood selected
                
                Button("Skip (AI decides)") {
                    onContinue()  // Proceed without mood
                }
                .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
    }
}


struct MoodButton: View {
    let emoji: String
    let title: String
    let mood: String
    @Binding var selectedMood: String?
    
    var body: some View {
        Button(action: { selectedMood = mood }) {
            HStack {
                Text(emoji).font(.title2)
                Text(title).fontWeight(.semibold)
                Spacer()
                if selectedMood == mood {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(selectedMood == mood ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        RandomPickView()
            .environmentObject(WatchlistManager())
    }
}
