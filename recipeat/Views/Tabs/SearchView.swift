//
//  SearchView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 3/2/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import Firebase
import SPAlert

enum SearchType:String, CaseIterable {
    case All = "all"
    case User = "users"
    case Comments = "comments"
    case Recipe = "recipe"
    case NewsFeed = "newsfeed"
}

enum SearchState:String, CaseIterable {
    case Searching = "Searching..."
    case Naive = "Let's find your next masterpiece!"
    //The reason the value of complete is "No results found." is because of the way we use the value of this enum to set the text on the screen. tehcnically we could have ".Complete" with actual values present, but in that case we wouldn't be displaying the text at all - instead we would be showing the results.
    case Complete = "No results found."
}

struct Identifiable_Any:Identifiable{
    var id = UUID()
    var any:Any?
    var QueryWeight:Double = 0
}

struct SearchResults:Identifiable {
    var id = UUID()
    var results:[Identifiable_Any]
    var timeStamp:Date?
    
}

struct RecipeResults:Identifiable {
    var id = UUID()
    var results:[RecipePost]
    var timeStamp:Date?
}

struct SearchView: View {
    @State var searchTerm = ""
    @State var searchType = SearchType.All
    @State var mainSearchResults = SearchResults(results: [], timeStamp: nil)
    @State var similarSearchResults = SearchResults(results: [], timeStamp: nil)
    @State var searchState = SearchState.Naive
    @EnvironmentObject var env: GlobalEnvironment
    @State var textfieldIsFocused = false
    @State var NavigationUnit = HashableNavigationUnit()
    var body: some View {
        
        ZStack{
            Color.init(white: 247/255)
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
            VStack(spacing: 0){
                VStack{
                    TextField_Detectable(text: $searchTerm, title: "Search",
                                         
                                         onEditingChanged: { isChanging in
                                            print(isChanging)
                                            self.textfieldIsFocused = isChanging
                    },
                                         onValChanged: {tfContent in
                                            print("change detected: \(tfContent)")
                                            DispatchQueue.main.async{
                                                self.submitQueries()
                                            }
                                            
                    },
                                         onCommit: {
                                            print("committed")
                                            DispatchQueue.main.async{
                                                self.submitQueries()
                                            }
                                            //reset the results
                                            
                    })
                        .padding(10)
                        .background(Color.init(white: 230/255))
                        .cornerRadius(8)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .autocapitalization(.none)
                    
                    ScrollView(.horizontal){
                        HStack{
                            ForEach(SearchType.allCases, id: \.self){thisCase -> AnyView? in
                                var caseText = ""
                                if thisCase == SearchType.User{
                                    caseText = "People"
                                } else if thisCase == SearchType.Recipe{
                                    caseText = "Recipes"
                                } else if thisCase == SearchType.All{
                                    caseText = "All"
                                }
                                if caseText != "" {
                                    return AnyView(
                                        Button(action: {
                                            self.searchType = thisCase
                                            //This is just saying that if you happen to switch search types while in a search it will execute the search again under the newly selected category
                                            if self.searchTerm != "" {
                                                DispatchQueue.main.async{
                                                    self.submitQueries()
                                                }
                                            }
                                        }){
                                            Text(caseText)
                                                .padding(5)
                                                .background(self.searchType == thisCase ? lightGreen : Color.init(white: 0.9))
                                                .foregroundColor(self.searchType == thisCase ? Color.white : Color.black)
                                                .cornerRadius(8)
                                                .animation(Animation.easeIn(duration: 0.2))
                                        }
                                    )
                                } else {
                                    return nil
                                }
                            }
                            
                            
                        }.padding(.horizontal, 10).padding(.bottom, 5)
                    }
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.init(white: 0.95))
                }
                .background(Color.init(white: 247/255).shadow(radius: 3, y: 3))
                .zIndex(4)
                
                if mainSearchResults.results.count > 0 || similarSearchResults.results.count > 0 {
                    List{
                        Section(header: Text("Results")){
                        if mainSearchResults.results.count > 0 {
                            ForEach(mainSearchResults.results, id: \.id){thisResult -> AnyView? in
                                if let thisUser = thisResult.any as? user{
                                    if self.env.currentUser.blockedBy.first(where: {$0.uuidString == thisUser.id.uuidString}) == nil {
                                        return AnyView(
                                            Button(action: {
                                                self.NavigationUnit.navigationContext = thisUser
                                                self.NavigationUnit.navigationSelector = NavigationDestination.UserHomeView.hashValue
                                            }){
                                                SearchResult_User(U: (thisUser).truncForm)
                                            }
                                        )
                                    } else {
                                        print("A user matched the description but they previously blocked the searcher")
                                        return nil
                                        
                                    }
                                    
                                    
                                } else if let thisRecipe = thisResult.any as? RecipePost{
                                    
                                    if self.env.currentUser.blockedBy.first(where: {$0.uuidString == thisRecipe.postingUser.id.uuidString}) == nil {
                                    return AnyView(
                                        Button(action: {
                                            self.NavigationUnit.navigationContext = (thisRecipe).id.uuidString
                                            self.NavigationUnit.navigationSelector = NavigationDestination.RecipePostView.hashValue
                                        }){
                                            SearchResult_Recipe(RP: thisRecipe)
                                        }
                                    )
                                    } else {
                                        print("A recipe matched the description but the posting user previously blocked the searcher")
                                        return nil
                                        
                                    }

                                    
                                    
                                } else {
                                    return AnyView(
                                    Text("Unknown result")
                                    )
                                }
                                

                        }
                        .animation(.linear(duration: 0.25))
                        .transition(.slide)
                        } else {
                            SearchResult_None()
                            }
                        }
                        if similarSearchResults.results.count > 0 {
                        Section(header: Text("You might also like...")) {
                            ForEach(similarSearchResults.results, id: \.id){thisResult in
                                ZStack{
                                    if thisResult.any as? user != nil{
                                        Button(action: {
                                            self.NavigationUnit.navigationContext = thisResult.any as! user
                                            self.NavigationUnit.navigationSelector = NavigationDestination.UserHomeView.hashValue
                                        }){
                                            SearchResult_User(U: (thisResult.any as! user).truncForm)
                                        }
                                    } else if thisResult.any as? RecipePost != nil{
                                        Button(action: {
                                            self.NavigationUnit.navigationContext = (thisResult.any as! RecipePost).id.uuidString
                                            self.NavigationUnit.navigationSelector = NavigationDestination.RecipePostView.hashValue
                                        }){
                                            SearchResult_Recipe(RP: thisResult.any as! RecipePost)
                                        }
                                        
                                    } else {
                                        Text("Unknown result")
                                    }
                                }
                            }
                        }
                        }
                    }
                } else {
                    
                    if self.searchTerm == "" && !self.textfieldIsFocused {
                        ScrollView{
                            ExploreView()
                            Spacer().frame(height: self.env.tabBarHeight)
                        }
                    } else {
                        Image("discoverLove")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width:80, height:80)
                            .padding(.top, 40)
                            .foregroundColor(Color.init(white: 0.8))
                        Text("RESULTS")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.init(white: 0.8))
                        Text(searchState.rawValue)
                            .frame(width: UniversalSquare.width - 100)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.init(white: 0.8))
                        Spacer().frame(height:40)
                        Spacer().frame(height: self.env.tabBarHeight)
                        Spacer()
                    }
                }
                
            }.background(Color.init(white: 0.95))
        }
