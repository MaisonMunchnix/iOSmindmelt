//
//  ThemeManager.swift
//  MindMelt
//
//  Created by STUDENT on 10/23/25.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    static let shared = ThemeManager()
    
    private init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }
    
    // Color scheme helper
    var colorScheme: ColorScheme {
        isDarkMode ? .dark : .light
    }
    
    // Theme Colors
    var backgroundColor: Color {
        isDarkMode ? Color(red: 0.11, green: 0.11, blue: 0.12) : .white
    }
    
    var secondaryBackgroundColor: Color {
        isDarkMode ? Color(red: 0.17, green: 0.17, blue: 0.18) : Color.gray.opacity(0.05)
    }
    
    var cardBackgroundColor: Color {
        isDarkMode ? Color(red: 0.17, green: 0.17, blue: 0.18) : .white
    }
    
    var primaryTextColor: Color {
        isDarkMode ? .white : .black
    }
    
    var secondaryTextColor: Color {
        isDarkMode ? Color.gray.opacity(0.8) : .gray
    }
    
    var accentColor: Color {
        .red // Keep red accent in both modes
    }
    
    var borderColor: Color {
        isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2)
    }
    
    var searchBarBackground: Color {
        isDarkMode ? Color(red: 0.17, green: 0.17, blue: 0.18) : Color.gray.opacity(0.1)
    }
    
    func toggle() {
        isDarkMode.toggle()
    }
}
