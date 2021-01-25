//
//  MenuButtonViews.swift
//  recipeat
//
//  Created by Christopher Guirguis on 10/5/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct ButtonColoring {
    var titleColor:Color?
    var subtitleColor:Color?
    var backgroundColor:Color?
    var iconColor:Color?
    var shadowColor:Color?
}

struct MediumButtonView: View {
    var image:String
    var title:String
    var subtitle:String?
    var buttonColoring:ButtonColoring
        
    var body: some View {
        ZStack{
            if buttonColoring.backgroundColor != nil {
                buttonColoring.backgroundColor!
            } else {
                Color.white
            }
            HStack{
                Image(systemName: image)
                    .foregroundColor(buttonColoring.iconColor)
                VStack(alignment: .leading){
                    Text(title)
                        .font(Font.system(size: 15, weight: .bold))
                        .foregroundColor(buttonColoring.titleColor)
                    if subtitle != nil {
                        Text(subtitle!)
                        .font(Font.system(size: 12, weight: .medium))
                            .foregroundColor(buttonColoring.subtitleColor)
                    }
                }
                Spacer()
            }.padding(.horizontal).padding(.vertical, 10)
        }
//        .frame(height: 50)
        .cornerRadius(10)
        .clipped()
        .shadow(color: buttonColoring.shadowColor == nil ? Color.gray: buttonColoring.shadowColor!, radius: 2, x: 1, y: 2)
//        .padding(.horizontal)
    }

    
}

struct SquareButtonView: View {
    var image:String
    var title:String
    var subtitle:String?
    var buttonColoring:ButtonColoring
        
    var body: some View {
        ZStack{
            if buttonColoring.backgroundColor != nil {
                buttonColoring.backgroundColor!
            } else {
                Color.white
            }

                VStack(alignment: .center){
                    Image(systemName: image)
                        .foregroundColor(buttonColoring.iconColor)
                        .font(Font.system(size: 30))
                    Spacer().frame(height: 10)
                    Text(title)
                        .font(Font.system(size: 15, weight: .bold))
                        .foregroundColor(buttonColoring.titleColor)
                    if subtitle != nil {
                        Text(subtitle!)
                        .font(Font.system(size: 12, weight: .medium))
                            .foregroundColor(buttonColoring.subtitleColor)
                    }
                }
                
            .padding(.horizontal).padding(.vertical, 10)
        }
        .frame(width: UIScreen.main.bounds.width/3, height: UIScreen.main.bounds.width/3)
        .cornerRadius(10)
        .clipped()
        .shadow(color: buttonColoring.shadowColor == nil ? Color.gray: buttonColoring.shadowColor!, radius: 2, x: 1, y: 2)
        .padding(.horizontal)
    }

    
}

