//
//  IngredientBannerViewModifier.swift
//  recipeat
//
//  Created by Christopher Guirguis on 10/13/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//
import SwiftUI


struct IngredientBannerModifier: ViewModifier {
    
    
    
    // Members for the Banner
    @Binding var show:Bool
    @State var duration:Double = 4
    
    @Binding var editing:Bool
    @Binding var editingIndex:Int?
    
    @Binding var newRecipePost:RecipePost
//    @Binding var postIngredients:[Ingredient]
    
    //Members for the ingredient addition/editing
    @Binding var ingredientName:String
    @Binding var ingredientAmount:String
    @Binding var ingredientUnit_index:Int
    
    //Members for the banner
    @State var showBanner:Bool = false
    @State var bannerData:BannerData = BannerData(title: "", detail: "", type: .Info)
    func body(content: Content) -> some View {
        ZStack {
            content
            if show {
                VisualEffectView(effect: UIBlurEffect(style: .regular))
                    .edgesIgnoringSafeArea(.vertical)
                    .animation(.easeInOut(duration: 0.5))
                    .transition(AnyTransition.opacity)
                VStack {
                    
                    VStack(spacing: 0){
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Use the textfields and picker provided below to \(self.editing ? "edit the selected" : "add a new") ingredient")
                                .multilineTextAlignment(.leading)
                                .lineLimit(8)
                                .font(.system(size: 15))
                                .foregroundColor(Color.init(white: 0.5))
                            HStack{
                                TextField("#", text: $ingredientAmount)
                                    .frame(width: 40)
                                    .padding(5)
                                    .background(Color.white.opacity(0.95))
                                    .cornerRadius(5)
                                    .keyboardType(.decimalPad)
                                
                                TextField("Ingredient Name", text: $ingredientName)
//                                    .frame(width: 90)
                                    .padding(5)
                                    .background(Color.white.opacity(0.95))
                                    .cornerRadius(5)
                            }
                            Picker(selection: $ingredientUnit_index, label: Text("Unit")){
                                ForEach(0..<IngredientUnit.allCases.count){
                                    Text($0 == 0 ? "No Units" : IngredientUnit.allCases[$0].rawValue).tag($0)
                                }
                            }
                            .labelsHidden()
                            .frame(height:100)
                            .clipped()
                            .padding(.vertical, 10)
                            .zIndex(2)
                        }
                        .padding(EdgeInsets.init(top: 12, leading: 12, bottom: 5, trailing: 12))
                            HStack{
                                Button(action: {
                                    withAnimation {
                                        self.show = false
                                    }
                                }){
                                    Spacer()
                                    Text("Back")
                                        .foregroundColor(Color.init(white: 0.5))
                                    Spacer()
                                }
                                .padding(EdgeInsets.init(top: 12, leading: 12, bottom: 12, trailing: 0))
                                .background(Color.black.opacity(0.1))
                                Button(action: {
                                    
                                    if editing {
                                        self.newRecipePost = ingredient_edit(
                                            ingredientAmount: self.ingredientAmount,
                                            ingredientName: self.ingredientName,
                                            postToModify: self.newRecipePost,
                                            ingredientUnit_index: self.ingredientUnit_index,
                                            completion: {rp in
                                                
                                                if let rp = rp{
                                                    newRecipePost = rp
                                                    print("recipePost updated")
                                                }
                                                print("Ingredient Edited")
//                                                self.hideFunc(true)
                                        }
                                        )
                                    } else {
                                        self.newRecipePost = ingredient_add(
                                            ingredientAmount: self.ingredientAmount,
                                            ingredientName: self.ingredientName,
                                            postToModify: self.newRecipePost,
                                            ingredientUnit_index: self.ingredientUnit_index,
                                            completion: {rp in
                                                
                                                if let rp = rp{
                                                    newRecipePost = rp
                                                    print("recipePost updated")
                                                }
                                                print("Ingredient Added")
//                                                self.hideFunc(true)
                                        }
                                        )
                                        print("new ingredient added")
                                    }
                                }){
                                    Spacer()
                                    Text(editing ? "Edit" : "Add")
                                        .foregroundColor(darkGreen)
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .padding(EdgeInsets.init(top: 12, leading: 0, bottom: 12, trailing: 12))
                            }
                            
                            
                            
                        }
                        
                    
                    
                        .frame(width: UniversalSquare.width-30)
                        .background(Color.init(white: 0.93).opacity(0.95))
                        .cornerRadius(8)
                        .shadow(radius: 4)
                    
                    Group{
                        Text("\(self.newRecipePost.ingredients.count)")
                            .foregroundColor(Color.white)
                            .fontWeight(.bold)
                            + Text(" ingredient added so far")
                            .foregroundColor(Color.init(white: 0.9))
                            .fontWeight(.regular)
                    }
                        
                        
                    
                    .padding()
                        .frame(width: UniversalSquare.width-30)
                        .background(verifiedDarkBlue)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                    
                    
                    if showBanner{
                        Spacer().frame(height: 10)
                        VStack(alignment: .leading){
                            Text(bannerData.title).font(.system(size: 17, weight: .semibold))
                            
                            Text(bannerData.detail).font(.system(size: 15, weight: .regular))
                        }
                            .foregroundColor(.white)
                        .padding(9)
                            .frame(width: UniversalSquare.width-30)
                        .background(bannerData.type.tintColor)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                        .onAppear(perform: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    self.showBanner = false
                                }
                            }
                        })
                    }
                    Spacer()
                }
                .padding()
                .animation(.easeInOut(duration: 0.5))
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))

                
            }
        }
    }

    
    func ingredient_add(ingredientAmount:String, ingredientName:String, postToModify:RecipePost, ingredientUnit_index:Int, completion: @escaping (RecipePost?) -> Void) -> RecipePost{
        let modifiable_RP = postToModify
        print("adding to - \(postToModify.fireBaseFormat)")
        if ingredientName == "" || ingredientName.count > 200 {
            bannerData = BannerData(title: "Hmmmm....", detail: "Make sure no textfields are left blank and length of your entry is not longer than 200 characters.", type: .Error)
            withAnimation{
                showBanner = true
            }
        } else {
                
                if let amount = possible_stringToDouble(ingredientAmount) {
                    
                    let thisIngredientUnit = IngredientUnit.allCases[ingredientUnit_index]
                    
                    
                    modifiable_RP.ingredients.append(Ingredient(name: ingredientName,
                                                                amount: amount,
                                                                amountUnit: thisIngredientUnit
                    ))
                        print(modifiable_RP.ingredients)
                        
                    completion(modifiable_RP)
                        self.ingredientAmount = ""
                        self.ingredientName = ""
                        bannerData = BannerData(title: "Added", detail: "Keep addding more ingredients or go back to move to the next step.", type: .Success)
                        withAnimation{
                            showBanner = true
                        }
                        
                    
                } else {
                    bannerData = BannerData(title: "Check the amount", detail: "Please enter a number (i.e. \"1\" or \"3.4\").", type: .Error)
                    withAnimation{
                        showBanner = true
                    }
                    print("amount is not a number")
                    
                }
                
            
        }
        
        return modifiable_RP
    }
    
    func ingredient_edit(ingredientAmount:String, ingredientName:String, postToModify:RecipePost, ingredientUnit_index:Int, completion: @escaping (RecipePost?) -> Void) -> RecipePost{
        let modifiable_RP = postToModify
        print("editing to - \(postToModify.fireBaseFormat)")
        if ingredientName == "" || ingredientName.count > 200 {
            bannerData = BannerData(title: "Hmmmm....", detail: "Make sure no textfields are left blank and length of your entry is not longer than 200 characters.", type: .Error)
            withAnimation{
                showBanner = true
            }
        } else {
        
                if let amount = possible_stringToDouble(ingredientAmount) {
                    
                    
                    let thisIngredientUnit = IngredientUnit.allCases[ingredientUnit_index]
                    
                    if let i = editingIndex {
                    modifiable_RP.ingredients[i] = Ingredient(name: ingredientName,
                                                                                amount: amount,
                                                                                amountUnit: thisIngredientUnit
                    )
                    completion(modifiable_RP)
                        show = false
                    } else {
                        bannerData = BannerData(title: "Hmmm...", detail: "Something went wrong trying to edit this ingredient", type: .Error)
                        withAnimation{
                            showBanner = true
                        }
                    }
                    
                } else {
                    bannerData = BannerData(title: "Check the amount", detail: "Please enter a number (i.e. \"1\" or \"3.4\").", type: .Error)
                    withAnimation{
                        showBanner = true
                    }
                    print("amount is not a number")
                    
                }
                
            
        }
        return modifiable_RP
    }
    
}

extension View {
    func IngredientBanner(editing: Binding<Bool>, editingIndex:Binding<Int?>, show: Binding<Bool>, recipePost:Binding<RecipePost>, ingredientName: Binding<String>, ingredientAmount: Binding<String>, ingredientUnit_index:Binding<Int>) -> some View {
        self.modifier(IngredientBannerModifier(show: show, editing: editing, editingIndex:editingIndex, newRecipePost: recipePost, ingredientName: ingredientName, ingredientAmount: ingredientAmount, ingredientUnit_index: ingredientUnit_index))
    }
}
