//
//  MindMeltApp.swift
//  MindMelt
//
//  Created by STUDENT on 9/15/25.
//

import SwiftUI

@main
struct MindMelt: App {
    @StateObject private var watchlistManager = WatchlistManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(watchlistManager)
        }
    }
}

