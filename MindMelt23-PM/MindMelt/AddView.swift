//
//  AddView.swift
//  MindMelt
//
//  Created by Kyla Enriquez on 9/22/25.
//
import Foundation
import SwiftUI

struct AddView: View {
    @State var title: String = ""
    @State var selectedType: WatchlistItem.ContentType = .youtubeVideo
    @State var selectedCategory: WatchlistItem.WatchCategory = .quick
    @State var notes: String = ""
    @State var detectedYoutubeId: String?
    @State var isAutoFilled = false
    @State var thumbnailURL: String?
    
    @EnvironmentObject var watchlistManager : WatchlistManager
    @Environment(\.dismiss) private var dismiss
    
    @State var fakebutton = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack {
                    HStack {
                        Image("mm")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        
                        Text("Add New")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button("Clear") {
                        // clearForm()
                    }
                    .foregroundColor(.red)
                    .padding()
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        if isAutoFilled {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                
                                Text("Auto-filled from YT")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Content Title")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                            
                            TextField("  Paste content link or enter title ", text: $title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .cornerRadius(13)
                                .frame(height: 70)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Content Type")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                            
                            Picker("Type", selection: $selectedType) {
                                ForEach(WatchlistItem.ContentType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Picker("Type", selection: $selectedCategory) {
                                ForEach(WatchlistItem.WatchCategory.allCases, id: \.self) { category in
                                    VStack {
                                        Text(category.rawValue)
                                    }.tag(category)
                                }
                            }
                            .pickerStyle(.menu)
                            .accentColor(.red)
                            .background()
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                            
                            TextField("  Add any notes..", text: $notes, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3, reservesSpace: true)
                                .cornerRadius(13)
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 20) {
                            Button(action: saveItem) {
                                Text("Save to Watchlist")
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .padding()
                                    .background(title.isEmpty ? Color.gray : Color.red)
                                    .cornerRadius(13)
                            }
                            .disabled(title.isEmpty)
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            checkForYTurl()
        }
    }
    
    private func downloadImage(from url: URL) async -> Data? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            print("Error downloading image: \(error)")
            return nil
        }
    }


    private func checkForYTurl() {
        if let vidID = Helper.checkClipboardforYT() {
            print("📋 Extracted video ID: \(vidID)")

            detectedYoutubeId = vidID
            selectedType = .youtubeVideo
            isAutoFilled = true

            Task {
                let (title, thumbnailUrl) = await YouTubeAPI.fetchVideoData(for: vidID)

                DispatchQueue.main.async {
                    if !title.isEmpty {
                        self.title = title
                    }

                    if !thumbnailUrl.isEmpty {
                        self.thumbnailURL = thumbnailUrl
                    }

                    print("Title: \(self.title), Thumbnail URL: \(self.thumbnailURL ?? "No thumbnail URL")")
                }
            }
        } else {
            print("❌ No YouTube link found in clipboard.")
        }
    }



    private func saveItem() {
        guard !title.isEmpty else {
            print("Title is required.")
            return
        }
        
        let new = WatchlistItem(
            title: title,
            type: selectedType,
            category: selectedCategory,
            notes: notes,
            dateAdded: Date(),
            isWatched: false,
            thumbnailURL: thumbnailURL,
            youtubeID: detectedYoutubeId
        )

        watchlistManager.addItem(new)
        dismiss()
    }

    private func clearForm() {
        title = ""
        selectedType = .movie
        selectedCategory = .quick
        notes = ""
        detectedYoutubeId = nil
        thumbnailURL = nil
        isAutoFilled = false
    }
}

#Preview {
    AddView()
}

 
