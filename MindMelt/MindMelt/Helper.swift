//
//  Helper.swift
//  Watchlist
//
//  Created by STUDENT on 9/4/25.
//

import Foundation

import SwiftUI

class Helper {
    static func checkClipboardforYT() -> String? {
        guard let clipboard = UIPasteboard.general.string,
              let url = URL(string: clipboard),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return nil
        }

        // Case 1: https://www.youtube.com/watch?v=VIDEO_ID
        if components.host?.contains("youtube.com") == true,
           let queryItems = components.queryItems {
            for item in queryItems {
                if item.name == "v", let videoID = item.value {
                    return videoID
                }
            }
        }

        // Case 2: https://youtu.be/VIDEO_ID or https://youtu.be/VIDEO_ID?si=...
        if components.host?.contains("youtu.be") == true {
            let rawPath = components.path.replacingOccurrences(of: "/", with: "")
            let cleanID = rawPath.components(separatedBy: "?").first ?? rawPath
            return cleanID
        }

        return nil
    }
}
