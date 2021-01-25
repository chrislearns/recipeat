//
//  AddNewComponent_View.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/1/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import SPAlert

struct AddNewComponent_View: View {
    var newItem_type:new_StepOrIngredient
    @State var halfModal_textField1_val = ""
    @State var halfModal_textField2_val = ""
    @State var ingredientUnit_index = 2
    @Binding var bindable_RP:RecipePost
    @State var hideFunc:(Any) -> Void
    
    @Binding var editingComponent:Int?
    @Binding var initialEditingVals_haveBeenSet:Bool
    
    
    var body: some View {
        ZStack{
            GeometryReader{geo  -> Text? in
                DispatchQueue.main.async {
                    if !self.initialEditingVals_haveBeenSet && self.editingComponent != nil{
                        if self.newItem_type == .Step {
                            let thisStep = self.bindable_RP.steps[self.editingComponent!]
                            self.halfModal_textField1_val = ""
                            self.halfModal_textField2_val = thisStep.subtitle
                        } else {
                            let thisIngredient = self.bindable_RP.ingredients[self.editingComponent!]
                            self.halfModal_textField1_val = (thisIngredient.amount == -1 ? "" : thisIngredient.amount.stringWithoutZeroFraction)
                            self.halfModal_textField2_val = thisIngredient.name
                            //                                IngredientUnit.init(rawValue: thisIngredient.amountUnit.rawValue)
                            self.ingredientUnit_index = IngredientUnit.allCases.firstIndex(of: thisIngredient.amountUnit) ?? 0
                        }
                        self.initialEditingVals_haveBeenSet = true
                    } else if !self.initialEditingVals_haveBeenSet && self.editingComponent == nil {
                        self.halfModal_textField1_val = ""
                        self.halfModal_textField2_val = ""
                        
                        self.ingredientUnit_index = 0
                        self.initialEditingVals_haveBeenSet = true
                    }
                }
                
                return nil
            }.frame(width:0, height:0)
            VStack{
//                Spacer().frame(height:15)
                HStack{
                        VStack(alignment: .leading, spacing:0){
                    Text(newItem_type == new_StepOrIngredient.Ingredient ? "Ingedient" : "Step")
                        .multilineTextAlignment(.leading)
                    .lineLimit(5)
                        .font(.system(size: 40, weight: .heavy))
                            Text("Use the textfield\(newItem_type == new_StepOrIngredient.Ingredient ? "s and picker" : "") provided below to \(self.editingComponent == nil ? "add a new" : "edit the selected") \(newItem_type == new_StepOrIngredient.Ingredient ? "ingredient" : "step").")
                        .multilineTextAlignment(.leading)
                        .lineLimit(8)
                        .font(.system(size: 15))
                        .foregroundColor(Color.init(white: 0.5))
                }
                        Spacer()
                    }
//                Text(newItem_type == new_StepOrIngredient.Ingredient ? "ADD A NEW INGREDIENT" : "ADD A NEW STEP").font(.headline)
                VStack{
                    HStack{
                        if newItem_type == new_StepOrIngredient.Ingredient {
                            TextField("#", text: $halfModal_textField1_val)
                                .frame(width:40)
                                .padding(10)
                                .background(
                                    Rectangle()
                                        .cornerRadius(10)
                                        .foregroundColor(Color.init(red: 0.95, green: 0.95, blue: 0.95))
                                    
                            )
                                .padding(20)
                                .keyboardType(.decimalPad)
                        }
                        
                        
                        if newItem_type == new_StepOrIngredient.Ingredient {
                            TextField("Enter new ingredient", text: $halfModal_textField2_val)
                                .padding(10)
                                .modifier(RoundedOutline())
                                .padding(10)
                        } else {
                            REP_TextView(text: $halfModal_textField2_val, keyboardType: .default)
                                            .autocapitalization(.sentences)
                                            .padding(5).background(Color.clear)
                                            .font(.system(size: 15))
                                            .frame(height:90).frame(maxWidth: .infinity)
                                            .modifier(RoundedOutline())
                            .padding(10)
                        }
                        
                    }.zIndex(3)
                    if self.newItem_type == .Ingredient {
                        Picker(selection: $ingredientUnit_index, label: Text("Unit")){
                            ForEach(0..<IngredientUnit.allCases.count){
                                Text($0 == 0 ? "No Units" : IngredientUnit.allCases[$0].rawValue).tag($0)
                            }
                        }
                        .labelsHidden()
                        .frame(height:80)
                        .clipped()
                        .padding()
                        .zIndex(2)
                        
                    }
                }.modifier(RoundedOutline(color: darkGreen))
                
                Button(action: {
                    if let thisComponent = self.editingComponent {
                        self.bindable_RP = editItem(
                            halfModal_textField1_val: self.halfModal_textField1_val,
                            halfModal_textField2_val: self.halfModal_textField2_val,
                            modifyingItem_index: thisComponent,
                            modifyingItem_type: self.newItem_type,
                            postToModify: self.bindable_RP,
                            ingredientUnit_index: self.ingredientUnit_index,
                            completion: {_ in
                                print("")
                                self.hideFunc(true)
                        }
                        )
                    } else {
                        self.bindable_RP = add_newItem(
                            halfModal_textField1_val: self.halfModal_textField1_val,
                            halfModal_textField2_val: self.halfModal_textField2_val,
                            newItem_type: self.newItem_type,
                            postToModify: self.bindable_RP,
                            ingredientUnit_index: self.ingredientUnit_index,
                            completion: {_ in
                                print("")
                                self.hideFunc(true)
                        }
                        )
                    }
                    self.halfModal_textField1_val = ""
                    self.halfModal_textField2_val = ""
                }){
                    Text(editingComponent == nil ? "+ ADD": "EDIT")
                }.buttonStyle(CapsuleStyle(bgColor: Color.white, fgColor: darkGreen))
                
                
                
                
                
                
                Spacer()
                
            }.padding(.vertical, 20).padding(.horizontal, 15)
        }
    }
    
    
}

