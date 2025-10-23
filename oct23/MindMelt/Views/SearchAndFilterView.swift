//
//  SearchAndFilterView.swift
//  MindMelt
//
//  Created by STUDENT on 10/23/25.
//

import SwiftUI

struct SearchAndFilterView: View {
    @EnvironmentObject var watchlistManager: WatchlistManager
    @State private var searchText = ""
    @State private var selectedContentType: WatchlistItem.ContentType?
    @State private var selectedCategory: WatchlistItem.WatchCategory?
    @State private var showWatchedOnly = false
    @State private var showUnwatchedOnly = false
    @State private var sortBy: SortOption = .dateAdded
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var showAdd = false
    
    enum SortOption: String, CaseIterable {
        case dateAdded = "Date Added"
        case title = "Title"
        case type = "Content Type"
        
        var iconName: String {
            switch self {
            case .dateAdded: return "calendar"
            case .title: return "textformat"
            case .type: return "film"
            }
        }
    }
    
    var filteredItems: [WatchlistItem] {
        var items = watchlistManager.items
        
        // Search filter
        if !searchText.isEmpty {
            items = items.filter { item in
                item.title.lowercased().contains(searchText.lowercased()) ||
                item.notes.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Content type filter
        if let contentType = selectedContentType {
            items = items.filter { $0.type == contentType }
        }
        
        // Category filter
        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }
        
        // Watched status filter
        if showWatchedOnly {
            items = items.filter { $0.isWatched }
        } else if showUnwatchedOnly {
            items = items.filter { !$0.isWatched }
        }
        
        // Sort
        switch sortBy {
        case .dateAdded:
            items.sort { $0.dateAdded > $1.dateAdded }
        case .title:
            items.sort { $0.title.lowercased() < $1.title.lowercased() }
        case .type:
            items.sort { $0.type.rawValue < $1.type.rawValue }
        }
        
        return items
    }
    
    var activeFilterCount: Int {
        var count = 0
        if selectedContentType != nil { count += 1 }
        if selectedCategory != nil { count += 1 }
        if showWatchedOnly || showUnwatchedOnly { count += 1 }
        return count
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search titles or notes...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top)
                
                // Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        // Content Type Filter
                        Menu {
                            Button("All Types") {
                                selectedContentType = nil
                            }
                            ForEach(WatchlistItem.ContentType.allCases, id: \.self) { type in
                                Button(type.rawValue) {
                                    selectedContentType = type
                                }
                            }
                        } label: {
                            FilterPill(
                                title: selectedContentType?.rawValue ?? "Type",
                                icon: "film",
                                isActive: selectedContentType != nil
                            )
                        }
                        
                        // Category Filter
                        Menu {
                            Button("All Categories") {
                                selectedCategory = nil
                            }
                            ForEach(WatchlistItem.WatchCategory.allCases, id: \.self) { category in
                                Button(category.rawValue) {
                                    selectedCategory = category
                                }
                            }
                        } label: {
                            FilterPill(
                                title: selectedCategory?.rawValue ?? "Category",
                                icon: "timer",
                                isActive: selectedCategory != nil
                            )
                        }
                        
                        // Watched Status Filter
                        Menu {
                            Button("All Items") {
                                showWatchedOnly = false
                                showUnwatchedOnly = false
                            }
                            Button("Watched Only") {
                                showWatchedOnly = true
                                showUnwatchedOnly = false
                            }
                            Button("Unwatched Only") {
                                showWatchedOnly = false
                                showUnwatchedOnly = true
                            }
                        } label: {
                            FilterPill(
                                title: showWatchedOnly ? "Watched" : showUnwatchedOnly ? "Unwatched" : "Status",
                                icon: "checkmark.circle",
                                isActive: showWatchedOnly || showUnwatchedOnly
                            )
                        }
                        
                        // Sort Menu
                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(action: {
                                    sortBy = option
                                }) {
                                    HStack {
                                        Text(option.rawValue)
                                        if sortBy == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            FilterPill(
                                title: "Sort",
                                icon: sortBy.iconName,
                                isActive: true
                            )
                        }
                        
                        // Clear All Filters
                        if activeFilterCount > 0 {
                            Button(action: clearAllFilters) {
                                HStack(spacing: 4) {
                                    Text("Clear")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Image(systemName: "xmark")
                                        .font(.caption2)
                                }
                                .foregroundColor(.red)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                
                Divider()
                
                // Results
                if filteredItems.isEmpty {
                    EmptySearchState(searchText: searchText)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            // Results Header
                            HStack {
                                Text("\(filteredItems.count) result\(filteredItems.count == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                if activeFilterCount > 0 {
                                    Text("•")
                                        .foregroundColor(.gray)
                                    
                                    Text("\(activeFilterCount) filter\(activeFilterCount == 1 ? "" : "s") active")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            
                            // Items List
                            ForEach(filteredItems) { item in
                                NavigationLink(destination: WatchlistItemDetailView(item: item)) {
                                    SearchResultRow(item: item)
                                        .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.bottom)
                    }
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    NavigationLink(destination: AddView()
                        .environmentObject(watchlistManager), isActive: $showAdd) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(width: 60, height: 60)
                            .background(Color.red)
                            .clipShape(Circle())
                            .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Search & Filter")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func clearAllFilters() {
        selectedContentType = nil
        selectedCategory = nil
        showWatchedOnly = false
        showUnwatchedOnly = false
    }
}

// MARK: - Supporting Views

struct FilterPill: View {
    let title: String
    let icon: String
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(isActive ? .red : .gray)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isActive ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isActive ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

struct SearchResultRow: View {
    let item: WatchlistItem
    @EnvironmentObject var watchlistManager: WatchlistManager
    
    var body: some View {
        HStack(alignment: .top) {
            // Icon with watched indicator
            ZStack(alignment: .topTrailing) {
                Image(systemName: item.type.iconName)
                    .foregroundColor(.red)
                    .frame(width: 40, height: 40)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                
                if item.isWatched {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .background(Circle().fill(Color.white).frame(width: 12, height: 12))
                        .offset(x: 4, y: -4)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Text(item.type.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                    
                    Text(item.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(4)
                }
                
                if !item.notes.isEmpty {
                    Text(item.notes)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
                
                Text("Added \(timeAgo(item.dateAdded))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                watchlistManager.toggleWatched(item)
            }) {
                Image(systemName: item.isWatched ? "arrow.uturn.backward.circle" : "checkmark.circle")
                    .foregroundColor(item.isWatched ? .orange : .green)
                    .font(.title3)
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
            return "\(days)d ago"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h ago"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "Just now"
        }
    }
}

struct EmptySearchState: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            if searchText.isEmpty {
                Text("Start searching")
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text("Enter keywords to find items in your watchlist")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                Text("No results found")
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text("Try adjusting your search or filters")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        SearchAndFilterView()
            .environmentObject(WatchlistManager())
    }
}
