//
//  Login.swift
//  Watchlist
//
//  Created by STUDENT on 9/2/25.
//

import Foundation
import SwiftUI

struct Login: View {
    @StateObject private var supabase = SupabaseManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    
    var body: some View {
        
        ZStack{
            
            VStack{
                VStack{
                    Text("M I N D  M E L T")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Image("mm")
                        .resizable()
                        .scaledToFit()
                        .frame(width:250, height: 300)
                }
                
                
                
                
                
                VStack(spacing: 20) {
                    TextField("Email address", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .onChange(of: email) { newValue in
                            email = newValue.lowercased()
                        }

                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        Task {
                            do {
                                if isSignUp {
                                    try await supabase.signup(email: email, password: password)
                                } else {
                                    try await supabase.signin(email: email, password: password)
                                }
                            } catch {
                                print("Auth error: \(error)")
                            }
                        }
                    }) {
                        Text(isSignUp ? "Sign Up" : "Sign In")
                            .font(.system(size: 18, weight: .semibold))  // Customize the font
                            .foregroundColor(.white)  // Text color
                            .frame(maxWidth: .infinity, minHeight: 50)  // Set width and height
                            .background(isSignUp ? Color.gray : Color.red)  // Background color
                            .cornerRadius(10)  // Rounded corners
                            .padding()  // Add some padding around the button
                    }

                    
                    Button(isSignUp ? "Already have account? Sign In" : "Need account? Sign Up") {
                        isSignUp.toggle()
                    }
                }
                .padding()
            }
            
            
                
                
            
        }
        
    }
}


#Preview {
    Login()
}
