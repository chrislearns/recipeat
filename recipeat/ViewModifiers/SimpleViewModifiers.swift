//
//  SimpleViewModifiers.swift
//  recipeat
//
//  Created by Christopher Guirguis on 10/3/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct RoundedOutline: ViewModifier {
    var color:Color = Color.init(white: 0.8)
    func body(content: Content) -> some View {
        content
            
                    .padding(5)
            .background(Color.white)
            .cornerRadius(10)
                
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1).foregroundColor(color))
    }
}




struct None: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}

struct TabBarImage:ViewModifier{
    
    func body(content: Content) -> some View {
        content
            .frame(width:25, height:25)
//            .background(Color.red)
            .shadow(radius: 0)
    }
}
