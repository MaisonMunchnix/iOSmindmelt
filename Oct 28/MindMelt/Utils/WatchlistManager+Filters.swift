//
//  WatchlistManager+Filters.swift
//  MindMelt
//
//  Created by STUDENT on 10/23/25.
//

import Foundation

// MARK: - Search & Filter Extension
extension WatchlistManager {
    
    // MARK: - Search Functions
    
    /// Search items by title or notes
    func searchItems(query: String) -> [WatchlistItem] {
        guard !query.isEmpty else { return items }
        
        let lowercasedQuery = query.lowercased()
        return items.filter { item in
            item.title.lowercased().contains(lowercasedQuery) ||
            item.notes.lowercased().contains(lowercasedQuery)
        }
    }
    
    /// Advanced search with multiple criteria
    func advancedSearch(
        query: String = "",
        contentType: WatchlistItem.ContentType? = nil,
        category: WatchlistItem.WatchCategory? = nil,
        isWatched: Bool? = nil,
        hasNotes: Bool? = nil
    ) -> [WatchlistItem] {
        var results = items
        
        // Text search
        if !query.isEmpty {
            results = searchItems(query: query)
        }
        
        // Content type filter
        if let type = contentType {
            results = results.filter { $0.type == type }
        }
        
        // Category filter
        if let cat = category {
            results = results.filter { $0.category == cat }
        }
        
        // Watched status filter
        if let watched = isWatched {
            results = results.filter { $0.isWatched == watched }
        }
        
        // Has notes filter
        if let notes = hasNotes {
            results = results.filter { notes ? !$0.notes.isEmpty : $0.notes.isEmpty }
        }
        
        return results
    }
    
    // MARK: - Filter Functions
    
    /// Get items by content type
    func getItemsByType(_ type: WatchlistItem.ContentType) -> [WatchlistItem] {
        return items.filter { $0.type == type }
    }
    
    /// Get items by category (already exist but adding for completeness)
    func getItemsByCategory(_ category: WatchlistItem.WatchCategory) -> [WatchlistItem] {
        return items.filter { $0.category == category }
    }
    
    /// Get items with notes
    func getItemsWithNotes() -> [WatchlistItem] {
        return items.filter { !$0.notes.isEmpty }
    }
    
    /// Get items without notes
    func getItemsWithoutNotes() -> [WatchlistItem] {
        return items.filter { $0.notes.isEmpty }
    }
    
    /// Get recently added items (last N days)
    func getRecentItems(days: Int = 7) -> [WatchlistItem] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return items.filter { $0.dateAdded >= cutoffDate }
            .sorted { $0.dateAdded > $1.dateAdded }
    }
    
    /// Get items added in a specific date range
    func getItemsInDateRange(from startDate: Date, to endDate: Date) -> [WatchlistItem] {
        return items.filter { $0.dateAdded >= startDate && $0.dateAdded <= endDate }
    }
    
    // MARK: - Sort Functions
    
    enum SortOption {
        case dateAddedNewest
        case dateAddedOldest
        case titleAscending
        case titleDescending
        case typeAscending
        case categoryAscending
    }
    
    /// Sort items by specified criteria
    func sortItems(_ items: [WatchlistItem], by option: SortOption) -> [WatchlistItem] {
        switch option {
        case .dateAddedNewest:
            return items.sorted { $0.dateAdded > $1.dateAdded }
        case .dateAddedOldest:
            return items.sorted { $0.dateAdded < $1.dateAdded }
        case .titleAscending:
            return items.sorted { $0.title.lowercased() < $1.title.lowercased() }
        case .titleDescending:
            return items.sorted { $0.title.lowercased() > $1.title.lowercased() }
        case .typeAscending:
            return items.sorted { $0.type.rawValue < $1.type.rawValue }
        case .categoryAscending:
            return items.sorted { $0.category.rawValue < $1.category.rawValue }
        }
    }
    
    // MARK: - Statistics Functions
    
    /// Get watchlist statistics
    func getStatistics() -> WatchlistStatistics {
        let totalItems = items.count
        let watchedItems = items.filter { $0.isWatched }.count
        let unwatchedItems = totalItems - watchedItems
        
        let movieCount = items.filter { $0.type == .movie }.count
        let youtubeCount = items.filter { $0.type == .youtubeVideo }.count
        let podcastCount = items.filter { $0.type == .podcast }.count
        
        let quickCount = items.filter { $0.category == .quick }.count
        let bingeCount = items.filter { $0.category == .long }.count
        
        let itemsWithNotes = items.filter { !$0.notes.isEmpty }.count
        
        return WatchlistStatistics(
            totalItems: totalItems,
            watchedItems: watchedItems,
            unwatchedItems: unwatchedItems,
            movieCount: movieCount,
            youtubeCount: youtubeCount,
            podcastCount: podcastCount,
            quickWatchCount: quickCount,
            bingeReadyCount: bingeCount,
            itemsWithNotes: itemsWithNotes
        )
    }
    
    /// Get completion percentage
    func getCompletionPercentage() -> Double {
        guard !items.isEmpty else { return 0.0 }
        let watched = items.filter { $0.isWatched }.count
        return (Double(watched) / Double(items.count)) * 100
    }
    
    // MARK: - Batch Operations
    
    /// Mark multiple items as watched
    func markMultipleAsWatched(_ itemIds: [UUID]) {
        for id in itemIds {
            if let index = items.firstIndex(where: { $0.id == id }) {
                items[index].isWatched = true
            }
        }
        saveItems()
        
        Task {
            for id in itemIds {
                if let item = items.first(where: { $0.id == id }) {
                    await updateItemInSupabase(item)
                }
            }
        }
    }
    
    /// Delete multiple items
    func deleteMultipleItems(_ itemIds: [UUID]) {
        let itemsToDelete = items.filter { itemIds.contains($0.id) }
        items.removeAll { itemIds.contains($0.id) }
        saveItems()
        
        Task {
            for item in itemsToDelete {
                await deleteItemFromSupabase(item)
            }
        }
    }
}

// MARK: - Statistics Model
struct WatchlistStatistics {
    let totalItems: Int
    let watchedItems: Int
    let unwatchedItems: Int
    let movieCount: Int
    let youtubeCount: Int
    let podcastCount: Int
    let quickWatchCount: Int
    let bingeReadyCount: Int
    let itemsWithNotes: Int
    
    var completionPercentage: Double {
        guard totalItems > 0 else { return 0.0 }
        return (Double(watchedItems) / Double(totalItems)) * 100
    }
}