func add_newItem(halfModal_textField1_val:String, halfModal_textField2_val:String, newItem_type: new_StepOrIngredient, postToModify:RecipePost, ingredientUnit_index:Int, completion: @escaping (Any) -> Void) -> RecipePost{
    let modifiable_RP = postToModify
    print("adding an item - \(newItem_type)")
    print("adding to - \(postToModify.fireBaseFormat)")
    if halfModal_textField2_val == "" || halfModal_textField2_val.count > 200 {
        let alertView = SPAlertView(title: "Hmmmm...", message: "Make sure no textfields are left blank and length of your entry is not longer than 200 characters. If you're trying to delete the ingredient, you can hold down on it and either reorder or delete it.", preset: SPAlertPreset.error)
        alertView.duration = 3
        alertView.present()
    } else {
        if newItem_type == .Step {
            modifiable_RP.steps.append(Step(subtitle: halfModal_textField2_val))
            completion(true)
        } else if newItem_type == .Ingredient{
            
            if let amount = possible_stringToDouble(halfModal_textField1_val) {
                if halfModal_textField1_val.count <= 200 {
                let thisIngredientUnit = IngredientUnit.allCases[ingredientUnit_index]
                
                modifiable_RP.ingredients.append(Ingredient(name: halfModal_textField2_val,
                                                            amount: amount,
                                                            amountUnit: thisIngredientUnit
                ))
                completion(true)
                } else {
                    let alertView = SPAlertView(title: "Hmmmm...", message: "Make sure no textfields are left blank and length of your entry is not longer than 200 characters. If you're trying to delete the ingredient, you can hold down on it and either reorder or delete it.", preset: SPAlertPreset.error)
                    alertView.duration = 3
                    alertView.present()
                }
            } else {
                let alertView = SPAlertView(title: "Check the amount", message: "Please enter a number (i.e. \"1\" or \"3.4\").", preset: SPAlertPreset.error)
                alertView.duration = 3
                alertView.present()
            }
            
        }
    }
    
    return modifiable_RP
}

func editItem(halfModal_textField1_val:String, halfModal_textField2_val:String, modifyingItem_index: Int, modifyingItem_type: new_StepOrIngredient, postToModify:RecipePost, ingredientUnit_index:Int, completion: @escaping (Any) -> Void) -> RecipePost{
    let modifiable_RP = postToModify
    print("editing an item - \(modifyingItem_type)")
    print("editing to - \(postToModify.fireBaseFormat)")
    
    if halfModal_textField2_val == "" || halfModal_textField2_val.count > 200 {
        let alertView = SPAlertView(title: "Hmmmm...", message: "Make sure no textfields are left blank and length of your entry is not longer than 200 characters. If you're trying to delete the ingredient, you can hold down on it and either reorder or delete it.", preset: SPAlertPreset.error)
        alertView.duration = 3
        alertView.present()
    } else {
        if modifyingItem_type == .Step {
            
            modifiable_RP.steps[modifyingItem_index] = Step(subtitle: halfModal_textField2_val)
            completion(true)
        } else if modifyingItem_type == .Ingredient{
            
            
            if let amount = possible_stringToDouble(halfModal_textField1_val) {
                
                if halfModal_textField1_val.count <= 200 {
                let thisIngredientUnit = IngredientUnit.allCases[ingredientUnit_index]
                
                
                modifiable_RP.ingredients[modifyingItem_index] = Ingredient(name: halfModal_textField2_val,
                                                                            amount: amount,
                                                                            amountUnit: thisIngredientUnit
                )
                completion(true)
                } else {
                    let alertView = SPAlertView(title: "Hmmmm...", message: "Make sure no textfields are left blank and length of your entry is not longer than 200 characters. If you're trying to delete the ingredient, you can hold down on it and either reorder or delete it.", preset: SPAlertPreset.error)
                    alertView.duration = 3
                    alertView.present()
                }
            } else {
                let alertView = SPAlertView(title: "Check the amount", message: "Please enter a number (i.e. \"1\" or \"3.4\").", preset: SPAlertPreset.error)
                alertView.duration = 3
                alertView.present()
            }
            
        }
    }
    return modifiable_RP
}
