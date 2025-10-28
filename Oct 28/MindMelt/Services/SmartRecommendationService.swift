//
//  SmartRecommendationService.swift
//  MindMelt
//

import Foundation

class SmartRecommendationService {
    static let shared = SmartRecommendationService()
          
      private var titleMoodCache: [String: (score: Int, reason: String)] = [:]  // <-- Add this
  
        
    
    private init() {}
    
    func getRecommendation(watchedItems: [WatchlistItem], unwatchedItems: [WatchlistItem], mood: String? = nil) async throws -> (title: String, reason: String) {
        
        guard !unwatchedItems.isEmpty else {
            throw RecommendationError.noItems
        }
        
        // Simulate AI "thinking" delay
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        let context = getCurrentContext()
        let recentlyWatchedTypes = getRecentlyWatchedTypes(from: watchedItems)
        
        // Score each unwatched item
        var scoredItems: [(item: WatchlistItem, score: Int, reason: String)] = []
        
        for item in unwatchedItems {
            var score = 10 // Base score
            var reasons: [String] = []
            
            // Time-based scoring
            if context.isEvening && item.category == .long {
                score += 15
                reasons.append("perfect for evening viewing")
            } else if context.isMorning && item.category == .quick {
                score += 15
                reasons.append("great morning content")
            } else if context.isAfternoon {
                score += 10
                reasons.append("good afternoon pick")
            }
            
            // Variety scoring - prefer different types than recently watched
            if !recentlyWatchedTypes.contains(item.type) {
                score += 20
                reasons.append("different from your recent watches")
            }
            
            // Age scoring - older items get higher priority
            let daysOld = Calendar.current.dateComponents([.day], from: item.dateAdded, to: Date()).day ?? 0
            if daysOld >= 7 {
                score += 10
                reasons.append("waiting in your list for a while")
            }
            
            // Weekend bonus for long content
            if context.isWeekend && item.category == .long {
                score += 10
                reasons.append("weekend is perfect for longer content")
            }
            
            if context.isLateNight && item.type == .movie {
                score += 12
                reasons.append("relaxing movie for late night")
            }
            
            switch item.type {
            case .movie:
                if context.isEvening || context.isWeekend {
                    score += 8
                }
            case .youtubeVideo:
                if context.isMorning || context.isAfternoon {
                    score += 8
                }
            case .podcast:
                if context.isMorning || context.isAfternoon {
                    score += 5
                }
            }
            
            // Mood-based scoring (moved to top for priority)
            if let mood = mood {
                print("🔍 Applying mood \(mood) to \(item.title)")
                switch mood {
                case "relaxed":
                    if item.category == .long || item.type == .movie {
                        score += 25  // Increased from 15
                        reasons.append("perfect for a relaxed mood")
                    } else {
                        score -= 5  // Slight penalty for non-matching items
                    }
                case "energetic":
                    if item.category == .quick || item.type == .youtubeVideo {
                        score += 25
                        reasons.append("energizing content to match your mood")
                    } else {
                        score -= 5
                    }
                case "learn":
                    if item.type == .podcast || item.type == .youtubeVideo {
                        score += 25
                        reasons.append("educational content to satisfy your curiosity")
                    } else {
                        score -= 5
                    }
                case "bored":
                    // Boost variety and older items
                    if !recentlyWatchedTypes.contains(item.type) || daysOld >= 7 {
                        score += 20
                        reasons.append("something different to break the boredom")
                    }
                default:
                    break
                }
                
                let (titleScore, titleReason) = await analyzeTitleForMood(item.title, mood: mood)
                score += titleScore  // Add 0-10 points based on title match
                if titleScore > 5 && !titleReason.isEmpty {  // Only add if we got a real reason
                    reasons.append(titleReason)  // Changed from "title suggests \(titleReason)"
                }
            }
            print("🔍 Item: \(item.title) | Type: \(item.type) | Category: \(item.category) | Final Score: \(score) | Reasons: \(reasons.joined(separator: ", "))")
           
            
//            let primaryReason = reasons.prefix(2).joined(separator: ", ")
//            scoredItems.append((item, score, primaryReason))
            
            let formattedReasons = reasons.map { "• \($0)" }.joined(separator: "\n")
            scoredItems.append((item, score, formattedReasons))
            
            
            
        }
        
        // Sort by score and get top recommendation
        print("🔍 Top 3 Scores: \(scoredItems.prefix(3).map { "\($0.item.title): \($0.score)" }.joined(separator: "; "))")

        scoredItems.sort { $0.score > $1.score }
        
//        if let topPick = scoredItems.first {
//            return (topPick.item.title, topPick.reason.isEmpty ? "recommended for you" : topPick.reason)
//        }
        if let best = scoredItems.max(by: { $0.score < $1.score }) {
            return (title: best.item.title, reason: best.reason)
        }
        
        // Fallback to random
        let randomItem = unwatchedItems.randomElement()!
        return (randomItem.title, "a fresh pick from your list")
    }
    
