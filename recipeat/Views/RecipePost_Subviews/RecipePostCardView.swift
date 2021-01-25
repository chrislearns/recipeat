//
//  RecipePostCardView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/17/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct RecipeDetailsView: View {
    var thisRecipePost:RecipePost
    @Binding var animatedIntro:Bool
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            HStack(alignment: .top){
                Spacer()
                if thisRecipePost.timePrep > 0 {
                    VStack(alignment: .center){
                        Text("\(thisRecipePost.timePrep)")
                            .font(.system(size: 25, weight: .bold))
                        Text(
                            """
                        Prep Time
                        (minutes)
                        """)
                            .font(.system(size: 12)).multilineTextAlignment(.center)
                    }
                    Spacer()
                }
                if thisRecipePost.timeCook > 0 {
                    VStack(alignment: .center){
                        Text("\(thisRecipePost.timeCook)")
                            .font(.system(size: 25, weight: .bold))
                        Text(
                            """
                    Cook Time
                    (minutes)
                    """)
                            .font(.system(size: 12)).multilineTextAlignment(.center)
                    }
                    Spacer()
                }
                if thisRecipePost.timeOther > 0 {
                    VStack(alignment: .center){
                        Text("\(thisRecipePost.timeOther)")
                            .font(.system(size: 25, weight: .bold))
                        Text(
                            """
                    Other Time
                    (minutes)
                    """)
                            .font(.system(size: 12)).multilineTextAlignment(.center)
                    }
                    Spacer()
                }
//                if possible_stringToDouble(thisRecipePost.estimatedServings) != nil {
//                    if possible_stringToDouble(thisRecipePost.estimatedServings)! > 0 {
//                        VStack(alignment: .center){
//                            Text("\(thisRecipePost.estimatedServings)")
//                                .font(.system(size: 25, weight: .bold))
//                            Text(
//                                """
//                        Servings
//                        """)
//                                .font(.system(size: 12))
//                        }
//                        Spacer()
//                    }
//                }
            }
            .padding()
            .background(lightGreen.opacity(0.6))
            .foregroundColor(Color.white).cornerRadius(20)
            .padding(5)
            .offset(y: animatedIntro ? 0 : -80)
            .opacity(animatedIntro ? 1 : 0)
            .animation(.easeInOut(duration: 0.35))
        }
    }
}

struct RecipeServingsView: View {
    var thisRecipePost:RecipePost
    @Binding var multiplier:Int
    @Binding var animatedIntro:Bool
    var body: some View {
//        VStack(alignment: .leading, spacing:0){
            HStack(alignment: .center){
//                Spacer()
                if possible_stringToDouble(thisRecipePost.estimatedServings) != nil {
                    if possible_stringToDouble(thisRecipePost.estimatedServings)! > 0 {
                        VStack(alignment: .center){
                            Text("\(((Double(thisRecipePost.estimatedServings) ?? 1) * Double(multiplier)).stringWithoutZeroFraction)")
                                .font(.system(size: 25, weight: .bold))
                            Text(
                                """
                        Servings
                        """)
                                .font(.system(size: 12))
                        }
                        .padding()
                        .background(Color.init(white: 0.9))
                        .foregroundColor(Color.black)
                        .cornerRadius(20)
                        
                        //                        Spacer()
                    }
                }
                VStack{
                    HStack{
                        Button(action: {
                            if self.multiplier > 1 {
                                self.multiplier = self.multiplier - 1
                            }
                            
                        }){
                            Image(systemName: "minus.circle")
                        }.font(.system(size: 22, weight: .light))
                        .foregroundColor(Color.black.opacity(multiplier == 1 ? 0.3 : 1))
                        Text("\(multiplier)")
                            .font(.system(size: 25, weight: .bold))
                        Button(action: {
                            self.multiplier = self.multiplier + 1
                        }){
                            Image(systemName: "plus.circle")
                        }.font(.system(size: 22, weight: .light))
                    }
                    Text("Portions Multiplier")
                        .font(.system(size: 12))
                }
                .padding()
                .background(Color.clear)
                .foregroundColor(Color.black)
                .cornerRadius(20)
                
                
                Spacer()
            }
            
            .padding(5)
            .offset(y: animatedIntro ? 0 : -80)
            .opacity(animatedIntro ? 1 : 0)
            .animation(.easeInOut(duration: 0.45))
        
        //        }
    }
}

struct RecipePostIngredientsView: View {
    var thisRecipePost:RecipePost
    @Binding var animatedIntro:Bool
    @Binding var multiplier:Int
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            
            HStack{
                VStack(alignment: .leading, spacing:0){
                    Text("Ingredients")
                        .font(.system(size: 28, weight: .semibold)).foregroundColor(Color.white)
                    if multiplier > 1 {
                        Text("All numbers multiplied by \(multiplier) to match the portions multiplier above")
                            .font(.system(size: 13, weight: .medium)).opacity(0.6)
                    }
                    
                }
                Spacer()
            }
                
            .padding(.bottom, 10)
            VStack(alignment: .leading){
                ForEach(thisRecipePost.ingredients, id: \.id){thisIngredient in
//                    Text("\(self.thisRecipePost.ingredients.getIndexOf(thisIngredient) + 1)) ")
                    Text("• ")
                        .foregroundColor(Color.init(white: 1).opacity(0.8)) +
                        Text("\((thisIngredient.amount == -1 ? "" : (thisIngredient.amount * Double(self.multiplier)).stringWithoutZeroFraction) + " ")" +
                        "\(thisIngredient.amountUnit == .none ? "" : thisIngredient.amountUnit.rawValue + " ")" +
                        "\(thisIngredient.name)"
                    ).foregroundColor(Color.init(white: 1))
                        
                }.font(.system(size: 19))
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(lightGreen)
        .foregroundColor(Color.white).cornerRadius(20).shadow(radius: 2)
        .padding(5)
        .offset(y: animatedIntro ? 0 : -50)
        .opacity(animatedIntro ? 1 : 0)
        .animation(.easeInOut(duration: 0.55))
        .onAppear(){
            self.animatedIntro = true
        }
    }
}

struct RecipePostStepsView: View {
    var thisRecipePost:RecipePost
    @Binding var animatedIntro:Bool
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            
            HStack{
                
                Text("Steps")
                    .font(.system(size: 28, weight: .semibold)).foregroundColor(Color.white)
                Spacer()
            }
            .padding(.bottom, 10)
            VStack(alignment: .leading){
                ForEach(thisRecipePost.steps, id: \.id){thisStep in
                    Text("\(self.thisRecipePost.steps.getIndexOf(thisStep) + 1). ").foregroundColor(Color.init(white: 1).opacity(0.8)) +
                    Text("\(thisStep.subtitle)").foregroundColor(Color.white)
                        
                        
                }
                .font(.system(size: 19))
                    .fixedSize(horizontal: false, vertical: true)
                
            }
            
        }
        .padding()
        .background(darkGreen)
//        .foregroundColor(Color.white)
        .cornerRadius(20).shadow(radius: 2)
        .padding(5)
        .offset(y: animatedIntro ? 0 : -80)
        .opacity(animatedIntro ? 1 : 0)
        .animation(.easeInOut(duration: 0.65))
    }
}

//struct RecipePostCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecipePostCardView()
//    }
//}
