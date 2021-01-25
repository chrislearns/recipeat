//
//  ExploreView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/9/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import Firebase
import SPAlert


struct ExploreView: View {
    
    @EnvironmentObject var env: GlobalEnvironment
    
    var sortedFoodTags = FoodTagDictionary.values.sorted{$0.displayVal < $1.displayVal}
    
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
            NavigationLink(destination: RecipePostView(isShown_selection: self.$NavigationUnit.navigationSelector, RP_String: NavigationUnit.navigationContext as? String ?? ""), tag: NavigationDestination.RecipePostView.hashValue, selection: self.$NavigationUnit.navigationSelector){
                EmptyView()
            }
            NavigationLink(destination: CategoryView(categoryVal: NavigationUnit.navigationContext as? String ?? ""), tag: NavigationDestination.CategoryView.hashValue, selection: self.$NavigationUnit.navigationSelector){
                EmptyView()
            }
            Color.init(white: 0.95)
            VStack(alignment: .leading, spacing:15){
                
                Group{
                    Text("New Recipes")
                        .font(.system(size: 35, weight: Font.Weight.heavy))
                        .foregroundColor(Color.black)
                        .padding(.horizontal, 15).padding(.top, 15)
                    RecipeScrollView(recipes: self.$env.NewRecipes,
                        closure_tapRecipe: {recipeString in
                        self.NavigationUnit.navigationContext = recipeString
                        self.NavigationUnit.navigationSelector = NavigationDestination.RecipePostView.hashValue
                    })
                    .onAppear(){
                        if self.env.NewRecipes.timeStamp == nil {
                            DispatchQueue.main.async{ self.refreshNewRecipes()}
                        } else {
                            DispatchQueue.global(qos: .background).async{ self.refreshNewRecipes()}
                        }
                        
                    }
                }
                Spacer().frame(height:10)
                Group{
                    Text("Categories")
                    .font(.system(size: 35, weight: Font.Weight.heavy))
                    .foregroundColor(Color.black)
                    .padding(.horizontal, 15)
                    ScrollView(.horizontal){
                        HStack{
                        Spacer().frame(width: 15, height: 10)
                        LazyHGrid(rows: [
                            GridItem(.flexible(minimum: 130, maximum: .infinity)),
                            GridItem(.flexible(minimum: 130, maximum: .infinity)),
                            GridItem(.flexible(minimum: 130, maximum: .infinity))
                            
                        ], spacing: 10){
                            ForEach(self.sortedFoodTags, id: \.id){fTag in
//                                Text(fTag.displayVal)
                            VStack{
                                Spacer()
                                HStack{
                                    Text(fTag.displayVal)
                                        .font(.system(size: 25, weight: .heavy))
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }

                            }
                            .padding(.horizontal, 10).padding(.vertical, 7)
                            .frame(width: 280, height: 130)
                            .background(
//                                Color.red
                                Image(fTag.dbVal + "_500")
                                    .resizable()
                                    .scaledToFill()
                                    .background(Color.black)
                                    .overlay(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.8)]), startPoint: .top, endPoint: .bottom))
                            )
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .onTapGesture {
                                    self.NavigationUnit.navigationContext = fTag.dbVal
                                    self.NavigationUnit.navigationSelector = NavigationDestination.CategoryView.hashValue

                            }
                                                             }
                        }
                        Spacer().frame(width: 15, height: 10)//.background(Color.red)
                        }

                        
                    }
                    .overlay(
                        HStack{
                            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.2),Color.white.opacity(0)]), startPoint: .leading, endPoint: .trailing).frame(width: 20)
                            Spacer()
                            
                            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0),Color.white.opacity(0.2)]), startPoint: .leading, endPoint: .trailing).frame(width: 20)
                        }.frame(width: UniversalSquare.width)
                    )
                }
                Spacer().frame(height:10)
                //                .background(Color.red)
                //                Group{
                //                    Text("Top Chefs")
                //                        .font(.system(size: 35, weight: Font.Weight.heavy))
                //                        .foregroundColor(Color.black)
                //                        .padding(.horizontal, 15)
                //                    ScrollView(.horizontal, showsIndicators: false){
                //                        HStack(alignment: .top, spacing:0){
                //                            Spacer().frame(width: 15)
                //                            if self.env.PopularUser.results.count > 0 {
                //                                ForEach(self.env.PopularUser.results, id: \.id){ thisResult -> AnyView? in
                //
                //                                    if let thisUser = thisResult.any as? user {
                //                                        if thisUser.id.uuidString != "07964547-C707-4CF3-AB29-29994079B831" {
                //                                            return AnyView(
                //                                                HStack{
                //                                                    //                                                Button(action: {
                //                                                    //                                                    self.NavigationUnit.navigationContext = thisUser.id.uuidString
                //                                                    //                                                    self.NavigationUnit.navigationSelector = NavigationDestination.UserHomeView.hashValue
                //                                                    //                                                }){
                //
                //                                                    ExploreUserView(thisUser: thisUser)
                //                                                        .cornerRadius(10)
                //                                                        .onTapGesture(count: 1, perform: {
                //                                                            self.NavigationUnit.navigationContext = thisUser.id.uuidString
                //                                                            self.NavigationUnit.navigationSelector = NavigationDestination.UserHomeView.hashValue
                //                                                        })
                //                                                    //                                                }
                //                                                    Spacer().frame(width: 15)
                //                                                }
                //                                            )
                //                                        } else {
                //                                            return nil
                //                                        }
                //                                    } else {
                //                                        return nil
                //                                    }
                //                                }
                //
                //                            } else {
                //                                VStack{
                //                                    Rectangle().frame(width: 300, height: 320)
                //                                        .foregroundColor(Color.init(white: 0.9))
                
                //                                        .cornerRadius(10).clipped()
                //                                    Spacer()
                //
                //                                }
                //                            }
                //                        }
                //                            //                        .frame(maxHeight: 320)
                //                            .onAppear(){
                //                                if let oldTimestamp = self.env.PopularUser.timeStamp {
                //                                    let oldTime_plus15min = oldTimestamp.addingTimeInterval(CacheDuration.Min15.rawValue)
                //                                    print("now: \(Date().debugDescription)")
                //                                    print("old + 15: \(oldTime_plus15min.debugDescription)")
                //                                    if oldTime_plus15min < Date(){
                //                                        print("hasn't been updated in over 15 minutes")
                //                                        self.refreshTopUsers()
                //                                    } else {
                //
                //                                    }
                //                                } else {
                //                                    self.refreshTopUsers()
                //                                }
                //                        }
                //
                //
                //                    }.overlay(
                //                        HStack{
                //                            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.15),Color.white.opacity(0)]), startPoint: .leading, endPoint: .trailing).frame(width: 20)
                //                            Spacer()
                //
                //                            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0),Color.white.opacity(0.15)]), startPoint: .leading, endPoint: .trailing).frame(width: 20)
                //                        }.frame(width: UniversalSquare.width)
                //                    )
                //                }
                
                //                Spacer().frame(height:10)
                //                Group{
                //                    Text("Popular Recipes")
                //                        .font(.system(size: 35, weight: Font.Weight.heavy))
                //                        .foregroundColor(Color.black)
                //                        .padding(.horizontal, 15)
                //                    ScrollView(.horizontal, showsIndicators: false){
                //                        HStack(spacing:0){
                //                            Spacer().frame(width: 15)
                //                            if self.env.PopularRecipes.results.count > 0 {
                //                                ForEach(self.env.PopularRecipes.results, id: \.id){ thisResult -> AnyView? in
                //
                //                                    if let thisRP = thisResult.any as? RecipePost {
                //                                        return AnyView(
                //                                            HStack{
                //                                                Button(action: {
                //                                                    self.NavigationUnit.navigationContext = thisRP.id.uuidString
                //                                                    self.NavigationUnit.navigationSelector = NavigationDestination.RecipePostView.hashValue
                //                                                }){
                //                                                    ExploreRecipeView(recipe: thisRP)
                //                                                }
                //                                                Spacer().frame(width: 15)
                //                                            }
                //                                        )
                //                                    } else {
                //                                        return nil
                //                                    }
                //                                }
                //                            } else {
                //                                ForEach(0..<3){ i -> AnyView in
                //                                        return AnyView(
                //                                            HStack{
                //                                                VStack{
                //                                                    Rectangle().frame(width: 330, height: 180)
                    
