//
//  ExploreRecipeView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/9/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct ExploreRecipeView: View {
    

    @State var recipe:RecipePost
    @State var loadedUserImage:UIImage?
    @State var loadedRecipeImage:UIImage?
    
    var body: some View {
        
        
        VStack(alignment: .leading, spacing:5){
            
            Image(uiImage: loadedRecipeImage == nil ? UIImage(named: "fishPlatter")! : loadedRecipeImage!)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: loadedRecipeImage == nil ? ContentMode.fit : ContentMode.fill)
//                .scaledToFit()
                .frame(width: 330, height: 180)
                .clipped()
                
                .overlay(LinearGradient(gradient: Gradient(colors: [Color.clear,Color.clear, Color.black.opacity(0.8)]), startPoint: .top, endPoint: .bottom))
                .cornerRadius(10)
                .overlay(
                    VStack{
                        HStack{
                            UserCapsule(username: $recipe.postingUser.username, image: $loadedUserImage)
                                .padding(.top, 7).padding(.leading, 7)
                            Spacer()
                        }
                        Spacer()
                        HStack{
                            HStack(spacing:4){
                                Image(systemName: "heart.fill")
                                    .padding(.vertical, 5)
                                    .padding(.leading, 5)
                                    .padding(.trailing, 2)
                                Text("\(recipe.likes.count)")
                                    .fontWeight(.medium)
                                    .padding(.trailing, 10)
                            }
                            .padding(5)
                            .font(.system(size: 15 ))
                            .foregroundColor(Color.white).opacity(0.8)
                            Spacer()
                            
                        }
                    }
            )
            HStack{
                Text(recipe.title)
                    .padding(.leading, 5)
                    .font(.system(size: 24, weight: .semibold))
                    .lineLimit(1)
                    .foregroundColor(Color.black)
                    
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            
            
        }.frame(width: 330, height: 220)
            
        .onAppear(){
            DispatchQueue.main.async{
                let user_imageString = "user/\(self.recipe.postingUser.id.uuidString)/profilepicture"
                loadImage_cache_FireStore(imageString: user_imageString, resized: .s64, minimumRecency: .Day1, completion: {
                imageData in
                DispatchQueue.main.async{
                if let imageData = imageData {
                    self.loadedUserImage = UIImage(data: imageData)!
                } else {
                    println("couldn't grab image", 2)
                }
                }
            })
            
            let recipe_imageString = "recipe/\(self.recipe.id.uuidString)/img0"
            loadImage_cache_FireStore(imageString: recipe_imageString, resized: .s512, minimumRecency: .Day10, completion: {
                imageData in
                if let imageData = imageData {
                    self.loadedRecipeImage = UIImage(data: imageData)!
                } else {
                    println("couldn't grab image", 2)
                }
            })
            }
        }
    }
}

//struct ExploreRecipeView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExploreRecipeView()
//    }
//}
