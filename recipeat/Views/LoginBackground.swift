//
//  LoginBackground.swift
//  recipeat
//
//  Created by Christopher Guirguis on 4/23/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct LoginBackground: View {
    
    var itemsPerRow = 6
    @State var isAnimating = false
    var body: some View {
        
        VStack(spacing:0){
            ForEach(0..<getNumberOfRows()){i in
                HStack(spacing:0){
                    ForEach(0..<self.itemsPerRow){j in
                        Image(self.getImage(indexLocation: (i * self.itemsPerRow) + j))
                        .resizable()
                        .scaledToFit()
                        .padding() .frame(width:UIScreen.main.bounds.width/CGFloat(self.itemsPerRow), height: UIScreen.main.bounds.width/CGFloat(self.itemsPerRow))
                            .opacity(self.isAnimating ? 1 : 0)
                        .animation(
                            Animation
                                .linear(duration: Double.random(in: 1.0...2.0))
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...1.5))
                        )
                    }
                }
            }
        }.onAppear(){
            self.isAnimating = true
        }
        
    }
    
    func getImage(indexLocation:Int) -> String{
        let totalNumberOfAssets = 30
        print(indexLocation % totalNumberOfAssets)
        return String(indexLocation % 30)
    }
    
    func getNumberOfRows() -> Int{
        let heightPerItem = UIScreen.main.bounds.width/CGFloat(self.itemsPerRow)
        return Int(UIScreen.main.bounds.height/heightPerItem) + 1
    }
}

struct LoginBackground_Previews: PreviewProvider {
    static var previews: some View {
        LoginBackground()
    }
}
