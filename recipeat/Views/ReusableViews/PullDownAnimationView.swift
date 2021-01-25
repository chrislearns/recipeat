//
//  PullDownAnimationView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 11/5/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct PullDownAnimationView:View{
    var vHeight:CGFloat = 80
    var items = 20
    
    @State var animate:Bool = false
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [
                Color.black.opacity(0.1),
                Color.black.opacity(0.0),
                Color.black.opacity(0.0),
            ]), startPoint: .top, endPoint: .bottom)
            ForEach(0..<items){i in
                Image("pd_\(i)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: vHeight/2)
                    .shadow(radius: 2)
                    .zIndex(Double.random(in: 0...100))
                    
                    .rotationEffect(.degrees(Double.random(in: -10...10)))
                    .offset(y: animate ? getJump(i) : 0)
                    .offset(x:-UIScreen.main.bounds.width/2)
//                    .opacity(Double(i)/10)
                    .offset(x: CGFloat(i)/19 * UIScreen.main.bounds.width)
                    .offset(y: getHeight(i))
                    
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 0.6...1.2))
                            
                            .repeatForever(autoreverses: true)
                            
                )
                    
                    
                    
                
                
            }
            Text("REFRESHING")
                .font(.system(size: 14, weight: .semibold))
        }.frame(width: UIScreen.main.bounds.width, height: 80)
        
        .background(
//            Color.white
            Image("onboard_background")
                .resizable()
                .scaledToFill()
        )
        .clipped()
        .onAppear{
            animate = true
        }
    }
    func getHeight(_ i:Int) -> CGFloat{
        var height = (vHeight/2
                        - (((abs(CGFloat((items/2)-i))) * vHeight)/(CGFloat(items) * 3)))
//        if i == 0 || i == items - 1 {
//            height -= vHeight/4
//        } else if i == 1 || i == items - 2 {
//            height -= vHeight/5
//        } else if i == 2 || i == items - 3 {
//            height -= vHeight/6
//        }
        return height
    }
    
    func getJump(_ i:Int) -> CGFloat {
        let height =
            -((abs(CGFloat((items/2)-i))) * vHeight)/(CGFloat(items) * 3) + CGFloat.random(in: 0...5)
//        if i == 0 || i == items - 1 {
//            height -= vHeight/4
//        } else if i == 1 || i == items - 2 {
//            height -= vHeight/5
//        } else if i == 2 || i == items - 3 {
//            height -= vHeight/6
//        }
        return height
    }
}

