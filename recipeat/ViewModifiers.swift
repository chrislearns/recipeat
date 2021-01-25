//
//  ViewModifiers.swift
//  recipeat
//
//  Created by Christopher Guirguis on 4/30/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import Foundation
import SwiftUI

public struct CapsuleStyle: ButtonStyle {
    var bgColor:Color
    var fgColor:Color
    var fontSize:CGFloat = 20
    var hPadding:CGFloat = 50
    
    var height:CGFloat = 50
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            
            .padding(.horizontal, hPadding)
            
            .frame(height:height)
            .foregroundColor(fgColor)
            .background(bgColor)
            .cornerRadius(height/2)
            .font(.system(size: fontSize))
            .shadow(radius: 3, y: 3)
            .padding(5)
    }
}
