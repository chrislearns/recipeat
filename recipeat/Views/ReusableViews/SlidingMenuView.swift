//
//  SlidingMenuView.swift
//  codeTutorial_slidingMenu
//
//  Created by Christopher Guirguis on 4/3/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct MenuButton:Identifiable {
    var id = UUID()
    var text:String
    var sfsymbol:String
    var active:Bool = true
    var action:() -> Void
}

struct SlidingMenuView: View {
    
    var buttons:[MenuButton]
    var body: some View {
        
        HStack{
            Spacer()
            VStack{
                Spacer().frame(height:UIApplication.shared.windows.first?.safeAreaInsets.top)
                Spacer().frame(height:30)
                ForEach(buttons, id: \.id){thisButton in
                    Button(action: {
                        if thisButton.active {
                            thisButton.action()
                        }
                        
                    }){
                        HStack{
                            
                            Image(systemName: thisButton.sfsymbol)
                            Text(thisButton.text)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .foregroundColor(thisButton.active ? Color.black : Color.init(white: 0.7))
                    }.frame(width: 220)
                }
                Spacer()
            }
            .edgesIgnoringSafeArea(.all)
            
        }
    }
}
//
//struct SlidingMenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        SlidingMenuView()
//    }
//}
