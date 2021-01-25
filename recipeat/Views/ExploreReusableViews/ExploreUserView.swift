//
//  ExploreUserView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/9/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct ExploreUserView: View {
    
    @State var thisUser:user
    @State var loadedUserImage:UIImage?
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading, spacing:10){
                HStack(alignment: .top){
                    Image(uiImage: loadedUserImage == nil ? UIImage(named: "chefAvatar")! : loadedUserImage!)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 125, height: 125)
                        .foregroundColor(Color.init(white:0.5))
                        .clipShape(Circle())
                        .padding(10)
                    VStack(alignment: .leading){
                        Text(thisUser.name)
                            .lineLimit(2)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.black)
                        
                        Text("\(thisUser.quantity_followers) followers")
                            
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.init(white: 0.5))
                        Text("\(thisUser.quantity_following) following")
                            
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.init(white: 0.5))
                        Text("\(thisUser.publishedRecipes != nil ? "\(thisUser.publishedRecipes!.count)" : "--") recipes")
                            
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.init(white: 0.7))
                        
                    }.padding(.top, 10)
                    Spacer()
                    
                    
                }
                
                Text("@\(thisUser.username)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.init(white: 0.5))
                if thisUser.bio != "" {
                    Text("\(thisUser.bio)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.init(white: 0.7))
                }
                
//                VStack(alignment: .leading, spacing:4){
//                    Text("Top Recipes")
//                        .font(.system(size: 20, weight: .semibold))
//                        .foregroundColor(Color.black)
//                        .padding(.bottom, 2)
//                    ForEach(0..<3){i -> AnyView? in
//                        //This puts the top 3 recipes up for display while making sure our loop index doesn't go out of range
//                        if self.thisUser.publishedRecipes != nil {
//                            if i < self.thisUser.publishedRecipes!.count{
//                                let thisRecipe = self.thisUser.publishedRecipes!.sorted{ $0.likes.count > $1.likes.count }[i]
//                                return AnyView(
//                                    HStack{
//                                        Image("14")
//                                            .renderingMode(.template)
//                                            .resizable()
//                                            .scaledToFit()
//                                            .frame(width: 12, height: 12)
//                                            .padding(6)
//                                            .foregroundColor(.white)
//                                            .background(darkGreen)
//                                            .cornerRadius(16)
//                                            .clipped()
//
//                                        Text(thisRecipe.title)
//                                            .lineLimit(1)
//                                            .foregroundColor(Color.init(white:0.5))
//                                        Spacer()
//                                        HStack{
//                                            Text("\(thisRecipe.likes.count)")
//                                            Image(systemName: "heart.fill")
//                                        }.foregroundColor(darkPink)
//                                    }
//
//                                )
//                            } else {
//                                return nil
//                            }
//                        } else {
//                            return nil
//                        }
//                    }
//
//                }
//                .padding(.horizontal, 10)
                
            }
        }
        .padding(10)
        .frame(width: 300)//.frame(maxHeight: 320)
        .background(Color.init(white: 0.95))
        .clipped()
            
        .onAppear(){
            DispatchQueue.main.async{
                let user_imageString = "user/\(self.thisUser.id.uuidString)/profilepicture"
                loadImage_cache_FireStore(imageString: user_imageString, resized: .s128, minimumRecency: .Day1, completion: {
                    imageData in
                    if let imageData = imageData {
                        self.loadedUserImage = UIImage(data: imageData)!
                    } else {
                        print("couldn't grab image")
                    }
                })
            }
        }
    }
}

//struct ExploreUserView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExploreUserView()
//    }
//}
