//
//  Models.swift
//  Watchlist
//
//  Created by STUDENT on 9/4/25.
//

import SwiftUI
import Foundation

struct WatchlistItem: Identifiable, Codable {
    let id: UUID
    var userId: UUID?
    var title: String
    var type: ContentType
    var category: WatchCategory
    var notes: String
    var dateAdded: Date
    var isWatched: Bool
    var thumbnailURL: String?
    var youtubeID: String?
    var createdAt: Date?
    var updatedAt: Date?
    
    // Local-only initializer (for existing functionality)
    init(title: String, type: ContentType, category: WatchCategory, notes: String = "", dateAdded: Date = Date(), isWatched: Bool = false, thumbnailURL: String? = nil, youtubeID: String? = nil) {
        self.id = UUID()
        self.userId = nil
        self.title = title
        self.type = type
        self.category = category
        self.notes = notes
        self.dateAdded = dateAdded
        self.isWatched = isWatched
        self.thumbnailURL = thumbnailURL
        self.youtubeID = youtubeID
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Supabase initializer (for database records)
    init(id: UUID, userId: UUID, title: String, contentType: String, category: String, notes: String, dateAdded: Date, isWatched: Bool, thumbnailURL: String? = nil, youtubeID: String? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.title = title
        self.type = ContentType(rawValue: contentType) ?? .movie
        self.category = WatchCategory(rawValue: category) ?? .quick
        self.notes = notes
        self.dateAdded = dateAdded
        self.isWatched = isWatched
        self.thumbnailURL = thumbnailURL
        self.youtubeID = youtubeID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum ContentType: String, CaseIterable, Codable {
        case movie = "Movie/Series"
        case youtubeVideo = "YouTube Video"
        case podcast = "Podcast"
        
        var iconName: String {
            switch self {
            case .movie: return "film"
            case .youtubeVideo: return "play.rectangle"
            case .podcast: return "mic"
            }
        }
    }
    
    enum WatchCategory: String, CaseIterable, Codable {
        case quick = "Quick Watch"
        case long = "Binge Ready"
        
        var description: String {
            switch self {
            case .quick: return "Under 30 minutes"
            case .long: return "30+ minutes"
            }
        }
    }
    
    // Custom coding keys to match Supabase column names
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case type = "content_type"
        case category
        case notes
        case dateAdded = "date_added"
        case isWatched = "is_watched"
        case thumbnailURL = "thumbnail_url"
        case youtubeID = "youtube_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// Supabase response models
struct SupabaseWatchlistItem: Codable {
    let id: UUID
    let userId: UUID
    let title: String
    let contentType: String
    let category: String
    let notes: String
    let dateAdded: String // ISO date string from Supabase
    let isWatched: Bool
    let thumbnailUrl: String?
    let youtubeId: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case contentType = "content_type"
        case category
        case notes
        case dateAdded = "date_added"
        case isWatched = "is_watched"
        case thumbnailUrl = "thumbnail_url"
        case youtubeId = "youtube_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Convert to WatchlistItem
    func toWatchlistItem() -> WatchlistItem {
        let dateFormatter = ISO8601DateFormatter()
        return WatchlistItem(
            id: id,
            userId: userId,
            title: title,
            contentType: contentType,
            category: category,
            notes: notes,
            dateAdded: dateFormatter.date(from: dateAdded) ?? Date(),
            isWatched: isWatched,
            thumbnailURL: thumbnailUrl,
            youtubeID: youtubeId,
            createdAt: createdAt != nil ? dateFormatter.date(from: createdAt!) : nil,
            updatedAt: updatedAt != nil ? dateFormatter.date(from: updatedAt!) : nil
        )
    }
}

// For inserting new items to Supabase
struct InsertWatchlistItem: Codable {
    let userId: UUID
    let title: String
    let contentType: String
    let category: String
    let notes: String
    let dateAdded: String
    let isWatched: Bool
    let thumbnailUrl: String?
    let youtubeId: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case title
        case contentType = "content_type"
        case category
        case notes
        case dateAdded = "date_added"
        case isWatched = "is_watched"
        case thumbnailUrl = "thumbnail_url"
        case youtubeId = "youtube_id"
    }
    
    init(from item: WatchlistItem, userId: UUID) {
        self.userId = userId
        self.title = item.title
        self.contentType = item.type.rawValue
        self.category = item.category.rawValue
        self.notes = item.notes
        let formatter = ISO8601DateFormatter()
        self.dateAdded = formatter.string(from: item.dateAdded)
        self.isWatched = item.isWatched
        self.thumbnailUrl = item.thumbnailURL
        self.youtubeId = item.youtubeID
    }
}
