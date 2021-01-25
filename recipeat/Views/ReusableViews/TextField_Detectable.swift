//
//  TextField_Detectable.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/3/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct TextField_Detectable: View {
    @Binding var text:String
    @State var lastVal = ""
    
    var title:String
    var onEditingChanged: (Bool) -> Void
    var onValChanged: (String) -> Void
    
    var onCommit:() -> Void
    
    var body: some View {
        ZStack{
            TextField(title, text: $text, onEditingChanged: self.onEditingChanged, onCommit: self.onCommit)
                
            GeometryReader{geo -> Text? in
                if self.text != self.lastVal {
                    print("val change")
                    print("\(self.text) || \(self.lastVal)")
                    DispatchQueue.main.async {
                        self.changeVal()
                    }
                    print("\(self.text) || \(self.lastVal)")
                    var _ = self.onValChanged(self.text)
                }
                
                return nil
                
            }.frame(height:0)
        }
    }
    
    func changeVal(){
        lastVal = text
    }
}

//struct TextField_Detectable_Previews: PreviewProvider {
//    static var previews: some View {
//        TextField_Detectable()
//    }
//}
