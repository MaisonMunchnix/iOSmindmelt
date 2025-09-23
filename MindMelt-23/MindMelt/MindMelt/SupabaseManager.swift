//
//  SupabaseManager.swift
//  Watchlist
//
//  Created by STUDENT on 9/15/25.
//


import Foundation

import Supabase
import SwiftUI


class SupabaseManager: ObservableObject {
    
    static let shared = SupabaseManager()
        
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://dqwuhhchzspmuxgajvmg.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRxd3VoaGNoenNwbXV4Z2Fqdm1nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcyOTg1ODcsImV4cCI6MjA3Mjg3NDU4N30.zqkd7sodgnybz-wPYWBXJexf8K0P1s5IQQW903ZEdWk"
    )
        
    @Published var isAuthenticated = false
    @Published var user: User?
    @Published var watchlistManager: WatchlistManager?
    @Published var errorMessage: String?
        
    private init() {
        // Keep init completely minimal - don't create WatchlistManager here
        print("SupabaseManager init completed")
    }
    
    func initialize() async {
        print("Creating WatchlistManager...")
        self.watchlistManager = WatchlistManager()
        print("WatchlistManager created")
        await checkAuthenticationStatus()
    }
    
    func isValidEmail(_ email: String) -> Bool {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            return emailTest.evaluate(with: email)
    }
    
    
    func signup(email: String, password: String) async throws {
        try await client.auth.signUp(email: email, password: password)
    }
    
    
    func signin(email: String, password: String) async throws {
        let session = try await client.auth.signIn(email: email, password: password)
        DispatchQueue.main.async {
            self.isAuthenticated = true
            self.user = session.user
        }
    }
    
    
    func signout() async throws {
        try await client.auth.signOut()
        
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.user = nil
        }
    }
    
    func setupWatchlistSync() {
        watchlistManager?.handleAuthStateChange()
    }
    
    private func checkAuthenticationStatus() async {
        do{
            let session = try await client.auth.session
            await MainActor.run {
                self.isAuthenticated = true
                self.user = session.user
            }
        }
        catch {
            await MainActor.run {
                self.isAuthenticated = false
                self.user = nil
            }
            print("Auth check error: \(error)")
        }
        
    }
    
    func uploadThumbnail(imageData: Data, fileName: String) async -> String? {
        let bucketName = "thumbnails" // replace with your bucket name

        do {
            let filePath = "thumbnails/\(fileName)" // Structure this path as needed
            
            // Perform the upload
            let _ = try await client.storage
                .from(bucketName)
                .upload(path: filePath, file: imageData)
            
            let fileUrl = try client.storage
                .from(bucketName)
                .getPublicURL(path: filePath)
            
            let urlString = fileUrl.absoluteString
            return urlString
            
            
        } catch {
            print("Error uploading image: \(error.localizedDescription)")
            return nil
        }
    }




}
