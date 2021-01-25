    //
    //  NewPost_IngredientsView.swift
    //  recipeat
    //
    //  Created by Christopher Guirguis on 10/13/20.
    //  Copyright © 2020 Christopher Guirguis. All rights reserved.
    //

    import SwiftUI

    struct NewPost_IngredientsView: View {
        @EnvironmentObject var recipeObject:RecipeObject
        
//        @EnvironmentObject var env: GlobalEnvironment
//        @ObservedObject var newRecipePost:RecipePost
        //This variable is the exact same aas the ingredients property of newRecipePost but for some reason it needs to be its own variable for the view builder to respond to its changes
//        @State var postIngredients:[Ingredient]
        
        @State var editingList = false
        
        @State var ingredientBanner_show = false
        
        @State var ingredientBanner_editing = false
        @State var ingredientBanner_editingIndex:Int? = nil
        //These two variables are made here but used in the ingredient banner in a bindable format. the purpose is so that we can modify them here when choosing to edit a
        @State var ingredientName = ""
        @State var ingredientAmount = ""
        @State var ingredientUnit_index:Int = 2
        
        @State var reg_bannerData:BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Success)
        @State var reg_bannerShown:Bool = false
        @State var next:Bool = false
        @Binding var isEditing:Bool
        @Binding var shown:Bool
        var body: some View {
            ZStack{
                NavigationLink(destination: NewPost_StepsView(isEditing:$isEditing, shown: $shown), isActive: $next){
                    EmptyView()
                }
            VStack{
                HStack{
                    Spacer()
                    
                    if !editingList {
//                        Text("\(postIngredients.count)")
                        Button(action: {
                            self.ingredientBanner_editingIndex = nil
                            self.ingredientName = ""
                            self.ingredientAmount = ""
                            self.ingredientUnit_index = 2
                            
                            
                            ingredientBanner_editing = false
                            ingredientBanner_show = true
                        }){
                            Image(systemName: "plus.circle")
                                .font(.system(size: 20))
                        }
                    }
                    if self.recipeObject.recipe.ingredients.count > 0 {
                        Button(action: {
                            print(self.recipeObject.recipe.ingredients)
                            print("begin editing list")
                            withAnimation{
                                editingList.toggle()
                            }
                        }){
                            Text(editingList ? "Done" : "Edit")
    //                            Image(systemName: "pencil.and.ellipsis.rectangle")
                                .font(.system(size: 20))
                        }
                    }
                }
                .padding(.horizontal)
                
                    
                    if self.recipeObject.recipe.ingredients.count > 0 {
                        ScrollView{
                            List{
                        ForEach(self.recipeObject.recipe.ingredients, id: \.id){thisIngredient in
                            HStack{
                                Text("\(self.recipeObject.recipe.ingredients.getIndexOf(thisIngredient) + 1)) \((thisIngredient.amount == -1 ? "" : thisIngredient.amount.stringWithoutZeroFraction)) \(thisIngredient.amountUnit.rawValue) \(thisIngredient.name)")
                                .padding(EdgeInsets.init(top: 3, leading: 6, bottom: 3, trailing: 6))
                                .background(Color.init(red: 0.9, green: 0.9, blue: 0.9))
                                .cornerRadius(5)
                                .lineLimit(nil)
                                    .onTapGesture(count: 2, perform: {
                                        withAnimation{
                                            self.editingList.toggle()
                                        }
                                        
                                        
                                        
                                    })
                                .onTapGesture(count: 1, perform: {
                                    withAnimation{
                                        
                                        self.ingredientBanner_editingIndex = self.recipeObject.recipe.ingredients.getIndexOf(thisIngredient)
                                        self.ingredientName = thisIngredient.name
                                        self.ingredientAmount = (thisIngredient.amount == -1 ? "" : thisIngredient.amount.stringWithoutZeroFraction)
                                        self.ingredientUnit_index = IngredientUnit.allCases.firstIndex(of: thisIngredient.amountUnit) ?? 0
                                        
                                        
                                        self.ingredientBanner_editing = true
                                        self.ingredientBanner_show = true
                                    }
                                    
                                    
                                    
                                })
                                Spacer()

                                
                            }
                        }.onMove(perform: move)
                            .onDelete(perform: delete)
                                if !editingList {
            //                        Text("\(postIngredients.count)")
                                    Button(action: {
                                        self.ingredientBanner_editingIndex = nil
                                        self.ingredientName = ""
                                        self.ingredientAmount = ""
                                        self.ingredientUnit_index = 2
                                        
                                        
                                        ingredientBanner_editing = false
                                        ingredientBanner_show = true
                                    }){
                                        HStack{
                                            Image(systemName: "plus.circle")
                                            Text("Add more")
                                        }
                                            
                                            .foregroundColor(Color.init(white: 0.9))
                                    }
                                }
                            
                        
                    }.frame(minHeight: 300, maxHeight: .infinity)
                        .environment(\.editMode, editingList ? .constant(.active) : .constant(.inactive))
                            
                        }
                    } else {
                        HStack(spacing: 0){
                            Text("Press ")
                            Image(systemName: "plus.circle")
                            Text(" to add an ingredient")
                        }
                        .padding(10)
//                        .background(Color.init(white: 0.9))
                        .foregroundColor(Color.init(white: 0.65))
//                        .cornerRadius(10)
                        Spacer()
                    }
                
                
            }
            .padding(.top)
            .navigationBarTitle("Add Ingredients", displayMode: .inline)
            .navigationBarItems(
                trailing:
                        ZStack{
                                Button(action: {
                                    if self.recipeObject.recipe.ingredients.count > 0 {
                                        ingredientBanner_show = false
                                        next = true
                                    } else {
                                        reg_bannerData = BannerModifier.BannerData(title: "Welp!", detail: "Make sure to add at least one ingredient to move forward.", type: .Error)
                                        withAnimation{
                                            reg_bannerShown = true
                                        }
                                    }
                                }){
                                    Text("Next")
                                        .foregroundColor(self.recipeObject.recipe.ingredients.count > 0 ? Color.blue : Color.gray)
                                }
                                    
                            
                        }
                            
                    )
            .IngredientBanner(editing: $ingredientBanner_editing, editingIndex: $ingredientBanner_editingIndex, show: $ingredientBanner_show, recipePost: self.$recipeObject.recipe, ingredientName: $ingredientName, ingredientAmount: $ingredientAmount, ingredientUnit_index:$ingredientUnit_index)
            .banner(data: $reg_bannerData, show: $reg_bannerShown)
        }
        }
        
        func delete(at offsets: IndexSet) {
            print(offsets)
            self.recipeObject.recipe.ingredients.remove(atOffsets: offsets)
            if self.recipeObject.recipe.ingredients.count == 0 { editingList = false}
        }
        func move(fromOffsets source: IndexSet, toOffsets destination: Int) {
            self.recipeObject.recipe.ingredients.move(fromOffsets: source, toOffset: destination)
                withAnimation {
                    editingList = false
                }
        }
        
        
        
        
    }

    //struct NewPost_IngredientsView_Previews: PreviewProvider {
    //    static var previews: some View {
    //        NewPost_IngredientsView()
    //    }