//                    .cornerRadius(10).clipped()
                //                                                    Spacer()
                //                                                }
                //                                                Spacer().frame(width: 15)
                //                                            }
                //                                        )
                //                                }
                //                            }
                //                        }.frame(height: 210)
                //
                //                    }.overlay(
                //                        HStack{
                //                            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.15),Color.white.opacity(0)]), startPoint: .leading, endPoint: .trailing).frame(width: 20)
                //                            Spacer()
                //
                //                            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0),Color.white.opacity(0.15)]), startPoint: .leading, endPoint: .trailing).frame(width: 20)
                //                        }.frame(width: UniversalSquare.width)
                //                    )
                //                }
                
                //                Spacer().frame(height:10)
            }.onAppear(){
                //                DispatchQueue.global(qos: .userInteractive).async {
                self.refreshExplore()
                //                }
                
            }
        }
        
    }
    
    //DONT DELETE ME!!! this contains the logic i will need to implement the popular recipe algorithm
    func refreshExplore(){
        //        if self.env.PopularRecipes.timeStamp == nil {
        //
        //
        //        println("PopularRecipes - Current: \(self.env.PopularRecipes.results.count)")
        //        let popularRecipe_queryRound = QueryRound(queryType: .order_and_Limit, refString: "recipe", field: "quantity_likes", QueryWeight: 500, value: 30, expectedReturn: SearchType.Recipe)
        //        DistributeQueryLoads(queryRounds: [popularRecipe_queryRound], completion: {results, queryTime in
        //            println("finished searching for popular recipes results")
        //            let sortedResults = results.sorted{ ($0.any as? RecipePost)?.likes.count ?? 0 > ($1.any as? RecipePost)?.likes.count ?? 0 }
        //            println("PopularRecipes - Results: \(results.count)")
        //            if let old_timeStamp = self.env.PopularRecipes.timeStamp {
        //                if queryTime > old_timeStamp {
        //                    self.env.PopularRecipes.results = sortedResults
        //                    self.env.PopularRecipes.timeStamp = queryTime
        //                } else {
        //                    println("planned on showing recipe but ended up here")
        //                    println("newdata - \(queryTime)")
        //                    println("olddata - \(old_timeStamp)")
        //                }
        //            } else {
        //                self.env.PopularRecipes.results = sortedResults
        //                self.env.PopularRecipes.timeStamp = queryTime
        //            }
        //        })
        //        }
        
        
        
        
        
        
    }
    
    func refreshNewRecipes(){
        println("NewRecipes - Current: \(self.env.NewRecipes.results.count)")
        let newRecipes_queryRound = QueryRound(queryType: .order_and_Limit, refString: "recipe", field: "dateCreate", QueryWeight: 500, value: 30, expectedReturn: SearchType.Recipe)
        DistributeQueryLoads(queryRounds: [newRecipes_queryRound], completion: {results, queryTime in
            println("finished searching for new recipe results")
            if let results = results.map({$0.any}) as? [RecipePost] {
                let sortedResults = results.sorted{ $0.dateCreate > $1.dateCreate }
            println("New recipes: \(results.count)")
            if let old_timeStamp = self.env.NewRecipes.timeStamp {
                if queryTime > old_timeStamp {
                    print("newest recipe is \(sortedResults[0].title)")
                        if sortedResults[0].id.uuidString == self.env.NewRecipes.results.first?.id.uuidString {
                            print("nothing has changed - no need to update the UI/the newest recipe being shown")
                        } else {
                            print("new recipes have been created since this explore was last updated - showing the new things!")
                            self.env.NewRecipes.results = sortedResults
                            self.env.NewRecipes.timeStamp = queryTime
                        }
                } else {
                    println("planned on showing recipe but ended up here because somehow this is and old query and the newest query is already shown")
                    println("newdata - \(queryTime)")
                    println("olddata - \(old_timeStamp)")
                }
            } else {
                self.env.NewRecipes.results = sortedResults
                self.env.NewRecipes.timeStamp = queryTime
            }
            } else {
                print("something went wrong - couldn't unwrap results to [RecipePost]")
            }
        })
    }
    
    func refreshTopUsers(){
        println("TopChefs - Current: \(self.env.PopularUser.results.count)")
        let popularUser_queryRound = QueryRound(queryType: .order_and_Limit, refString: "users", field: "quantity_followers", QueryWeight: 500, value: 40, expectedReturn: SearchType.User)
        DistributeQueryLoads(queryRounds: [popularUser_queryRound], completion: {results, queryTime in
            println("finished searching for popular users results")
            //Taking the opportunity to use filter to exlude people with less than 1 recipe
            let sortedResults = results
            
            println("PopularUsers - Results: \(results.count)")
            println("PopularUsers - Results: \(results.map({($0.any as? user)?.name ?? ""}))")
            println("PopularUsers - Results: \(sortedResults.map({($0.any as? user)?.name ?? ""}))")
            if let old_timeStamp = self.env.PopularUser.timeStamp {
                if queryTime > old_timeStamp {
                    self.env.PopularUser.results = sortedResults
                    self.env.PopularUser.timeStamp = queryTime
                } else {
                    println("planned on showing recipe but ended up here")
                    println("newdata - \(queryTime)")
                    println("olddata - \(old_timeStamp)")
                }
            } else {
                self.env.PopularUser.results = sortedResults
                self.env.PopularUser.timeStamp = queryTime
            }
        })
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
