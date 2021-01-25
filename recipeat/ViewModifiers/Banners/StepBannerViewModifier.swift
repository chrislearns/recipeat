//
//  StepBannerViewModifier.swift
//  recipeat
//
//  Created by Christopher Guirguis on 10/19/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct StepBannerViewModifier: ViewModifier {
    // Members for the Banner
    @Binding var show:Bool
    @State var duration:Double = 4
    
    @Binding var editing:Bool
    @Binding var editingIndex:Int?
    
    @Binding var newRecipePost:RecipePost
    
    //Members for the step addition/editing
    @Binding var stepName:String
    
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
                            Text("Use the textfield provided below to \(self.editing ? "edit the selected" : "add a new") step")
                                .multilineTextAlignment(.leading)
                                .lineLimit(8)
                                .font(.system(size: 15))
                                .foregroundColor(Color.init(white: 0.5))
                                
                                TextField("Step description", text: $stepName)
//                                    .frame(width: 90)
                                    .padding(5)
                                    .background(Color.white.opacity(0.95))
                                    .cornerRadius(5)
                        }
                        .padding(EdgeInsets.init(top: 12, leading: 12, bottom: 12, trailing: 12))
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
                                        self.newRecipePost = step_edit(stepSubtitle: stepName, postToModify: self.newRecipePost, completion: {rp in
                                                                       
                                                                       if let rp = rp{
                                                                           newRecipePost = rp
                                                                           print("recipePost updated")
                                                                       }
                                                                       print("step Edited")
                                                               })
                                        
                                    } else {
                                        self.newRecipePost = step_add(
                                            stepSubtitle: stepName,
                                            postToModify: self.newRecipePost,
                                            completion: {rp in
                                                
                                                if let rp = rp{
                                                    newRecipePost = rp
                                                    print("recipePost updated")
                                                }
                                                print("step Added")
//                                                self.hideFunc(true)
                                        }
                                        )

                                        print("new step added")
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
                        Text("\(self.newRecipePost.steps.count)")
                            .foregroundColor(Color.white)
                            .fontWeight(.bold)
                            + Text(" step\(self.newRecipePost.steps.count == 1 ? "" : "s") added so far")
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
    
    func step_add(stepSubtitle:String, postToModify:RecipePost, completion: @escaping (RecipePost?) -> Void) -> RecipePost{
        let modifiable_RP = postToModify
        
        print("adding to - \(postToModify.fireBaseFormat)")
        if stepSubtitle == "" || stepSubtitle.count > 1000 {
            bannerData = BannerData(title: "Hmmmm....", detail: "Make sure no textfields are left blank and length of your entry is not longer than 1000 characters.", type: .Error)
            withAnimation{
                showBanner = true
            }
        } else {
            
            modifiable_RP.steps.append(Step(subtitle: stepSubtitle))
            print(modifiable_RP.steps)
            
            completion(modifiable_RP)
            self.stepName = ""
            
            bannerData = BannerData(title: "Added", detail: "Keep adding more steps or click next to keep creating your recipe.", type: .Success)
            withAnimation{
                showBanner = true
            }
            
        }
        
        return modifiable_RP
    }
    
    func step_edit(stepSubtitle:String, postToModify:RecipePost, completion: @escaping (RecipePost?) -> Void) -> RecipePost{
        let modifiable_RP = postToModify
        print("editing to - \(postToModify.fireBaseFormat)")
        if stepSubtitle == "" || stepSubtitle.count > 1000 {
            bannerData = BannerData(title: "Hmmmm....", detail: "Make sure no textfields are left blank and length of your entry is not longer than 1000 characters.", type: .Error)
            withAnimation{
                showBanner = true
            }
        } else {
                    if let i = editingIndex {
                        
                        
                        
                    modifiable_RP.steps[i] = Step(subtitle: stepSubtitle)
                        
                        completion(modifiable_RP)
                        show = false
                        
                        
                        
                    } else {
                        bannerData = BannerData(title: "Hmmm...", detail: "Something went wrong trying to edit this step", type: .Error)
                        withAnimation{
                            showBanner = true
                        }
                    }
                    
                
                
            
        }
        return modifiable_RP
    }
}

extension View {
    func StepBanner(editing: Binding<Bool>, editingIndex:Binding<Int?>, show: Binding<Bool>, recipePost:Binding<RecipePost>, stepName: Binding<String>) -> some View {
        self.modifier(
            StepBannerViewModifier(show: show, editing: editing, editingIndex: editingIndex, newRecipePost: recipePost, stepName: stepName)

        )
    }
}
