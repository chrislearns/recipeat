//
//  NewPost_StepsView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 10/19/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct NewPost_StepsView: View {
    @EnvironmentObject var recipeObject:RecipeObject
    //    @EnvironmentObject var env: GlobalEnvironment
    
    @State var editingList = false
    
    @State var stepBanner_show = false
    
    @State var stepBanner_editing = false
    @State var stepBanner_editingIndex:Int? = nil
    //These variables are made here but used in the steps banner in a bindable format. the purpose is so that we can modify them here when choosing to edit a
    @State var stepName = ""
    
    @State var reg_bannerData:BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Success)
    @State var reg_bannerShown:Bool = false
    @State var next:Bool = false
    @Binding var isEditing:Bool
    @Binding var shown:Bool
    var body: some View {
        ZStack{
            NavigationLink(destination: NewPost_TagView(isEditing:$isEditing, shown: $shown), isActive: $next){
                EmptyView()
            }
        VStack{
            HStack{
                Spacer()
                
                if !editingList {
                    Button(action: {
                        self.stepBanner_editingIndex = nil
                        self.stepName = ""
                        
                        
                        
                        stepBanner_editing = false
                        stepBanner_show = true
                    }){
                        Image(systemName: "plus.circle")
                            .font(.system(size: 20))
                    }
                }
                if self.recipeObject.recipe.steps.count > 0 {
                    Button(action: {
                        print(self.recipeObject.recipe.steps)
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
            
                
                if self.recipeObject.recipe.steps.count > 0 {
                    ScrollView{
                        List{
                    ForEach(self.recipeObject.recipe.steps, id: \.id){thisStep in
                        HStack{
                            Text("\(self.recipeObject.recipe.steps.getIndexOf(thisStep) + 1)) \(thisStep.subtitle)")
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
                                    
                                    self.stepBanner_editingIndex = self.recipeObject.recipe.steps.getIndexOf(thisStep)
                                    self.stepName = thisStep.subtitle
                                    
                                    
                                    
                                    self.stepBanner_editing = true
                                    self.stepBanner_show = true
                                }
                                
                                
                                
                            })
                            Spacer()

                            
                        }
                    }.onMove(perform: move)
                        .onDelete(perform: delete)
                            if !editingList {
        
                                Button(action: {
                                    
                                    self.stepName = ""
                                    
                                    
                                    
                                    stepBanner_editing = false
                                    stepBanner_show = true
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
                        Text(" to add a step")
                    }
                    .padding(10)
//                        .background(Color.init(white: 0.9))
                    .foregroundColor(Color.init(white: 0.65))
//                        .cornerRadius(10)
                    Spacer()
                }
            
            
        }
        .padding(.top)
        .navigationBarTitle("Add Steps", displayMode: .inline)
        .navigationBarItems(
            trailing:
                ZStack{
                        Button(action: {
                            if self.recipeObject.recipe.steps.count > 0 {
                                stepBanner_show = false
                                next = true
                            } else {
                                reg_bannerData = BannerModifier.BannerData(title: "Welp!", detail: "Make sure to add at least one step to move forward.", type: .Error)
                                withAnimation{
                                    reg_bannerShown = true
                                }
                            }
                        }){
                            Text("Next")
                                .foregroundColor(self.recipeObject.recipe.steps.count > 0 ? Color.blue : Color.gray)
                        }
                            
                    
                }
                        
                )
        .StepBanner(editing: $stepBanner_editing, editingIndex: $stepBanner_editingIndex, show: $stepBanner_show, recipePost: self.$recipeObject.recipe, stepName: $stepName)
//        .IngredientBanner(editing: $ingredientBanner_editing, editingIndex: $ingredientBanner_editingIndex, show: $ingredientBanner_show, recipePost: self.$env.newRecipePost, ingredientName: $ingredientName, ingredientAmount: $ingredientAmount, ingredientUnit_index:$ingredientUnit_index)
        .banner(data: $reg_bannerData, show: $reg_bannerShown)
    }
    }
    
    func delete(at offsets: IndexSet) {
        print(offsets)
        self.recipeObject.recipe.steps.remove(atOffsets: offsets)
        if self.recipeObject.recipe.steps.count == 0 { editingList = false}
    }
    func move(fromOffsets source: IndexSet, toOffsets destination: Int) {
        self.recipeObject.recipe.steps.move(fromOffsets: source, toOffset: destination)
            withAnimation {
                editingList = false
            }
    }
    
    
    
    

}
//
//struct NewPost_StepsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewPost_StepsView()
//    }
//}