    private func getCurrentContext() -> TimeContext {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let dayOfWeek = calendar.component(.weekday, from: now)
        
        return TimeContext(
            hour: hour,
            dayOfWeek: dayOfWeek,
            isMorning: (6..<12).contains(hour),
            isAfternoon: (12..<17).contains(hour),
            isEvening: (17..<22).contains(hour),
            isLateNight: hour >= 22 || hour < 6,
            isWeekend: dayOfWeek == 1 || dayOfWeek == 7
        )
    }
    
    private func getRecentlyWatchedTypes(from watchedItems: [WatchlistItem]) -> Set<WatchlistItem.ContentType> {
        let recentWatched = watchedItems
            .sorted { $0.dateAdded > $1.dateAdded }
            .prefix(5)
        return Set(recentWatched.map { $0.type })
    }
    
    private func analyzeTitleForMood(_ title: String, mood: String) async -> (score: Int, reason: String) {
        // Create a unique cache key per title+mood combination
        let cacheKey = "\(title)-\(mood)"
        
        // ✅ Check cache first
        if let cached = titleMoodCache[cacheKey] {
            return cached
        }
        
        guard let apiKey = ProcessInfo.processInfo.environment["OPENROUTER_API_KEY"] else {
            titleMoodCache[cacheKey] = (0, "")  
            return (0, "")  // Fallback if no key
        }
        
        let prompt = """
        Analyze the video title: "\(title)".
        Evaluate how well the *content implied by this title* matches a "\(mood)" mood.
        Do NOT base the reason on the literal words in the title — instead, infer what kind of content or vibe it likely represents.
        Avoid phrases like "The title...", "Based on the title...", "The title suggests...", or other similar — focus on the implied content, NOT THE TITLE.
        Respond with a score from 0–10 (10 = perfect match) and a brief reason describing the *type of content or mood*, not just a restatement of the title.
        Format: Score: X, Reason: Y
        (Limit to 2 sentences (30 words max), use only lowercase and start with a verb)
        """

        
        let requestBody: [String: Any] = [
            "model": "openai/gpt-4o-mini",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 50
        ]
        
        guard let url = URL(string: "https://openrouter.ai/api/v1/chat/completions"),
              let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            titleMoodCache[cacheKey] = (0, "")
            return (0, "")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(OpenRouterResponse.self, from: data)
            let content = response.choices.first?.message.content ?? ""
            
            let parts = content.split(separator: ",", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            if parts.count == 2,
               let scoreStr = parts[0].split(separator: ":").last?.trimmingCharacters(in: .whitespaces),
               let score = Int(scoreStr) {
                let reason = parts[1].split(separator: ":").last?.trimmingCharacters(in: .whitespaces) ?? ""
                let result = (score, reason)
                titleMoodCache[cacheKey] = result
                return result
            }
        } catch {
            print("OpenRouter error: \(error)")
        }
        
        titleMoodCache[cacheKey] = (0, "")
        return (0, "")
    }

    
    
}

struct TimeContext {
    let hour: Int
    let dayOfWeek: Int
    let isMorning: Bool
    let isAfternoon: Bool
    let isEvening: Bool
    let isLateNight: Bool
    let isWeekend: Bool
}

enum RecommendationError: Error, LocalizedError {
    case noItems
    
    var errorDescription: String? {
        switch self {
        case .noItems:
            return "No items available for recommendation"
        }
    }
}


// Add this for API response parsing
struct OpenRouterResponse: Codable {
    let choices: [Choice]
    struct Choice: Codable {
        let message: Message
    }
    struct Message: Codable {
        let content: String
    }
}