//        .navigationBarTitle("Search", displayMode: .inline)
            .onAppear(){
                if self.searchTerm == "" {
                    self.searchState = .Naive
                }
        }
    }
    
    func submitQueries(){
        if self.searchTerm.alphanumerics.count > 0 {
            mainQuery()
            similarQuery()
        }
    }
    
    func mainQuery(){
        self.mainSearchResults.results = []
        if self.searchTerm == "" {
            self.searchState = SearchState.Naive
        } else {
            self.searchState = SearchState.Searching
            form_QueryRound_search(searchType: searchType, searchTerm: searchTerm.alphanumerics_andWhiteSpace, completion: {results, queryTime in
                if let old_timeStamp = self.mainSearchResults.timeStamp {
                    if queryTime > old_timeStamp {
                        self.mainSearchResults.results = results
                        self.mainSearchResults.timeStamp = queryTime
                    }
                } else {
                    self.mainSearchResults.results = results
                    self.mainSearchResults.timeStamp = queryTime
                }
                
                if self.searchTerm == "" {
                    self.searchState = SearchState.Naive
                } else {
                    self.searchState = SearchState.Complete
                }
            })
            
        }
        
    }
    
    func similarQuery(){
        self.mainSearchResults.results = []
        if searchType == SearchType.Recipe || searchType == SearchType.All {
            let taggedWords = evaluateComponents(text: self.searchTerm.alphanumerics_andWhiteSpace)
                print("Tagged Words: \(taggedWords.map{$0.word})")
                print("Tagged Tags: \(taggedWords.map{$0.tag.rawValue})")

            var similarWords:[String] = []
            for word in taggedWords.map({$0.word}){
                if let newWords = embedCheck(word: word){
                    similarWords = similarWords + newWords
                }
            }

            let chunkedTags = similarWords.chunked(by: 10)
            
            //These query round will be for similar word in the "recipe" collection
            let lowPriority_QueryRound = chunkedTags.map{
                QueryRound(queryType: .ArrayContainsAny, refString: "recipe", field: "tags_title", QueryWeight: 200, value: $0, expectedReturn: .Recipe)
            }
            

        
        DistributeQueryLoads(queryRounds: lowPriority_QueryRound, completion: {results, queryTime in
            //            p/("finished searching for SIMILAR recipe results")
            let sortedResults = results.sorted{ if ($0.any as? RecipePost)?.dateCreate != ($1.any as? RecipePost)?.dateCreate { // first, compare by last names
                        return ($0.any as? RecipePost)?.dateCreate ?? "" > ($1.any as? RecipePost)?.dateCreate ?? ""
                    }
                    /*  last names are the same, break ties by foo
                    else if $0.foo != $1.foo {
                        return $0.foo < $1.foo
                    }
                    ... repeat for all other fields in the sorting
                    */
                    else { // All other fields are tied, break ties by last name
                        return ($0.any as? RecipePost)?.dateCreate ?? "" > ($1.any as? RecipePost)?.dateCreate ?? ""
                    }
                }
//                results.sorted{ ($0.any as? RecipePost)?.dateCreate ?? "" > ($1.any as? RecipePost)?.dateCreate ?? "" }
            
            
            print("Similar recipes: \(results.count)")
            if let old_timeStamp = self.similarSearchResults.timeStamp {
                if queryTime > old_timeStamp {
                    //This means replace the old results
                    self.similarSearchResults.results = sortedResults
                    self.similarSearchResults.timeStamp = queryTime
                } else  if queryTime > old_timeStamp {
                    
                    //This lets us start showing results as they come in and append the old view as new ones continue to come in
                    self.similarSearchResults.results = self.similarSearchResults.results + sortedResults
                } else {
                    //            p/("planned on showing recipe but ended up here")
                    //            p/("newdata - \(queryTime)")
                    //            p/("olddata - \(old_timeStamp)")
                }
            } else {
                
                //            p/("we're here because old_timestamp unwrap failed meaning no previous timestamp was present, therefore this is the first set of search results")
                self.similarSearchResults.results = sortedResults
                self.similarSearchResults.timeStamp = queryTime
            }
        })
    }
            
        
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
