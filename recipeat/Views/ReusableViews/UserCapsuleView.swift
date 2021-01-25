//
//  UserCapsuleView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/9/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct UserCapsule: View {
        @Binding var username:String
        @Binding var image:UIImage?
        var body: some View {
            
            HStack(spacing:0){
//            Image(uiImage: )
            Image(uiImage: image == nil ? UIImage(named: "chefAvatar")! : image!)
                .renderingMode(.original)
                
                .resizable()
                .scaledToFill()
                //                .padding(5)
                .frame(width: 26, height: 26)
                .foregroundColor(Color.init(white:0.5))
                .cornerRadius(13)
                .padding(5)
            Text("\(username)")
                .fontWeight(.medium)
                .padding(.trailing, 7)
        }.background(Color.white.opacity(0.7))
        .foregroundColor(Color.black)
        .cornerRadius(18)
        .shadow(radius: 2)
        
    }
}
//
//struct UserCapsuleView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserCapsuleView()
//    }
//}
