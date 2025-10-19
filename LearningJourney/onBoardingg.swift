//
//  onBoardingg.swift
//  LearningJourney
//
//  Created by Deemah Alhazmi on 16/10/2025.
//

import Foundation
import SwiftUI

struct onBoardingg: View {
    var body: some View {
        ZStack{
            //background color
            Color.black.ignoresSafeArea()
            Color.black.opacity(0.1).edgesIgnoringSafeArea(.all)
            
            VStack (){
                Spacer()
                
            
                ZStack (){
                    Circle()
                    .fill(Color(red: 0.25, green: 0.10, blue: 0.00).opacity(0.8))
                    .frame(width: 109, height: 109)
                    .overlay(
                        Circle()
                            .stroke(
                                Color.orange.opacity(0.45),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                            .shadow(color: Color.orange.opacity(0.001), radius: 0, x: 0, y: 0)
                        
                    )
            
                Image(systemName: "flame.fill")
                    .font(.system(size: 45))
                    .foregroundColor(.orange)
                    
            }
            // Headline
            VStack(alignment: .leading, spacing: 8) {
                Text("Hello Learner")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)

                Text("This app will help you learn everyday!")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding()
            }
        }
        
    }
}
#Preview {
    onBoardingg()
}
