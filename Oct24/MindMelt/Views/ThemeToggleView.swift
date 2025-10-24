//
//  ThemeToggleView.swift
//  MindMelt
//
//  Created by STUDENT on 10/23/25.
//

import SwiftUI

struct ThemeToggleView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Image(systemName: "sun.max.fill")
                .foregroundColor(themeManager.isDarkMode ? .gray : .orange)
                .font(.title3)
            
            Toggle("", isOn: $themeManager.isDarkMode)
                .labelsHidden()
                .tint(.red)
            
            Image(systemName: "moon.fill")
                .foregroundColor(themeManager.isDarkMode ? .blue : .gray)
                .font(.title3)
        }
        .padding()
        .background(themeManager.secondaryBackgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.borderColor, lineWidth: 1)
        )
    }
}
