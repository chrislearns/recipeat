//
//  CustomActivityIndicator.swift
//  recipeat
//
//  Created by Christopher Guirguis on 4/24/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct CustomActivityIndicator: View {
    
    @EnvironmentObject var env: GlobalEnvironment
    
    @State var isAnimating = false
    @State var image = 19
    
    var fgColor = Color.white
    var bgColor = darkPink
    
    
    var body: some View {
        ZStack{
            bgColor
            VStack{
                VStack{
                    Image("\(image)")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width:100, height:100)
                        .rotationEffect(Angle(degrees: isAnimating ? 1080 : 0))
                        .animation(
                            Animation
                                .easeInOut(duration: 0.7)
                                .delay(isAnimating ? 0.5 : 0)
                                .repeatForever(autoreverses: false)
                    )
                        .scaleEffect(isAnimating ? 1 : 0)
                        .animation(
                            Animation
                                .easeInOut(duration: 0.7)
                                .delay(isAnimating ? 0.5 : 0)
                                .repeatForever(autoreverses: true)
                    )
                }.frame(width: 130, height: 130)
            }.onAppear(){
                Timer.scheduledTimer(withTimeInterval: 2.4, repeats: true) {_ in
                    self.image = Int.random(in: 0...29)
                }
                self.isAnimating = true
            }.foregroundColor(fgColor)
        }
        .edgesIgnoringSafeArea(.vertical)
    }
}

struct CustomActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        CustomActivityIndicator()
            .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
    }
}
