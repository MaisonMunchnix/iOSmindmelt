//
//  AccountSettingsView.swift
//  MindMelt
//
//  Created by STUDENT on 10/7/25.
//

import SwiftUI

struct AccountSettingsView: View {
    @StateObject private var supabase = SupabaseManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        // REMOVE NavigationView - it's already in Landing.swift
        Form {
            Section("Account Information") {
                if let user = supabase.user {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(user.email ?? "N/A")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section("Preferences") {
                Toggle("Push Notifications", isOn: .constant(true))
            }
            
            Section {
                Button("Delete Account") {
                    // delete
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Account Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        AccountSettingsView()
    }
}
