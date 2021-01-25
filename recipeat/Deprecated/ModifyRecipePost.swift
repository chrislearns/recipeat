//
//  ModifyRecipePost.swift
//  recipeat
//
//  Created by Christopher Guirguis on 3/26/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import SPAlert

struct ModifyRecipePost: View {
    @EnvironmentObject var env: GlobalEnvironment
    
    
    @Binding var binding_recipePost:RecipePost
    @Binding var images:[Identifiable_UIImage]
    @Binding var isShown:Bool
    
    @State var showTime = false
    @State var editingIngredients = false
    @State var editingSteps = false
    @State var listType = new_StepOrIngredient.Ingredient
    
    var buttonHeight:CGFloat = 50
    
    var buttonColor = darkGreen
    var actionButton:ActionableButton?
    
    @State var showTagPicker = false
    
    @State var halfModal_shown = false
    @State var halfModal_height:CGFloat = 380
    @State var newItem_type:new_StepOrIngredient = .Step
    @State var editingComponent:Int? = nil
    @State var initialEditingVals_haveBeenSet = true
    
    @State var reachedBottom:Bool = false
    var body: some View {
        ZStack{
            ScrollView{
                HStack(spacing:0){
                    if images.count > 0 {
                        GalleryView(
                            actionButton: nil,
                            galleryHeight: UIScreen.main.bounds.width,
                            galleryWidth: UIScreen.main.bounds.width,
                            imageWidth: UIScreen.main.bounds.width,
                            imageHeight: UIScreen.main.bounds.width,
                            contents: self.images
                        )
                        
                        
                        
                    } else {
                        Text("Please go back and select at least 1 image.")
                            .frame(width: UIScreen.main.bounds.width, height:UIScreen.main.bounds.width)
                            .background(Color.init(white:0.95))
                    }
                }
                .zIndex(1)
                VStack(alignment: .leading, spacing:0){
                    Group{
                        VStack(spacing:0){
                            
                            HStack{
                                Text("TITLE")
                                Spacer()
                            }
                            .font(.system(size: 20, weight: .semibold))
                                
                                
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.bottom, 8)
                            TextField("Name your masterpiece", text: $binding_recipePost.title)
                                .autocapitalization(.words)
                                .padding(5).background(Color.clear)
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity)
                                .modifier(RoundedOutline())
                            Spacer().frame(height: 10)
                            HStack{
                                Text("DESCRIPTION")
                                Spacer()
                            }
                            .font(.system(size: 20, weight: .semibold))
                                
                                
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.bottom, 8)
                            TextEditor(text: $binding_recipePost.subtitle)
                                .keyboardType(.default)
                                .autocapitalization(.sentences)
//                            REP_TextView(text: $binding_recipePost.subtitle, keyboardType: .default)
//                                .autocapitalization(.sentences)
                                .padding(5).background(Color.clear)
                                .font(.system(size: 15))
                                .frame(height:90).frame(maxWidth: .infinity)
                                .modifier(RoundedOutline())
                            
                            
                            
                            
                                            
//                                            HStack{
//                                                Text("PERSONAL INFO")
//                                                Spacer()
//                                            }
//                        TextField("Name your masterpiece", text: $binding_recipePost.title).padding()
//                        Rectangle().frame(width: UniversalSquare.width - 50, height: 1).foregroundColor(Color.init(white: 0.95)).padding(.horizontal, 25)
//                        TextField("Give it a description", text: $binding_recipePost.subtitle).padding()
//                        Rectangle().frame(width: UniversalSquare.width - 50, height: 1).foregroundColor(Color.init(white: 0.95)).padding(.horizontal, 25)
                        
                    }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                    HStack{
                        Text("TAGS")
                        Button(action: {
                            self.showTagPicker = true
                            
                        }){
                            Image(systemName: "plus.circle")
                                .foregroundColor(binding_recipePost.tags.count < 1 ? lightPink : lightGreen)
                        }.sheet(isPresented: $showTagPicker){
                            TagSelectorView(closure: {
                                tagEntities in
                                print(tagEntities)
                                self.binding_recipePost.tags = tagEntities
                                self.showTagPicker = false
                            }, isShown: self.$showTagPicker, tagObjects:
                            FoodTagDictionary.map{mapItem in
                                TagObject(tagEntity: TagEntity(keywords: mapItem.value .keywords, dbVal: mapItem.value.dbVal, displayVal: mapItem.value.displayVal), selected: (
                                    //This ternary operator is checking to see if this item is in the user's list of already selected tags. this will determine whether we return true or false for "selected" when displaying the TagSelectorView and its item "tagObjects"
                                    self.binding_recipePost.tags.first(where: {item in
                                        item.dbVal == mapItem.value.dbVal}) != nil ? true : false
                                ))
                            }.sorted{ $0.tagEntity.displayVal < $1.tagEntity.displayVal }
                            )
                        }
                        if binding_recipePost.tags.count < 1 {
                            Text("Minimum of 1 Categorical Tag")
                                .foregroundColor(Color.init(white:0.85))
                            .font(.system(size: 12, weight: .medium))
                        } else {
                            ScrollView(.horizontal, showsIndicators: false){
                                HStack{
                                    ForEach(binding_recipePost.tags, id: \.id){thisTag in
                                        
                                        TagItemView(fontSize: StandardTagViewAttributes().fontSize, wordPadding: StandardTagViewAttributes().wordPadding,  text: .constant(thisTag.displayVal),
                                                    selected: .constant(true)
                                        )
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .frame(width: UniversalSquare.width)
                        .clipped()
                    .zIndex(5)
                    Rectangle().frame(width: UniversalSquare.width - 50, height: 1).foregroundColor(Color.init(white: 0.95)).padding(.horizontal, 25)
                    
                        Button(action: {self.showTime = true}){
                            HStack{
                        Text("TIME & SERVINGS")
                        Text("Tap here to modify")
                            .foregroundColor(Color.init(white:0.85))
                            .font(.system(size: 12, weight: .medium))
                        Spacer()
                        Image(systemName: "chevron.right")
                        
                            .font(.system(size: 20, weight: .light))
                            }.foregroundColor(possible_stringToDouble(binding_recipePost.estimatedServings) == nil ? lightPink :  darkGreen)
                        }.sheet(isPresented: self.$showTime){
                            VStack{
                                HStack{
                                    VStack(alignment: .leading, spacing:0){
                                Text("Time and Serving Estimates")
                                    .multilineTextAlignment(.leading)
                                .lineLimit(5)
                                    .font(.system(size: 40, weight: .heavy))
                                Text("Changes made here are saved automatically. Press \"CONTINUE\" or swipe down to continue modifying recipe")
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(8)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.init(white: 0.5))
                            }
                                    Spacer()
                                }
                            
                                Spacer().frame(height: 50)
//                                TimeAndServingsView(estimatedServings: self.$binding_recipePost.estimatedServings, timePrep: self.$binding_recipePost.timePrep, timeCook: self.$binding_recipePost.timeCook, timeOther: self.$binding_recipePost.timeOther, standardTF:true, midSpacer: 20)
                            Spacer().frame(minWidth: 0, maxWidth: .infinity)
                                Button(action: {
                                    self.showTime = false
                                }) {
                                    Text("CONTINUE")
                                }.zIndex(20)
                                    .buttonStyle(CapsuleStyle(bgColor: darkGreen, fgColor: Color.white, height: 50))
                                    .padding(.bottom, 20)
                            }
                                
                            .padding(.vertical, 20).padding(.horizontal, 15)
                        }
                    
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .frame(width: UniversalSquare.width)
                        .clipped()
                
                    }
                    Rectangle().frame(width: UniversalSquare.width - 50, height: 1).foregroundColor(Color.init(white: 0.95)).padding(.horizontal, 25)
                    HStack{
                        Text("INGREDIENTS")
                        Button(action: {
                            self.update_halfModal(itemType: .Ingredient, height: 510)
                            self.halfModal_shown = true
                        }){
                            Image(systemName: "plus.circle")
                                .foregroundColor(binding_recipePost.ingredients.count < 1 ? lightPink : lightGreen)
                        }
                        Text("Hold down to change order")
                            .foregroundColor(Color.init(white:0.85))
                        .font(.system(size: 12, weight: .medium))
                        
                    }
                    .font(.system(size: 20, weight: .semibold))
                .zIndex(10)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    List{
                        ForEach(binding_recipePost.ingredients, id: \.id){thisIngredient in
                            HStack{
                                Text("\(self.binding_recipePost.ingredients.getIndexOf(thisIngredient) + 1)) \((thisIngredient.amount == -1 ? "" : thisIngredient.amount.stringWithoutZeroFraction)) \(thisIngredient.amountUnit.rawValue) \(thisIngredient.name)")
                                .padding(EdgeInsets.init(top: 3, leading: 6, bottom: 3, trailing: 6))
                                .background(Color.init(red: 0.9, green: 0.9, blue: 0.9))
                                .cornerRadius(5)
                                .lineLimit(nil)
                                if !self.editingIngredients {
                                    Button(action: {
                                        print("tapped edit")
                                        self.update_halfModal(itemType: .Ingredient, height: 510)
                                        self.halfModal_shown = true
                                        self.editingComponent = self.binding_recipePost.ingredients.getIndexOf(thisIngredient)
                                        self.initialEditingVals_haveBeenSet = false
                                    }){Text("SAVE").foregroundColor(lightGreen)}
                                }
                                Spacer()
                            }
                        }.onMove(perform: move)
                            .onDelete(perform: delete)
                            .onTapGesture(count: 2, perform: {
                                withAnimation{
                                    self.listType = .Ingredient
                                    self.editingIngredients.toggle()
                                }
                                
                                
                                
                            })
                            .onLongPressGesture {
                                withAnimation{
                                    self.listType = .Ingredient
                                    self.editingIngredients.toggle()
                                }
                        }
                        
                    }.frame(minHeight: 300, maxHeight: .infinity)
                        .environment(\.editMode, editingIngredients ? .constant(.active) : .constant(.inactive))
                    HStack{
                        Text("STEPS")
                            .overlay(
                                        GeometryReader{geo -> Text? in
                                            let offsetY = geo.frame(in: .global).minY
                                            DispatchQueue.main.async{
                                                //The UniversalSquare.height is the bottom of the screen, the offsets amd button height means the header must be above the text, and the +20 gives a buffer of not necessarily having to get THAT high. essentially, most likely the person scrolled and the momentum of the scroll should carry them the rest of the way, or at least they now know theres more on the bottom of the screen
                                                let threshold = UniversalSquare.height + 20 - (UniversalSafeOffsets?.bottom ?? 0 + self.buttonHeight)
                                                if offsetY < (threshold) {
                                                    self.reachedBottom = true
                                                }
                                            }
                                            return nil
//                                            return Text("\(offsetY)")
                                        }
                            
                            )
                        Button(action: {
                            self.update_halfModal(itemType: .Step, height: 380)
                            self.halfModal_shown = true
                            
                            self.editingComponent = nil
                            self.initialEditingVals_haveBeenSet = false
                        }){
                            Image(systemName: "plus.circle")
                                .foregroundColor(binding_recipePost.steps.count < 1 ? lightPink : lightGreen)
                        }
                        Text("Hold down to change order")
                            .foregroundColor(Color.init(white:0.85))
                        .font(.system(size: 12, weight: .medium))
                    }
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.vertical, 5)
                        
                    .padding(.horizontal, 10)
                    List{
                        ForEach(binding_recipePost.steps, id: \.id){thisStep in
                            HStack{
                                Text("\(self.binding_recipePost.steps.getIndexOf(thisStep) + 1). \(thisStep.subtitle)")
                                    .padding(EdgeInsets.init(top: 3, leading: 6, bottom: 3, trailing: 6))
                                    .background(Color.init(red: 0.9, green: 0.9, blue: 0.9))
                                    .cornerRadius(5)
                                    .lineLimit(nil)
                                if !self.editingSteps {
                                    Button(action: {
                                        print("tapped edit")
                                        self.update_halfModal(itemType: .Step, height: 380)
                                        self.halfModal_shown = true
                                        self.editingComponent = self.binding_recipePost.steps.getIndexOf(thisStep)
                                        self.initialEditingVals_haveBeenSet = false
                                    }){Text("SAVE").foregroundColor(lightGreen)}
                                }
                                Spacer()
                            }
                        }
                        .onMove(perform: move)
                        .onDelete(perform: delete)
                        .onTapGesture(count: 2, perform: {
                            withAnimation{
                                self.listType = .Step
                                self.editingSteps.toggle()
                            }
                        })
                            .onLongPressGesture {
                                withAnimation{
                                    self.listType = .Step
                                    self.editingSteps.toggle()
                                }
                        }
                        
                        
                    }.frame(minHeight: 300, maxHeight: .infinity)
                        .environment(\.editMode, editingSteps ? .constant(.active) : .constant(.inactive))
                    
                    Spacer()
                    
                    //This is serving as a placeholder for the floating button
                    Spacer().frame(height: buttonHeight).frame(maxWidth: 200)
                    
                }
                .background(Color.white)
                .zIndex(5)
                
            }
            .padding(.bottom, 20)
            VStack{
                Spacer()
                Button(action: {
                    if let actionButton = self.actionButton {
                        actionButton.action(true)
                    }
                }) {
                    Text(reachedBottom ? actionButton?.text ?? "Go": actionButton?.moreScrollText ?? "SCROLL" )
                }
                .buttonStyle(CapsuleStyle(bgColor: reachedBottom ? darkGreen : Color.white, fgColor: reachedBottom ? Color.white : darkPink, height: buttonHeight))
                .padding(.bottom, 20)
                .animation(.linear)
            }
            .zIndex(10)
            
            .sheet(isPresented: $halfModal_shown){//}, modalHeight:halfModal_height){
                AddNewComponent_View(newItem_type: self.newItem_type, bindable_RP: self.$binding_recipePost, hideFunc: {_ in
                    UIApplication.shared.endEditing()
                    self.halfModal_shown = false
                    self.update_halfModal(itemType: .Ingredient, height: 300)
                    if self.editingComponent != nil {
                        self.editingComponent = nil
                        self.initialEditingVals_haveBeenSet = true
                    }
                }, editingComponent: self.$editingComponent, initialEditingVals_haveBeenSet: self.$initialEditingVals_haveBeenSet)
                
            }
            .zIndex(20)
        }
    }
    
    
    func delete(at offsets: IndexSet) {
        print(offsets)
        
        if listType == .Step {
            binding_recipePost.steps.remove(atOffsets: offsets)
        } else {
            binding_recipePost.ingredients.remove(atOffsets: offsets)
        }
    }
    func move(fromOffsets source: IndexSet, toOffsets destination: Int) {
        
        if listType == .Step {
            binding_recipePost.steps.move(fromOffsets: source, toOffset: destination)
            withAnimation {
                editingSteps = false
            }
        } else {
            binding_recipePost.ingredients.move(fromOffsets: source, toOffset: destination)
            withAnimation {
                editingIngredients = false
            }
        }
        
    }
    
    
    func update_halfModal(itemType:new_StepOrIngredient, height:CGFloat){
        newItem_type = itemType
        halfModal_height = height
    }
    
}


//
//struct ModifyRecipePost_Previews: PreviewProvider {
//
//    static var previews: some View {
//
//        ModifyRecipePost(recipeTitle: .constant("abc"))
//    }
//}
