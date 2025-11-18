//
//  SidebarView.swift
//  MindMelt
//
//  Created by STUDENT on 10/7/25.
//

import SwiftUI

struct SidebarView: View {
    @Binding var isShowing: Bool
    @StateObject private var supabase = SupabaseManager.shared
    @EnvironmentObject var watchlistManager: WatchlistManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            // Dimmed background
            if isShowing {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isShowing = false
                        }
                    }
            }
            
            // Sidebar content
            HStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 0) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 12) {
                        Image("mm")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                        
                        if let user = supabase.user {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Signed in as")
                                    .font(.caption2)
                                    .foregroundColor(themeManager.secondaryTextColor)
                                
                                Text(user.email ?? "User")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(themeManager.primaryTextColor)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .padding(.bottom, 30)
                    
                    Divider()
                        .background(themeManager.borderColor)
                    
                    // Menu Items Section
                    ScrollView {
                        VStack(spacing: 0) {
                            // Account Settings
                            NavigationLink(destination: AccountSettingsView()
                                .environmentObject(themeManager)) {
                                SidebarNavigationItem(
                                    icon: "person.circle",
                                    title: "Account Settings"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                                .background(themeManager.borderColor)
                                .padding(.horizontal, 20)
                            
                            // Logout Section
                            VStack(spacing: 0) {
                                Divider()
                                    .background(themeManager.borderColor)
                                
                                SidebarMenuItem(
                                    icon: "rectangle.portrait.and.arrow.right",
                                    title: "Logout",
                                    textColor: .red,
                                    action: {
                                        logOut()
                                    }
                                )
                            }
                            .padding(.bottom, 40)
                            
                            // Statistics (Optional)
//                            Button(action: {
//                                // Add statistics view if needed
//                            }) {
//                                SidebarNavigationItem(
//                                    icon: "chart.bar.fill",
//                                    title: "Statistics"
//                                )
//                            }
//                            .buttonStyle(PlainButtonStyle())
                            
//                            Divider()
//                                .background(themeManager.borderColor)
//                                .padding(.horizontal, 20)
                            
                            // Sync Now
//                            Button(action: {
//                                Task {
//                                    await watchlistManager.syncWithSupabase()
//                                }
//                            }) {
//                                SidebarNavigationItem(
//                                    icon: "arrow.triangle.2.circlepath",
//                                    title: "Sync Now"
//                                )
//                            }
//                            .buttonStyle(PlainButtonStyle())
                            
//                            Divider()
//                                .background(themeManager.borderColor)
//                                .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 10)
                    }
                    
//                    Spacer()
                    
                    // Theme Toggle Section
                    VStack(spacing: 15) {
                        Divider()
                            .background(themeManager.borderColor)
                        
                        VStack(spacing: 10) {
                            HStack {
                                Text("Appearance")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(themeManager.secondaryTextColor)
                                
                                Spacer()
                            }
                            
                            ThemeToggleView()
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    
                }
                .frame(width: 280)
                .background(themeManager.backgroundColor)
                .offset(x: isShowing ? 0 : 280)
            }
        }
        .zIndex(999)
        .animation(.easeInOut(duration: 0.3), value: isShowing)
    }
    
    private func logOut() {
        Task {
            do {
                try await SupabaseManager.shared.signout()
                print("User signed out")
                withAnimation {
                    isShowing = false
                }
            } catch {
                print("Signout error: \(error)")
            }
        }
    }
}

// MARK: - Sidebar Menu Item (Button)
struct SidebarMenuItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    let icon: String
    let title: String
    var textColor: Color? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(textColor ?? themeManager.primaryTextColor)
                    .frame(width: 30)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(textColor ?? themeManager.primaryTextColor)
                
                Spacer()
                
                if textColor == nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Sidebar Navigation Item (NavigationLink)
struct SidebarNavigationItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    let icon: String
    let title: String
    var textColor: Color? = nil
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(textColor ?? themeManager.primaryTextColor)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
                .foregroundColor(textColor ?? themeManager.primaryTextColor)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(themeManager.secondaryTextColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .contentShape(Rectangle())
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()
        
        SidebarView(isShowing: .constant(true))
            .environmentObject(WatchlistManager())
            .environmentObject(ThemeManager.shared)
    }
}
