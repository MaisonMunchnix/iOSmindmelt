//
//  Login.swift.swift
//  MindMelt
//
//  Created by STUDENT on 9/30/25.
//


import Foundation
import SwiftUI

struct Login: View {
    @StateObject private var supabase = SupabaseManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    
    
    var body: some View {
        
        ZStack{
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack{
                VStack{
                    Text("M I N D  M E L T")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(themeManager.primaryTextColor)
                    
                    Image("mm")
                        .resizable()
                        .scaledToFit()
                        .frame(width:250, height: 300)
                }
                
                
                
                
                
                VStack(spacing: 20) {
                    
                    if showError && !errorMessage.isEmpty{
                        VStack{
                            HStack{
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .multilineTextAlignment(.leading)
                                
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red.opacity(0.3), lineWidth:1)
                            )
                        }
                        .padding(.horizontal)
                        .animation(.easeInOut(duration:0.3), value: showError)
                    }
                    
                    
                    TextField("Email address", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .onChange(of: email) { newValue in
                            email = newValue.lowercased()
                            
                            clearError()
                        }
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)

                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .onChange(of: password){ _ in
                            clearError()
                        }
                    
                    Button(action: {
                        handleAuth()
                    }){
                        HStack{
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint:.white))
                                    .scaleEffect(0.8)
                            }
                            
                            Text(isLoading ? "Please wait..." : (isSignUp ? "Sign Up" : "Sign In"))
                                .font(.system(size:18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(isButtonDisabled ? Color.gray : Color.red)
                        .cornerRadius(10)
                        .padding()
                    }.disabled(isButtonDisabled)

                    
                    Button(isSignUp ? "Already have account? Sign In" : "Need account? Sign Up") {
                        isSignUp.toggle()
                        clearError()
                    }
                    .disabled(isLoading)
                }
                .padding()
            }
        }
    }
    
    
    private var isButtonDisabled: Bool {
        return isLoading || email.isEmpty || password.isEmpty
    }
    
    
    private func handleAuth() {
        guard !email.isEmpty, !password.isEmpty else{
            showErrorMessage("Please enter both email and password.")
            return
        }
        
        guard isValidEmail(email) else{
            showErrorMessage("Please enter a valid email address.")
            return
        }
        
        
        guard password.count >= 6 else{
            showErrorMessage("Password must be atleast 6 characters long.")
            return
        }
        
        isLoading = true
        clearError()
        
        Task{
            do{
                if isSignUp{
                    try await supabase.signup(email: email, password: password)
                    await MainActor.run {
                        showErrorMessage("Account created successfully! Please check your email inbox to verify your account before signing in.")
                        isLoading = false
                    }
                }else{
                    try await supabase.signin(email: email, password: password)
                    await MainActor.run {
                        isLoading = false
                    }
                }
            }catch{
                await MainActor.run{
                    isLoading = false
                    handleAuthError(error)
                }
            }
        }
    }
    
    private func handleAuthError(_ error: Error) {
        let errorDescription = error.localizedDescription.lowercased()
        
        if errorDescription.contains("Invalid login credentials") ||
           errorDescription.contains("Invalid email or password") ||
           errorDescription.contains("email not confirmed") {
            showErrorMessage("Incorrect email or password. Please try again.")
        } else if errorDescription.contains("user already registered") {
            showErrorMessage("An account with this email already exists. Try signing in instead.")
            isSignUp = false
        } else if errorDescription.contains("email not confirmed") {
            showErrorMessage("Please check your email and click the confirmation link before signing in.")
        } else if errorDescription.contains("network") || errorDescription.contains("internet") {
            showErrorMessage("Network error. Please check your internet connection and try again.")
        } else if errorDescription.contains("weak password") {
            showErrorMessage("Password is too weak. Please use at least 6 characters.")
        } else if errorDescription.contains("invalid email") {
            showErrorMessage("Please enter a valid email address.")
        } else {
            // Generic error message for unknown errors
            showErrorMessage("Something went wrong. Please try again later.")
        }
        
        print("Auth error details: \(error)")
    }
    
    
    private func showErrorMessage(_ message: String){
        errorMessage = message
        withAnimation(.easeInOut(duration: 0.3)){
            showError = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0 ){
            clearError()
        }
    }
    
    
    private func clearError(){
        withAnimation(.easeInOut(duration: 0.3)){
            showError = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
            errorMessage = ""
        }
    }
    
    
    
    private func isValidEmail(_ email: String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
}


#Preview {
    Login()
}
