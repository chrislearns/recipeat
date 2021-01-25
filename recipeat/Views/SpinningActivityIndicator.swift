//
//  SpinningActivityIndicator.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/23/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct SpinningActivityIndicator: View {
    @State var isAnimating = false
    var body: some View {
        Image("activityIndicator")
        .resizable()
        .scaledToFit()
            .rotationEffect(Angle(degrees: isAnimating ? 0 : 360))
            .animation(
                Animation.linear(duration: 1.5)
                .repeatForever(autoreverses: false)
        )
            .onAppear(){
                self.isAnimating = true
        }
    }
}

struct SpinningActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        SpinningActivityIndicator()
    }
}
