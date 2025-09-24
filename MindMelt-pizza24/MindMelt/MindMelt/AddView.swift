//
//  AddView.swift
//  Watchlist
//
//  Created by STUDENT on 9/2/25.
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
    
    
    
    @State private var hasReminder = false
    @State private var reminderDate = Date()
    @State private var reminderTime = Date()
    @State private var showingReminderPicker = false
    @State private var reminderMessage = false
    
    
    @EnvironmentObject var watchlistManager : WatchlistManager
    @Environment(\.dismiss) private var dismiss
    
    @State var fakebutton = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
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
                         clearForm()
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
                            
                            TextField("  Enter title ", text: $title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .cornerRadius(13)
                                .frame(height: 70).autocorrectionDisabled(true)
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
                                .cornerRadius(13).autocorrectionDisabled(true) //
                        }
                        .padding(.horizontal)
                        
                        
                        VStack(alignment: .leading,  spacing: 12){
                            HStack{
                                Text("Set Reminder")
                                    .foregroundColor(.black)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Toggle(" ", isOn: $hasReminder)
                                    .labelsHidden()
                            }
                            .padding(.horizontal)
                            
                            if hasReminder {
                                VStack(spacing:15){
                                    VStack(alignment: .leading,spacing: 8){
                                        Text("Reminder date and time")
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                        
                                        DatePicker(
                                            "Date & Time",
                                            selection: $reminderDate,
                                            in: Date()...,
                                            displayedComponents: [.date, .hourAndMinute]
                                        )
                                        .labelsHidden()
                                        .datePickerStyle(.compact)
                                    }
                                    .padding(.horizontal)
                                    
                                    
                                    
                                    VStack(alignment: .leading, spacing: 8){
                                        Text("Quick Options")
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                        
                                        ScrollView(.horizontal, showsIndicators: false){
                                            HStack(spacing: 10){
                                                QuickReminderButton(title: "Tonight 8PM"){
                                                    setReminderTime(hour:20, daysFromNow: 0)
                                                }
                                                
                                                QuickReminderButton(title: "Tomorrow 7PM"){
                                                    setReminderTime(hour:19, daysFromNow: 1)
                                                }
                                                
                                                QuickReminderButton(title: "Weekend"){
                                                    setReminderTime()
                                                }
                                                
                                                QuickReminderButton(title: "Next week"){
                                                    setReminderTime(hour:20, daysFromNow: 7)
                                                }
                                            }
                                        }.padding(.horizontal)
                                    }
                                }
                                
                                VStack(alignment:.leading, spacing: 8){
                                    Text("Reminder Message (Optional)")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                    
                                    TextField("e.g., Recommended by a friend.")
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    
                                }
                                .padding(.horizontal)
                                
                                
                                if hasReminder {
                                    HStack{
                                        Image(systemName: "bell.fill")
                                            .foregroundColor(.blue)
                                        
                                        
                                        VStack(alignment: .leading, spacing:2){
                                            Text("Reminder set for:")
                                                .font(.caption)
                                                .foregroundcolor(.gray)
                                            
                                            
                                            Text(formatReminderDate(reminderDate))
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.blue)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                }
                            }
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(13)
                            .padding(.horizontal)
                        }
                        
                        
                        
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
            print("Extracted video ID: \(vidID)")

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
            print("No YouTube link found in clipboard.")
        }
    }
    
    private func setReminderTime(hour: Int, daysFromNow: Int){
        let calendar = Calendar.current
        let now = Date()
        
        if let newDate = calendar.date(byAdding: .day, value:  daysFromNow, to: now)
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
