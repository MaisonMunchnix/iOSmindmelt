//
//  Reminder.swift
//  MindMelt
//
//  Created by STUDENT on 9/30/25.
//


import Foundation

import SwiftUI
 
struct Reminder : View{
    @State var fakebutton = false
    @EnvironmentObject var themeManager: ThemeManager
    var body: some View{
        ZStack{
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack{
                HStack{
                    HStack{
                        Image("mm")
                            .resizable()
                            .scaledToFit()
                            .frame(width:20, height: 30)
                        
                        Text("Set Reminder")
                            .foregroundColor(themeManager.primaryTextColor)
                            .fontWeight(.bold)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Text("Cancel").foregroundColor(.red).padding()
                }
                
//                Divider()
//                    .frame(height: 1)
//                    .foregroundColor(.white)
                
                VStack{
                    Image("thumb")
                        .scaledToFit()
                        .padding()
                        .frame(width: 200, height: 150)
                        .cornerRadius(20)
                    
                    Text("Google Firebase Studio in 23 minutes")
                        .foregroundColor(themeManager.primaryTextColor)
                        .fontWeight(.medium)
                    
                    
                }
                
                VStack{
                    HStack{
                        Text("Set Date")
                            .foregroundColor(themeManager.primaryTextColor)
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "calendar")
                            .foregroundColor(themeManager.primaryTextColor)
                    }
                    .padding()
                    
                    HStack{
                        Text("Set Time")
                            .foregroundColor(themeManager.primaryTextColor)
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "clock")
                            .foregroundColor(themeManager.primaryTextColor)
                    }
                    .padding()
                }
                .padding()
                .cornerRadius(50)
                
                Spacer()
                Button(action:
                        {
                            fakebutton = true
                        }
                ){
                    Text("Save reminder")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(13)
                }
                
            }
            
            
        }
       
    }
}
 
 
#Preview {
    Reminder()
}
