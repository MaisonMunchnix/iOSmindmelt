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
                    // Header
                    HStack{
                        VStack(alignment: .leading, spacing: 8) {
                            Image("mm")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                            
                            if let user = supabase.user {
                                Text(user.email ?? "User")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                               
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                        .padding(.bottom, 30)
                        
                    }
                    Divider()
                    
                    VStack(spacing: 0) {
                        NavigationLink(destination: AccountSettingsView()) {
                                SidebarNavigationItem(
                                    icon: "person.circle",
                                    title: "Account Settings"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                            .padding(.vertical, 10)
                        
                        
                        SidebarMenuItem(
                            icon: "rectangle.portrait.and.arrow.right",
                            title: "Logout",
                            action: {
                                logOut()
                            }
                        )
                        
                        
                        Spacer()
                    }
                    
                    
                    
                    
                }
                .frame(width: 280)
                .background(Color.white)
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

struct SidebarMenuItem: View {
    let icon: String
    let title: String
    var textColor: Color = .black
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(textColor)
                    .frame(width: 30)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(textColor)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SidebarView(isShowing: .constant(true))
        .environmentObject(WatchlistManager())
}


struct SidebarNavigationItem: View {
    let icon: String
    let title: String
    var textColor: Color = .black
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(textColor)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
                .foregroundColor(textColor)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
}
