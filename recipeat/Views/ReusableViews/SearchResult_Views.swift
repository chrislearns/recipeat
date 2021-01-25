//
//  SearchResult_Views.swift
//  recipeat
//
//  Created by Christopher Guirguis on 4/27/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct SearchResult_User: View {
    var U:trunc_user
    @State var resultImage:UIImage? = nil
    var body: some View {
        HStack(spacing:0){
            //Image
            ZStack{
                if resultImage != nil {
                    Image(uiImage: resultImage!)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 42, height:42)
                        .cornerRadius(21)
                    
                    
                } else {
                    Image("chef")
                        .resizable()
                        .padding(8)
                        .foregroundColor(.init(white: 0.6))
                        .overlay(Circle().stroke(lineWidth: 1).foregroundColor(.init(white: 0.6)))
                        .padding(5)
                        .frame(width: 42, height:42)
                }
            }
            .padding(4)
            .padding(.trailing, 5)
            
            VStack(alignment: .leading, spacing: 0){
                HStack(spacing: 3){
                    Text(U.name)
                    .font(.headline)
                    
                    if self.U.verified == true {
                        Image("verified_128")
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        .padding(0)
                    }
                }
                Text("@\(U.username)")
                    .font(.subheadline)
                    .foregroundColor(.init(white: 0.6))
            }
            
        }
            
        .frame(height: 50)
        .onAppear(){
            
            DispatchQueue.main.async{
                let imageString = "user/\(self.U.id.uuidString)/profilepicture"
            loadImage_cache_FireStore(imageString: imageString, resized: .s64, minimumRecency: .Hour6, completion: {
                    imageData in
                    if let imageData = imageData {
                        
                            self.resultImage = UIImage(data: imageData)!
                        
                        
                    } else {
                                    println("couldn't grab image", 2)
                    }
                })
            }
            
        }
    }
    
}

struct SearchResult_Recipe: View {
    var RP:RecipePost
    @State var resultImage:UIImage? = nil
    var body: some View {
        HStack(spacing:0){
            //Image
            ZStack{
                if resultImage != nil {
                    Image(uiImage: resultImage!)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 42, height:42)
                        .cornerRadius(5)
                    
                    
                } else {
                    Image("14")
                        .resizable()
                        .padding(8)
                        .foregroundColor(.init(white: 0.6))
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 1).foregroundColor(.init(white: 0.6)))
                        .padding(5)
                        .frame(width: 42, height:42)
                }
            }
            .padding(3)
            .frame(width: 50, height:50)
            
            VStack(alignment: .leading){
                Text(RP.title)
                    .font(.headline)
                Text("@\(RP.postingUser.username)")
                    .font(.subheadline)
                    .foregroundColor(.init(white: 0.6))
            }
            Spacer()
            
            HStack(spacing:5){
                
                Text("\(RP.likes.count)")
                Image(systemName: "heart.fill")
                
            }
            .font(.system(size: 12, weight: .semibold))
            .padding(0)
//            .background(Color.init(white: 0.90))
//            .cornerRadius(5)
            .foregroundColor(lightPink).opacity(0.7)
            
            Text("RECIPE")
                .font(.system(size: 10, weight: .semibold))
                .padding(5)
                .background(Color.init(white: 0.90))
                .cornerRadius(5)
                .foregroundColor(Color.init(white: 0.3))
                .padding(10)
            
            
        }
        .frame(height: 50)
        .onAppear(){
            DispatchQueue.main.async {
                let imageString = "recipe/\(self.RP.id.uuidString)/img0"
                loadImage_cache_FireStore(imageString: imageString, resized: .s64, minimumRecency: .Day10, completion: {
                    imageData in
                    if let imageData = imageData {
                        self.resultImage = UIImage(data: imageData)!
                    } else {
                        //            p/("couldn't grab image")
                    }
                })
            }
            
        }
    }
}
struct SearchResult_None: View {
    
    var body: some View {
        HStack(spacing:0){
            Spacer()
            VStack(){
                Text("Aww man...")
                    .font(.headline)
                .foregroundColor(.init(white: 0.6))
                Text("No results found")
                    .font(.subheadline)
                    .foregroundColor(.init(white: 0.75))
            }
            Spacer()
            
        }
        .frame(height: 50)
        
    }
}
