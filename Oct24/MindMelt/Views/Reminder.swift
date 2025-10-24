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
    var body: some View{
        ZStack{
            Color.black.ignoresSafeArea()
            
            VStack{
                HStack{
                    HStack{
                        Image("mm")
                            .resizable()
                            .scaledToFit()
                            .frame(width:20, height: 30)
                        
                        Text("Set Reminder")
                            .foregroundColor(.white)
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
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                    
                    
                }
                
                VStack{
                    HStack{
                        Text("Set Date")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "calendar")
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    HStack{
                        Text("Set Time")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "clock")
                            .foregroundColor(.white)
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
