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
    @State private var showDeleteConfirmation = false
    
    @State private var isSelectionMode = false
    @State private var selectedItems: Set<UUID> = []
    
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
    
    
    var allFilteredItemIds: Set<UUID> {
        Set(filteredItems.map { $0.id })
    }

    var isAllSelected: Bool {
        !filteredItems.isEmpty && selectedItems == allFilteredItemIds
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
                            // Results Header
                            HStack {
                                if isSelectionMode {
                                    Button(action: {
                                        if isAllSelected {
                                            selectedItems.removeAll()
                                        } else {
                                            selectedItems = allFilteredItemIds
                                        }
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: isAllSelected ? "checkmark.square.fill" : "square")
                                                .foregroundColor(.red)
                                            Text(isAllSelected ? "Deselect All" : "Select All")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.red)
                                        }
                                    }
                                    
                                    Text("•")
                                        .foregroundColor(.gray)
                                    
                                    Text("\(selectedItems.count) selected")
                                        .font(.caption)
                                        .foregroundColor(themeManager.primaryTextColor)
                                } else {
                                    Text("\(filteredItems.count) result\(filteredItems.count == 1 ? "" : "s")")
                                        .font(.caption)
                                        .foregroundColor(themeManager.secondaryTextColor)
                                    
                                    if activeFilterCount > 0 {
                                        Text("•")
                                            .foregroundColor(themeManager.secondaryTextColor)
                                        
                                        Text("\(activeFilterCount) filter\(activeFilterCount == 1 ? "" : "s") active")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            
                            // Items List
                            ForEach(filteredItems) { item in
                                if isSelectionMode {
                                    Button(action: {
                                        if selectedItems.contains(item.id) {
                                            selectedItems.remove(item.id)
                                        } else {
                                            selectedItems.insert(item.id)
                                        }
                                    }) {
                                        SearchResultRow(
                                            item: item,
                                            isSelectionMode: true,
                                            isSelected: selectedItems.contains(item.id)
                                        )
                                        .padding(.horizontal)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    NavigationLink(destination: WatchlistItemDetailView(item: item)) {
                                        SearchResultRow(
                                            item: item,
                                            isSelectionMode: false,
                                            isSelected: false
                                        )
                                        .padding(.horizontal)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !filteredItems.isEmpty {
                    Button(action: {
                        isSelectionMode.toggle()
                        selectedItems.removeAll()
                    }) {
                        Text(isSelectionMode ? "Cancel" : "Select")
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                if isSelectionMode && !selectedItems.isEmpty {
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                            Text("Delete (\(selectedItems.count))")
                        }
                        .foregroundColor(.red)
                        .fontWeight(.semibold)
                    }
                }
            }
        }
        .alert("Delete Items", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteSelectedItems()
            }
        } message: {
            Text("Are you sure you want to delete \(selectedItems.count) item(s)?")
        }
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func clearAllFilters() {
        selectedContentType = nil
        selectedCategory = nil
        showWatchedOnly = false
        showUnwatchedOnly = false
    }
    
    private func deleteSelectedItems() {
        let itemsToDelete = filteredItems.filter { selectedItems.contains($0.id) }
        
        for item in itemsToDelete {
            watchlistManager.deleteItem(item)
        }
        
        selectedItems.removeAll()
        isSelectionMode = false
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
    let isSelectionMode: Bool
    let isSelected: Bool
    @EnvironmentObject var watchlistManager: WatchlistManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 0) {
            // Selection checkbox (only in selection mode)
            if isSelectionMode {
                Button(action: {}) { // Empty action, handled by parent
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(.red)
                        .font(.system(size: 24))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Main content
            HStack(alignment: .top, spacing: 12) {
                // Icon with watched indicator
                ZStack(alignment: .topTrailing) {
                    Image(systemName: item.type.iconName)
                        .foregroundColor(.red)
                        .font(.system(size: 20))
                        .frame(width: 50, height: 50)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                    
                    if item.isWatched {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                            .background(
                                Circle()
                                    .fill(themeManager.backgroundColor)
                                    .frame(width: 16, height: 16)
                            )
                            .offset(x: 6, y: -6)
                    }
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.primaryTextColor)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(spacing: 6) {
                        Text(item.type.rawValue)
                            .font(.system(size: 11))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(themeManager.secondaryBackgroundColor)
                            .foregroundColor(themeManager.secondaryTextColor)
                            .cornerRadius(6)
                        
                        Text(item.category.rawValue)
                            .font(.system(size: 11))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(6)
                    }
                    
                    if !item.notes.isEmpty {
                        Text(item.notes)
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.secondaryTextColor)
                            .lineLimit(2)
                            .padding(.top, 2)
                    }
                    
                    Text("Added \(timeAgo(item.dateAdded))")
                        .font(.system(size: 11))
                        .foregroundColor(themeManager.secondaryTextColor.opacity(0.7))
                        .padding(.top, 2)
                }
                
                Spacer(minLength: 8)
                
                // Quick action button (only when NOT in selection mode)
                if !isSelectionMode {
                    Button(action: {
                        watchlistManager.toggleWatched(item)
                    }) {
                        Image(systemName: item.isWatched ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill")
                            .foregroundColor(item.isWatched ? .orange : .green)
                            .font(.system(size: 28))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .background(themeManager.secondaryBackgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.red : themeManager.borderColor, lineWidth: isSelected ? 2 : 1)
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
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            if searchText.isEmpty {
                Text("Start searching")
                    .font(.headline)
                    .foregroundColor(themeManager.primaryTextColor)
                
                Text("Enter keywords to find items in your watchlist")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                Text("No results found")
                    .font(.headline)
                    .foregroundColor(themeManager.primaryTextColor)
                
                Text("Try adjusting your search or filters")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
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
