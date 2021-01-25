//
//  RecipeScrollView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/24/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct RecipeScrollView: View {
//    @EnvironmentObject var env: GlobalEnvironment
    @Binding var recipes:RecipeResults
    var closure_tapRecipe:(String)-> Void
    
    
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            LazyHStack(spacing:15){
                
                if recipes.results.count > 0 {
                    ForEach(recipes.results.filter({$0.isFeatureEligible}).chunked(by: 10)[0], id: \.id){ thisResult in
                            
                                    ExploreRecipeView(recipe: thisResult)
                                        .onTapGesture(count: 1, perform: {
                                            self.closure_tapRecipe(thisResult.id.uuidString)
                                            
                                        })
                            
                        
                    }
                } else {
                    ForEach(0..<3){ i -> AnyView in
                        return AnyView(
                            
                            VStack{
                                Rectangle().frame(width: 330, height: 220)
                                    .foregroundColor(Color.init(white: 0.1))
                                    .cornerRadius(10).clipped()
                                .opacity(0.5)
                                
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 15)
            
        }.overlay(
            HStack{
                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.15),Color.white.opacity(0)]), startPoint: .leading, endPoint: .trailing).frame(width: 20)
                Spacer()
                
                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0),Color.white.opacity(0.15)]), startPoint: .leading, endPoint: .trailing).frame(width: 20)
            }.frame(width: UniversalSquare.width)
        )
    }
}

//struct RecipeScrollView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecipeScrollView()
//    }
//}
