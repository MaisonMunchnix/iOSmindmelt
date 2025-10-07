//
//  note.swift
//  MindMelt
//
//  Created by STUDENT on 10/7/25.
//

// add to accountsetttings
import SwiftUI

struct AccountSettingsView2: View {
    @StateObject private var supabase = SupabaseManager.shared
    @Environment(\.dismiss) private var dismiss
    
    // Change password states
    @State private var showChangePassword = false
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isChangingPassword = false
    @State private var passwordErrorMessage = ""
    @State private var passwordSuccessMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Account Information") {
                    if let user = supabase.user {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email ?? "N/A")
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("User ID")
                            Spacer()
                            Text(user.id.uuidString.prefix(8) + "...")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
                
                Section("Security") {
                    Button(action: {
                        showChangePassword = true
                    }) {
                        HStack {
                            Image(systemName: "lock.rotation")
                                .foregroundColor(.red)
                            Text("Change Password")
                                .foregroundColor(.black)
                        }
                    }
                }
                
                Section("Preferences") {
                    Toggle("Email Notifications", isOn: .constant(true))
                    Toggle("Push Notifications", isOn: .constant(true))
                }
                
                Section("App Information") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    Button("Delete Account") {
                        // Handle account deletion
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
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordView(
                    isPresented: $showChangePassword,
                    onPasswordChanged: {
                        passwordSuccessMessage = "Password changed successfully!"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            passwordSuccessMessage = ""
                        }
                    }
                )
            }
            .alert("Success", isPresented: .constant(!passwordSuccessMessage.isEmpty)) {
                Button("OK") {
                    passwordSuccessMessage = ""
                }
            } message: {
                Text(passwordSuccessMessage)
            }
        }
    }
}

// Change Password Modal View
struct ChangePasswordView: View {
    @Binding var isPresented: Bool
    var onPasswordChanged: () -> Void
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    @StateObject private var supabase = SupabaseManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        
                        Text("Change Password")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("Enter your new password below")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Error message
                    if showError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    
                    // Password fields
                    VStack(spacing: 15) {
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Password")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            
                            SecureField("Enter current password", text: $currentPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: currentPassword) { _ in
                                    clearError()
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("New Password")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            
                            SecureField("Enter new password", text: $newPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: newPassword) { _ in
                                    clearError()
                                }
                            
                            // Password strength indicator
                            if !newPassword.isEmpty {
                                HStack(spacing: 4) {
                                    ForEach(0..<4) { index in
                                        Rectangle()
                                            .fill(index < passwordStrength ? strengthColor : Color.gray.opacity(0.2))
                                            .frame(height: 4)
                                    }
                                }
                                
                                Text(passwordStrengthText)
                                    .font(.caption2)
                                    .foregroundColor(strengthColor)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm New Password")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            
                            SecureField("Confirm new password", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: confirmPassword) { _ in
                                    clearError()
                                }
                            
                            // Match indicator
                            if !confirmPassword.isEmpty {
                                HStack {
                                    Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(passwordsMatch ? .green : .red)
                                    Text(passwordsMatch ? "Passwords match" : "Passwords don't match")
                                        .font(.caption2)
                                        .foregroundColor(passwordsMatch ? .green : .red)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Password requirements
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password Requirements:")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        PasswordRequirement(met: newPassword.count >= 8, text: "At least 8 characters")
                        PasswordRequirement(met: newPassword.contains(where: { $0.isUppercase }), text: "One uppercase letter")
                        PasswordRequirement(met: newPassword.contains(where: { $0.isNumber }), text: "One number")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            changePassword()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text(isLoading ? "Changing..." : "Change Password")
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isValidForm ? Color.red : Color.gray)
                            .cornerRadius(10)
                        }
                        .disabled(!isValidForm || isLoading)
                        
                        Button("Cancel") {
                            isPresented = false
                        }
                        .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Computed Properties
    
    private var isValidForm: Bool {
        return !currentPassword.isEmpty &&
               !newPassword.isEmpty &&
               !confirmPassword.isEmpty &&
               passwordsMatch &&
               newPassword.count >= 8
    }
    
    private var passwordsMatch: Bool {
        return newPassword == confirmPassword && !confirmPassword.isEmpty
    }
    
    private var passwordStrength: Int {
        var strength = 0
        
        if newPassword.count >= 8 { strength += 1 }
        if newPassword.count >= 12 { strength += 1 }
        if newPassword.contains(where: { $0.isUppercase }) { strength += 1 }
        if newPassword.contains(where: { $0.isNumber }) { strength += 1 }
        if newPassword.contains(where: { "!@#$%^&*()_+-=[]{}|;:,.<>?".contains($0) }) { strength += 1 }
        
        return min(strength, 4)
    }
    
    private var strengthColor: Color {
        switch passwordStrength {
        case 0...1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        default: return .gray
        }
    }
    
    private var passwordStrengthText: String {
        switch passwordStrength {
        case 0...1: return "Weak"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Strong"
        default: return ""
        }
    }
    
    // MARK: - Functions
    
    private func changePassword() {
        guard isValidForm else { return }
        
        isLoading = true
        clearError()
        
        Task {
            do {
                // Verify current password by trying to sign in
                try await supabase.client.auth.signIn(
                    email: supabase.user?.email ?? "",
                    password: currentPassword
                )
                
                // Update password
                try await supabase.client.auth.update(
                    user: UserAttributes(password: newPassword)
                )
                
                await MainActor.run {
                    isLoading = false
                    isPresented = false
                    onPasswordChanged()
                }
                
            } catch {
                await MainActor.run {
                    isLoading = false
                    handlePasswordError(error)
                }
            }
        }
    }
    
    private func handlePasswordError(_ error: Error) {
        let errorDescription = error.localizedDescription.lowercased()
        
        if errorDescription.contains("invalid login credentials") {
            showErrorMessage("Current password is incorrect")
        } else if errorDescription.contains("password") && errorDescription.contains("weak") {
            showErrorMessage("Password is too weak. Try adding more characters or symbols.")
        } else if errorDescription.contains("same password") {
            showErrorMessage("New password must be different from current password")
        } else {
            showErrorMessage("Failed to change password. Please try again.")
        }
        
        print("Password change error: \(error)")
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        withAnimation {
            showError = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            clearError()
        }
    }
    
    private func clearError() {
        withAnimation {
            showError = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            errorMessage = ""
        }
    }
}

// Password Requirement Row Component
struct PasswordRequirement: View {
    let met: Bool
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .foregroundColor(met ? .green : .gray.opacity(0.3))
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .foregroundColor(met ? .green : .gray)
        }
    }
}

#Preview {
    AccountSettingsView()
}
