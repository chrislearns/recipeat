//
//  NewPost_TitleDescriptionSelection.swift
//  recipeat
//
//  Created by Christopher Guirguis on 10/13/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct NewPost_TitleDescriptionSelectionView: View {
//    @EnvironmentObject var env: GlobalEnvironment
    @EnvironmentObject var recipeObject:RecipeObject
    
//    @ObservedObject var newRecipePost:RecipePost
    @State var next = false
    @Binding var isEditing:Bool
    @Binding var shown:Bool
    
    var body: some View {
        ZStack
        {
            NavigationLink(destination: NewPost_TimeServingSelectionView(isEditing: $isEditing, shown:$shown), isActive: $next){
                EmptyView()
            }
            VStack(alignment: .leading){
                
                Text("Title")
                    .font(.system(size: 14, weight: .semibold))
                TextField("What do you call this recipe?", text: self.$recipeObject.recipe.title)
                        .padding(5)
                        .background(Color.clear)
                        .frame(height:35)
                        .modifier(RoundedOutline())
                Spacer().frame(height: 10)
                Text("Description")
                    .font(.system(size: 14, weight: .semibold))
                TextEditor(text: self.$recipeObject.recipe.subtitle)
                    .padding(5)
                    .background(Color.clear)
                        .frame(height:80)
                        .modifier(RoundedOutline())
                Spacer()
                        
                    
                
                
                
                

                
                
                
                
        }
            .padding()
        .zIndex(15)
        .navigationTitle("Title and Description")
        .navigationBarItems(
            trailing:
                    ZStack{
                            Button(action: {
                                    next = true
                            }){
                                Text("Next")
                            }
                                
                        
                    }
                        
                )
        }
    }
    
}



//struct NewPost_TitleDescriptionSelectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewPost_TitleDescriptionSelectionView()
//    }
//}
