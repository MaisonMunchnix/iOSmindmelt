//
//  YouTubeAPI.swift
//  MindMelt
//
//  Created by Kyla Enriquez on 9/22/25.
//

import Foundation


class YouTubeAPI {

    static func fetchVideoData(for videoID: String) async -> (String, String) {
        let apiKey = "AIzaSyCOBEj7LfMD5tTodrQR-lbOd0Gv4ncVMxU"
        let urlString = "https://www.googleapis.com/youtube/v3/videos?part=snippet&id=\(videoID)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            return ("", "")
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Debug: Print the raw response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("🎯 Raw JSON: \(jsonString)")
            }

            let jsonResponse = try JSONDecoder().decode(YouTubeResponse.self, from: data)
            
            if let snippet = jsonResponse.items.first?.snippet {
                let title = snippet.title

                // Try to get the best available thumbnail
                let thumbnailUrl =
                    snippet.thumbnails.maxres?.url ??
                    snippet.thumbnails.standard?.url ??
                    snippet.thumbnails.high?.url ??
                    snippet.thumbnails.medium?.url ??
                    snippet.thumbnails.default?.url ?? ""

                return (title, thumbnailUrl)
            } else {
                return ("", "")
            }
        } catch {
            print("❌ Error fetching video data: \(error.localizedDescription)")
            return ("", "")
        }
    }
}

// MARK: - Models

struct YouTubeResponse: Decodable {
    let items: [YouTubeItem]
}

struct YouTubeItem: Decodable {
    let snippet: Snippet
}

struct Snippet: Decodable {
    let title: String
    let thumbnails: Thumbnails
}

struct Thumbnails: Decodable {
    let `default`: ThumbnailInfo?
    let medium: ThumbnailInfo?
    let high: ThumbnailInfo?
    let standard: ThumbnailInfo?
    let maxres: ThumbnailInfo?
}

struct ThumbnailInfo: Decodable {
    let url: String
}
