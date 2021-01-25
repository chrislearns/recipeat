//
//  NewPost_TimeServingSelection.swift
//  recipeat
//
//  Created by Christopher Guirguis on 10/12/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct NewPost_TimeServingSelectionView: View {
    //    @EnvironmentObject var env: GlobalEnvironment
        @EnvironmentObject var recipeObject:RecipeObject
    
    @State var servingsValid = false
    @State var next = false
    @Binding var isEditing:Bool
    @Binding var shown:Bool
    var body: some View {
        ZStack
        {
            NavigationLink(destination: NewPost_IngredientsView(isEditing:$isEditing, shown:$shown), isActive: $next){
                EmptyView()
            }
            VStack{
                TimeAndServingsView(estimatedServings: self.$recipeObject.recipe.estimatedServings, timePrep: self.$recipeObject.recipe.timePrep, timeCook: self.$recipeObject.recipe.timeCook, timeOther: self.$recipeObject.recipe.timeOther, standardTF: true, servingsValid: $servingsValid)
        }
            .navigationTitle("Servings & Time")
        .navigationBarItems(
            trailing:
                    ZStack{
                        if !servingsValid {
                            Text("Next")
                                .foregroundColor(Color.init(white: 0.6))
                        } else {
                            Button(action: {
                                if validate_estimatedServings(self.recipeObject.recipe.estimatedServings){
                                    next = true
                                } else {
                                    servingsValid = validate_estimatedServings(self.recipeObject.recipe.estimatedServings)
                                }
                                
                            }){
                                Text("Next")
                            }
                                
                        }
                    }
                        
                )
        }
    }
}

//struct NewPost_TimeServingSelectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewPost_TimeServingSelectionView()
//    }
//}
