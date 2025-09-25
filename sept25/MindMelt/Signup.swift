//
//  Signup.swift
//  MindMelt
//
//  Created by Kyla Enriquez on 9/22/25.
//

import Foundation

import SwiftUI


struct Signup: View {
    @State var login = false
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPw: String = ""
    
    var body: some View {
        
        ZStack{
            Color.black.ignoresSafeArea()
            VStack{
                Text("M I N D  M E L T")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Image("mm")
                    .resizable()
                    .scaledToFit()
                    .frame(width:150, height: 200)
                
                
                VStack{
                    
                    //
                    VStack{
                        TextField(text: $email, prompt:
                            Text("  Email address")
                            .font(.system(size:24))
                        
                        
                        ){
                            Text("Email address")
                            
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .cornerRadius(20)
                        .font(.system(size:23))
                        .frame(height: 40)
                        .disableAutocorrection(true)
                        
                        SecureField(text: $password, prompt:
                            Text("  Password")
                            .font(.system(size:24))
                        
                        ){
                            Text("Password")
                            
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .cornerRadius(20)
                        .font(.system(size:23))
                        .frame(height: 40)
                        .padding(.top,10)
                        .disableAutocorrection(true)
                        
                        SecureField(text: $password, prompt:
                            Text("  Confirm password")
                            .font(.system(size:24))
                        
                        ){
                            Text("Password")
                            
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .cornerRadius(20)
                        .font(.system(size:23))
                        .frame(height: 40)
                        .padding(.top,10)
                        .disableAutocorrection(true)
                        
                    }
                    .padding()
                        
                        
                    
                    Button(action:{
                        login = true
                    }, label:{
                        Text("Create account")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(13)
                        
                    })
                    .padding()
                    
                    
                    
                    
                    
                    
//                    NavigationLink(destination: Landing(), isActive: $login) {
//                        EmptyView()
//                    }
                    
                }
            }
            
        }
    }
}

#Preview{
    Signup()
}
                
