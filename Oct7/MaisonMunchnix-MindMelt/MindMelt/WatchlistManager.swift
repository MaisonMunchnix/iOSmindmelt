//
//  WatchlistManager.swift
//  MindMelt
//
//  Created by STUDENT on 9/30/25.
//


import SwiftUI
import Supabase

class WatchlistManager: ObservableObject {
    @Published var items: [WatchlistItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let saveKey = "WatchlistItems"
    private let supabase = SupabaseManager.shared
    
    init() {
        loadItems()
        
        Task{
            await autoSyncOnStartup()
        }
    }
    
    // MARK: - Core
    func addItem(_ item: WatchlistItem) {
        items.append(item)
        saveItems()
        
        Task {
            await syncItemToSupabase(item)
        }
    }
    
    func toggleWatched(_ item: WatchlistItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isWatched.toggle()
            saveItems()
            
            // Sync to Supabase
            Task {
                await updateItemInSupabase(items[index])
            }
        }
    }
    
    func deleteItem(_ item: WatchlistItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
        
        // Delete from Supabase
        Task {
            await deleteItemFromSupabase(item)
        }
    }
    
    // MARK: - Filter
    
    func getQuickItems() -> [WatchlistItem] {
        return items.filter { $0.category == .quick && !$0.isWatched }
    }
    
    func getBingeItems() -> [WatchlistItem] {
        return items.filter { $0.category == .long && !$0.isWatched }
    }
    
    func getWatchedItems() -> [WatchlistItem] {
        return items.filter { $0.isWatched }
    }
    
    func getRandomItem() -> WatchlistItem? {
        let unwatched = items.filter { !$0.isWatched }
        return unwatched.randomElement()
    }
    
    // MARK: - Local Storage (Unchanged)
    
    private func saveItems() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decodedItems = try? JSONDecoder().decode([WatchlistItem].self, from: data) {
            items = decodedItems
        }
    }
    
    @MainActor
    private func autoSyncOnStartup() async {
        if supabase.isAuthenticated {
            print("Syncing supaabase...")
            await syncWithSupabase()
        }
    }
    // MARK: - Supabase sync
    
    @MainActor
    func syncWithSupabase() async {
        guard supabase.isAuthenticated, let user = supabase.user else {
            print("User not authenticated, skipping sync")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [SupabaseWatchlistItem] = try await supabase.client
                .from("watchlist_items")
                .select()
                .eq("user_id", value: user.id)
                .execute()
                .value
            
            let supabaseItems = response.map { $0.toWatchlistItem() }
            
            items = supabaseItems
            saveItems()
            
            print("Sync completed. \(supabaseItems.count)")
            
//            var mergedItems: [WatchlistItem] = []
//            let supabaseItemIds = Set(supabaseItems.map { $0.id })
//
//            mergedItems.append(contentsOf: supabaseItems)
//
//            let localOnlyItems = items.filter { !supabaseItemIds.contains($0.id) }
//            mergedItems.append(contentsOf: localOnlyItems)
//
//            items = mergedItems
//            saveItems()
//
//            for localItem in localOnlyItems {
//                await syncItemToSupabase(localItem)
//            }
            
            print("Sync completed successfully")
            
        } catch {
            errorMessage = "Sync failed: \(error.localizedDescription)"
            print("Sync error: \(error)")
        }
        
        isLoading = false
    }
    
    private func syncItemToSupabase(_ item: WatchlistItem) async {
        guard supabase.isAuthenticated, let user = supabase.user else {
            return
        }
        
        do {
            let insertItem = InsertWatchlistItem(from: item, userId: user.id)
            
            try await supabase.client
                .from("watchlist_items")
                .insert(insertItem)
                .execute()
            
            print("Item synced to Supabase: \(item.title)")
            
        } catch {
            print("Failed to sync item to Supabase: \(error)")
        }
    }
    
    private func updateItemInSupabase(_ item: WatchlistItem) async {
        guard supabase.isAuthenticated, item.userId != nil else {
            return
        }
        
        do {
            let formatter = ISO8601DateFormatter()
            struct WatchlistItemUpdate: Encodable {
                let title: String
                let content_type: String
                let category: String
                let notes: String
                let is_watched: Bool
                let thumbnail_url: String?
                let youtube_id: String?
                let updated_at: String
            }

            // Then use it:
            let updateData = WatchlistItemUpdate(
                title: item.title,
                content_type: item.type.rawValue,
                category: item.category.rawValue,
                notes: item.notes,
                is_watched: item.isWatched,
                thumbnail_url: item.thumbnailURL,
                youtube_id: item.youtubeID,
                updated_at: formatter.string(from: Date())
            )

            try await supabase.client
                .from("watchlist_items")
                .update(updateData)
                .eq("id", value: item.id)
                .execute()
            
            print("Item updated in Supabase: \(item.title)")
            
        } catch {
            print("Failed to update item in Supabase: \(error)")
        }
    }
    
    private func deleteItemFromSupabase(_ item: WatchlistItem) async {
        guard supabase.isAuthenticated, item.userId != nil else {
            return
        }
        
        do {
            try await supabase.client
                .from("watchlist_items")
                .delete()
                .eq("id", value: item.id)
                .execute()
            
            print("Item deleted from Supabase: \(item.title)")
            
        } catch {
            print("Failed to delete item from Supabase: \(error)")
        }
    }
    
    
    func handleAuthStateChange() {
        if supabase.isAuthenticated {
            Task {
                await syncWithSupabase()
            }
        } else {
            print("User logged out, keeping local data")
        }
    }
    
    func debugAuthStatus() {
        print("=== DEBUG AUTH STATUS ===")
        print("Is authenticated: \(supabase.isAuthenticated)")
        print("User ID: \(supabase.user?.id.uuidString ?? "nil")")
        print("Local items count: \(items.count)")
        print("========================")
    }
}
