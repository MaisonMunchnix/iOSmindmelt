//
//  NotificationDelegate.swift
//  MindMelt
//
//  Created by STUDENT on 9/30/25.
//


import Foundation
import UserNotifications
import SwiftUI

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    // This makes notifications show even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("📱 Notification received while app is open: \(notification.request.content.title)")
        
        // Show banner, badge, and play sound even when app is open
        completionHandler([.banner, .badge, .sound])
    }
    
    // Handle when user taps the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("👆 User tapped notification: \(response.notification.request.content.title)")
        
        // You can navigate to specific content here if needed
        completionHandler()
    }
}
