//
//  CategoryView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/24/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct CategoryView: View {
    
    @EnvironmentObject var env: GlobalEnvironment
    
    
    
    @State var catRecip_new = RecipeResults(results: [], timeStamp: nil)
    @State var catRecip_top = RecipeResults(results: [], timeStamp: nil)
    var categoryVal:String
    @State var tagEntity:TagEntity = TagEntity(keywords: [], dbVal: "", displayVal: "...")
    @State var NavigationUnit = HashableNavigationUnit()
    var body: some View {
        ZStack{
            NavigationLink(
                destination: UserView(
                                      //This tries to unwrap the navigation context as a user()
                    user_forPage: NavigationUnit.navigationContext as? user ?? nil,
                    //This tries to do the same as above, but if it fails, it tries to unwrap it as a string, and if THAT fails then it just gives a default string value of "". This should go on to the UserView which will then fail to retrieve a user's page and return that error with some sort of alert
                    user_forPage_string: (NavigationUnit.navigationContext as? user)?.id.uuidString ?? (NavigationUnit.navigationContext as? String ?? "")
                ),
                tag: NavigationDestination.UserHomeView.hashValue,
                selection: self.$NavigationUnit.navigationSelector){
                    EmptyView()
            }
            NavigationLink(destination: RecipePostView(
                isShown_selection: self.$NavigationUnit.navigationSelector, RP_String: NavigationUnit.navigationContext as? String ?? ""), tag: NavigationDestination.RecipePostView.hashValue, selection: self.$NavigationUnit.navigationSelector
            ){
                EmptyView()
            }
            
            VStack{
                Image(categoryVal)
                    .resizable()
                .scaledToFill()
                    .frame(width: UniversalSquare.width, height: 550)
                .overlay(
                LinearGradient(gradient: Gradient(colors: [
                    Color.black.opacity(0.8),
                    Color.white.opacity(0.4),
                ]), startPoint: .top, endPoint: .bottom)
                    .overlay(
                    LinearGradient(gradient: Gradient(colors: [
                        Color.white.opacity(0),
                        
                        Color.white.opacity(1),
                    ]), startPoint: .top, endPoint: .bottom)
                    )
                )
                Spacer()
            }
                ScrollView{
                    VStack(alignment: .leading, spacing:15){
                        HStack{
                            Text("\(tagEntity.displayVal)")
                                .font(.system(size: 50, weight: Font.Weight.heavy))
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 15).padding(.top, 15)
                            Spacer()
                        }
                        Spacer().frame(height: 25)
                        if catRecip_new.results.count == 0 && catRecip_top.results.count == 0
                         && catRecip_new.timeStamp !=  nil && catRecip_top.timeStamp !=  nil{
                            VStack{
                                Spacer().frame(height: 80)
                                Image("11")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:80, height:80)
                                Text("YOU'RE FIRST")
                                    .font(.system(size: 20, weight: .semibold))
                                Text("Be the first person to add a recipe in this category by clicking on the \"Add Recipe\" tab below").frame(width: UniversalSquare.width - 100)
                                    .multilineTextAlignment(.center)
                                Spacer().frame(height: 80)
                            }
                            .frame(width: UniversalSquare.width)
                            .foregroundColor(Color.init(white: 0.40))
                        
                            } else {
                        Text("🔥 Top Recipes")
                            .font(.system(size: 25, weight: Font.Weight.bold))
                            .foregroundColor(darkPink)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(10, corners: [.topRight, .bottomRight])
                        RecipeScrollView(recipes: $catRecip_top,
                            closure_tapRecipe: {recipeString in
                            self.NavigationUnit.navigationContext = recipeString
                            self.NavigationUnit.navigationSelector = NavigationDestination.RecipePostView.hashValue
                        })
                            .onAppear(){
                                    if let foodCategoricalTag = FoodCategoricalTags.init(rawValue:self.categoryVal){
                                        if let uwEntity = FoodTagDictionary[foodCategoricalTag]{
                                            print(uwEntity.displayVal)
                                            self.tagEntity = uwEntity
                                            print("unwrapped tagEntity")
                                            self.categoricalRecipes_top(category: uwEntity.dbVal, currentResults: self.catRecip_top, completion: {results in self.catRecip_top = results})
                                        }
                                    }
                                    
                                    
                                    
                            }
                        
                        Spacer().frame(height: 10)
                        Text("⏲️ New Recipes")
                            .font(.system(size: 25, weight: Font.Weight.bold))
                            .foregroundColor(darkGreen)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(10, corners: [.topRight, .bottomRight])
                        RecipeScrollView(recipes: $catRecip_new, closure_tapRecipe: {recipeString in
                            self.NavigationUnit.navigationContext = recipeString
                            self.NavigationUnit.navigationSelector = NavigationDestination.RecipePostView.hashValue
                        })
                            .onAppear(){
                                if let foodCategoricalTag = FoodCategoricalTags.init(rawValue:self.categoryVal){
                                    if let uwEntity = FoodTagDictionary[foodCategoricalTag]{
                                        print(uwEntity.displayVal)
                                        self.tagEntity = uwEntity
                                        print("unwrapped tagEntity")
                                        self.categoricalRecipes_new(category: uwEntity.dbVal, currentResults: self.catRecip_new, completion: {results in self.catRecip_new = results})
                                    }
                                }
                                
                                
                                
                        }
                        
                    }
                    }
                }.frame(width: UniversalSquare.width)
            
            
        }.navigationBarTitle("Category")
    }
    
    func categoricalRecipes_new(category:String, currentResults:RecipeResults, completion: @escaping (RecipeResults) -> Void) {
        println("NewRecipes - Current: \(currentResults.results.count)", 0)
        println("Searching for new recipes in category: \(String(describing: category))", 0)
        let newRecipes_queryRound = QueryRound(queryType: .ArrayContainsAny, refString: "recipe", field: "tags", QueryWeight: 500, value: [category], expectedReturn: SearchType.Recipe, filters:[QueryFilter(queryFilterType: .order_and_Limit, field: "dateCreate", filterArgument: 50)]
            )
        
        DistributeQueryLoads(queryRounds: [newRecipes_queryRound], completion: {results, queryTime in
            println("finished searching for new recipe results")
            if let results = results.toRecipeResults(){
                let sortedResults = results.sorted{ $0.dateCreate > $1.dateCreate}
            if let old_timeStamp = currentResults.timeStamp {
                if queryTime > old_timeStamp{
                    if sortedResults.count > 1 {
                        print("newest recipe is \(sortedResults[0].title)")
                    
                        if sortedResults[0].id.uuidString == currentResults.results.first?.id.uuidString {
                            print("nothing has changed - no need to update the UI/the newest recipe being shown")
                        } else {
                            print("new recipes have been created since this explore was last updated - showing the new things!")
                            completion(RecipeResults(results: sortedResults, timeStamp: queryTime))
                            
                        }
                    
                    } else {
                        print("fetched new results but they were empty")
                        completion(RecipeResults(results: sortedResults, timeStamp: queryTime))
                    }
                    
                } else {
                    println("planned on showing recipe but ended up here because somehow this is and old query and the newest query is already shown")
                    println("newdata - \(queryTime)")
                    println("olddata - \(old_timeStamp)")
                }
            } else {
                completion(RecipeResults(results: sortedResults, timeStamp: queryTime))
            }
            }
        })
    }
    func categoricalRecipes_top(category:String, currentResults:RecipeResults, completion: @escaping (RecipeResults) -> Void) {
        println("TopRecipes - Current: \(currentResults.results.count)", 0)
        println("Searching for top recipes in category: \(String(describing: category))", 0)
        let newRecipes_queryRound = QueryRound(queryType: .ArrayContainsAny, refString: "recipe", field: "tags", QueryWeight: 500, value: [category], expectedReturn: SearchType.Recipe, filters:[QueryFilter(queryFilterType: .order_and_Limit, field: "quantity_likes", filterArgument: 50)]
            )
        
        DistributeQueryLoads(queryRounds: [newRecipes_queryRound], completion: {results, queryTime in
            println("finished searching for top recipe results")
            if let results = results.toRecipeResults(){
                let sortedResults = results.sorted{$0.likes.count > $1.likes.count}
            println("top recipes: \(results.count)")
            if let old_timeStamp = currentResults.timeStamp {
                if queryTime > old_timeStamp{
                    if sortedResults.count > 1 {
                        print("top recipe is \(sortedResults[0].title)")
                        
                            
                            completion(RecipeResults(results: sortedResults, timeStamp: queryTime))
                            
                    
                    } else {
                        print("fetched top results but they were empty - still updating the page with nothing")
                        completion(RecipeResults(results: sortedResults, timeStamp: queryTime))
                    }
                    
                } else {
                    println("planned on showing recipe but ended up here because somehow this is and old query and the newest query is already shown")
                    println("newdata - \(queryTime)")
                    println("olddata - \(old_timeStamp)")
                }
            } else {
                completion(RecipeResults(results: sortedResults, timeStamp: queryTime))
            }
            }
        })
    }
    
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView(categoryVal: "ketogenic")
    }
}
