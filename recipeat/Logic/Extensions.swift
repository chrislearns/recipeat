//
//  Extensions.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/16/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import Foundation
import SwiftUI
import SPAlert
import Firebase
import FirebaseFirestore
import AVFoundation

extension Array where Element == Any {
    func toUUID() -> [UUID]{
        println("converting likes as [Any] to [UUID] -- \(self)")
        if let likes = self as? [UUID]{
            return likes
        } else if let likes = self as? [String]{
            if let convertedLikes = likes.toUUID_list() {
                println("converted successfully -- \(convertedLikes)")
                return convertedLikes
            } else {
                return []
            }
        } else {
            println("error unwrapping the trunc users when initializing")
            return []
        }
    }
    
    func toTruncUser() -> [trunc_user]{
        if let items = self as? [trunc_user] {
            return items
        } else if let items_dicts = self as? [[String:Any]] {
            var returnVal:[trunc_user] = []
            for element in items_dicts {
                returnVal.append(trunc_user(
                    id: UUID(uuidString:
                        element["id"] as? String ?? UUID().uuidString
                        ) ?? UUID()
                    ,
                    username: element["username"] as? String ?? "Username Error",
                    name: element["name"] as? String ?? "Name Error",
                    verified: element["verified"] as? Bool ?? false)
                )
            }
            return returnVal
        } else {
            return []
        }
    }
    
    func toTruncRecipe() -> [trunc_RecipePost]{
        if let items = self as? [trunc_RecipePost] {
            return items
        } else if let items_dicts = self as? [[String:Any]] {
            var returnVal:[trunc_RecipePost] = []
            for element in items_dicts {
                returnVal.append(trunc_RecipePost(
                    id: UUID(uuidString:
                        element["id"] as? String ?? UUID().uuidString
                        ) ?? UUID()
                    ,
                    title: element["title"] as? String ?? "Title Error",
                    subtitle: element["subtitle"] as? String ?? "Subtitle Error",
                    dateCreate: element["dateCreate"] as? String ?? "",
                    likes: element["likes"] as? [Any] ?? []
                    )
                )
            }
            return returnVal
        } else {
            return []
        }
    }
    
    func toIngredients() -> [Ingredient] {
        if let items = self as? [Ingredient] {
            return items
        } else if let items_dicts = self as? [[String:Any]] {
            var returnVal:[Ingredient] = []
            for element in items_dicts {
                returnVal.append(Ingredient(
                    id:  UUID(uuidString: element["id"] as? String ?? UUID().uuidString) ?? UUID(),
                    name: element["name"] as? String ?? "Subtitle Error",
                    amount: element["amount"] as? Double ?? -1,
                    amountUnit: IngredientUnit.init(rawValue: element["amountUnit"] as? String ?? "") ?? IngredientUnit.none)
                    
                )
            }
            return returnVal
        } else {
            return []
        }
    }
    
    func toSteps() -> [Step] {
        if let items = self as? [Step] {
            return items
        } else if let items_dicts = self as? [[String:Any]] {
            var returnVal:[Step] = []
            for element in items_dicts {
                returnVal.append(Step(
                    id: UUID(uuidString: element["id"] as? String ?? UUID().uuidString) ?? UUID(),
                    subtitle: element["subtitle"] as? String ?? "Subtitle Error")
                )
            }
            return returnVal
        } else {
            return []
        }
    }
    
    func toTags() -> [TagEntity] {
        if let items = self as? [TagEntity] {
            return items
        } else if let items_dicts = self as? [String] {
            var returnVal:[TagEntity] = []
            for element in items_dicts {
                
                if let FCTag = FoodCategoricalTags.allCases.first(where: {$0.rawValue == element}) {
                    if let tagEntity = FoodTagDictionary.first(where: {$0.key.rawValue == FCTag.rawValue}){
                        println("found the matching entity for the tag \(FCTag.rawValue)")
                        returnVal.append(tagEntity.value)
                        
                    } else {
                        print("FCTag \(FCTag) could not be located in the FoodTagDictionary and unwrapped into a TagEntity")
                    }
                } else {
                    print("element \(element) could not be unwrapped into an FCTag")
                }
                
            }
            return returnVal
        } else {
            return []
        }
    }
}

extension Array where Element == Identifiable_UIImage {
    func toAnyView(_ scaleFit:Bool = true) -> [Identifiable_AnyView]{
        var returnVal:[Identifiable_AnyView] = []
        for element in self {
            returnVal.append(
                Identifiable_AnyView(anyView:
                    AnyView(
                        ZStack{
                            Text("")
                            if scaleFit {
                                Image(uiImage: element.image.raw)
                                //.resizable()
                                //.scaledToFit()
                            } else {
                                Image(uiImage: element.image.raw)
                            }
                        }
                        
                    )
                )
            )
        }
        
        return returnVal
    }
    
    func getIndexOf(_ anyObject: Identifiable_UIImage) -> Int{
        
        var index = -1
        for i in 0..<self.count {
            if self[i].id == anyObject.id {
                index = i
            }
        }
        //        print("index = \(index)")
        return index
    }
    
}

extension Array where Element == Identifiable_AnyView {
    func getIndexOf(_ anyObject: Identifiable_AnyView) -> Int{
        
        var index = -1
        for i in 0..<self.count {
            if self[i].id == anyObject.id {
                index = i
            }
        }
        print("index = \(index)")
        return index
    }
}

extension Array where Element == Ingredient {
    func formatForFirebase() -> [[String:Any]]{
        var returnVal:[[String:Any]] = []
        for element in self {
            returnVal.append(element.dictionary.value)
        }
        
        return returnVal
    }
    
    func getIndexOf(_ anyObject: Ingredient) -> Int{
        
        var index = -1
        for i in 0..<self.count {
            if self[i].id == anyObject.id {
                index = i
            }
        }
        print("index = \(index)")
        return index
    }
    
}

extension Array where Element == Identifiable_Any {
    func toRecipeResults() -> [RecipePost]? {
        if let i = self.map({$0.any}) as? [RecipePost] {
            return i
        } else {
            return nil
        }
    }
}

extension Array where Element == Step {
    func formatForFirebase() -> [[String:Any]]{
        var returnVal:[[String:Any]] = []
        for element in self {
            returnVal.append(element.dictionary.value)
        }
        
        return returnVal
    }
    
    func getIndexOf(_ anyObject: Step) -> Int{
        
        var index = -1
        for i in 0..<self.count {
            if self[i].id == anyObject.id {
                index = i
            }
        }
        println("index = \(index)")
        return index
    }
    
}

extension Array where Element == String {
    func toUUID_list() -> [UUID]?{
        var returnVal:[UUID] = []
        for element in self {
            if let castedUUID = UUID(uuidString: element) {
                returnVal.append(castedUUID)
            }
            
        }
        
        if self.count > returnVal.count {
            println("unable to convert all UUIDs")
            return nil
        } else {
            return returnVal
        }
        
        
    }
    
    
    
}

extension Array where Element == TagEntity {
    func formatForFirebase() -> [[String:Any]]{
        var returnVal:[[String:Any]] = []
        for element in self {
            returnVal.append(element.dictionary)
        }
        
        return returnVal
    }
    
    //These is what is run/stored as the tags of a recipe
    func dbValue_StringArray() -> [String]{
        var returnVal:[String] = []
        for element in self {
            returnVal.append(element.dbVal)
        }
        
        return returnVal
    }
    
    func getIndexOf(_ anyObject: TagEntity) -> Int{
        
        var index = -1
        for i in 0..<self.count {
            if self[i].id == anyObject.id {
                index = i
            }
        }
        println("index = \(index)")
        return index
    }
    
}

extension Array where Element == TagObject {
    
    func getIndexOf(_ anyObject: TagObject) -> Int{
        
        var index = -1
        for i in 0..<self.count {
            if self[i].id == anyObject.id {
                index = i
            }
        }
        println("index = \(index)")
        return index
    }
    
}

extension Array where Element == TagObjectList {
    
    func getIndexOf(_ anyObject: TagObjectList) -> Int{
        
        var index = -1
        for i in 0..<self.count {
            if self[i].id == anyObject.id {
                index = i
            }
        }
        println("index = \(index)")
        return index
    }
    
}

extension Array where Element == trunc_RecipePost {
    func formatForFirebase() -> [[String:Any]]{
        var returnVal:[[String:Any]] = []
        for element in self {
            returnVal.append(element.dictionary)
        }
        
        return returnVal
    }
    
}

extension Array where Element == trunc_user {
    func formatForFirebase() -> [[String:Any]]{
        var returnVal:[[String:Any]] = []
        for element in self {
            returnVal.append(element.dictionary.value)
        }
        
        return returnVal
    }
    
}

extension Array where Element == UUID {
    func formatForFirebase() -> [String]{
        var returnVal:[String] = []
        for element in self {
            returnVal.append(element.uuidString)
        }
        
        return returnVal
    }
    
    
    
}

extension AVAsset {
    func getVideoDimensions() -> CGSize? {
        guard let track = self.tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return size
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Double {
    var stringWithoutZeroFraction: String {
        return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension GlobalEnvironment {
    
    //The purpose of this function is to sync anything from self.env.unfinishedRecipes to the unfinishedrecipes in UserDefaults. It works by forcing the env value onto UserDefaults
    func sync_unfinishedRecipes(){
        print("syncing unfinished recipes into the UserDefaults")
        let data_dictionary:[String:RecipePost] = self.unfinishedRecipes
        let save_UserDefaults = UserDefaults.standard
        
        do {
            let sessionData = try  NSKeyedArchiver.archivedData(withRootObject: data_dictionary, requiringSecureCoding: false)
            save_UserDefaults.set(sessionData, forKey: UserDefaultKeys.UnfinishedRecipes.rawValue)
            print("saved successfully")
            
        } catch {
            print("couldn't write data")
        }
    }
    
    func load_unfinishedRecipes(completion: ([String:RecipePost]?) -> Void){
        print("first load the unfinished recipes that were previously present")
        if let unfinishedRecipe_objects = UserDefaults.standard.object(forKey: UserDefaultKeys.UnfinishedRecipes.rawValue) as? Data{
            print("ufRP loaded")
            do {
                print("unfinished recipes gathered")
                if let lastSession = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(unfinishedRecipe_objects) as? [String:RecipePost] {
                    print("recipes gathered")
                    
                    completion(lastSession)
//                    if let rememberedUser = lastSession["lastLogin_user"] as? user{
//                        print("logged in successful with remembered user")
//                        println(rememberedUser)
//                        print(rememberedUser.username)
//                        print(rememberedUser.following)
//                        self.env.currentUser = rememberedUser
//                        self.env.initializeListener_currentUser()
//                        self.env.isLoggedIn = true
//                        vc_forLogin = UIHostingController(rootView:
//                            TabbedRootView(NavigationUnit: $env.DeeplinkNavUnit).environmentObject(self.env)
//                                .environment(\   .managedObjectContext, context)
//                        )
//
//                    } else {
//                        print("couldn't unwrap user")
//                        println(lastSession)
//                        println(lastSession["lastLogin_user"] as Any)
//                    }
                    
                } else {
                    completion(nil)
                }
            } catch {
                println("couldn't unwrap data/unfinished recipes")
                completion(nil)
            }
        } else {
            print("couldn't unwrap data/unfinishedRecipe_objects")
            completion(nil)
        }
    }
    
    func save_UserDefaults(){
        let data_dictionary:[String:Any?] = [
            "lastLogin_user":currentUser,
        ]
        let save_UserDefaults = UserDefaults.standard
        
        do {
            let sessionData = try  NSKeyedArchiver.archivedData(withRootObject: data_dictionary, requiringSecureCoding: false)
            save_UserDefaults.set(sessionData, forKey: UserDefaultKeys.LastLoggedInObject.rawValue)
            print("saved successfully")
            
        } catch {
            print("couldn't write file")
        }
    }
    
    
    
    func reset_UserDefaults(){
        let data_dictionary:[String:Any?] = [:]
        let reset_UserDefaults = UserDefaults.standard
        
        do {
            let sessionData = try  NSKeyedArchiver.archivedData(withRootObject: data_dictionary, requiringSecureCoding: false)
            reset_UserDefaults.set(sessionData, forKey: UserDefaultKeys.LastLoggedInObject.rawValue)
            println("reset successfully")
        } catch {
            println("couldn't write file")
        }
    }
    
    func initializeListener_currentUser(){
        print("initializing full user subscription")
        
        fullUserSubscription(currentUser)
        if self.currentUser.id.uuidString == "07964547-C707-4CF3-AB29-29994079B831"
            && subscriptionCatalog.firstIndex(of: "all") == nil{
            subscribeToTopic("all")
        }
        
        
            Firestore.firestore().document("users/\(self.currentUser.id.uuidString)")
            .addSnapshotListener { querySnapshot, error in
                guard let document = querySnapshot else {
                    println("Error fetching documents: \(error!)")
                    return
                }
                
                
                println("new information found with listener", 0)
                println("\(document.documentID) => \(String(describing: document.data()))", 0)
                
                
                println("Saving new information from listener to local environment")
                println("this user's recipes = \(String(describing: document.data()?["publishedRecipes"]))", 0)
                
                
                if let loadedUser_UUID = UUID(uuidString: document.documentID){
                    if let data = document.data() {
                        self.currentUser = data.toUser(formerUUID: loadedUser_UUID)
                        print("updated data: ")
                        print(data.toUser(formerUUID: loadedUser_UUID).dictionary)
                        print(data.toUser(formerUUID: loadedUser_UUID).blocked)
                        
                        

                    
                    println("Saving new information from listener to user defaults")
                    self.save_UserDefaults()
                    } else {
                        print("data could not be optionally unwrapped")
                    }
                } else {
                    let alertView = SPAlertView(title: "Listener Initializer Failed", message: "err: 9asvm 39ska", preset: SPAlertPreset.error)
                    alertView.duration = 3
                    alertView.present()
                }
                
            }
            
        
        
        Firestore.firestore().collection("users/\(self.currentUser.id.uuidString)/publishedRecipes").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            self.currentUser.publishedRecipes = snapshot.documents.map({$0.data().toRecipePost(formerUUID:
                UUID(uuidString: $0.documentID) ?? UUID()
                ).truncForm})
            
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    print("Additions: \(diff.document.data())")
                }
                if (diff.type == .modified) {
                    print("Modifications: \(diff.document.data())")
                }
                if (diff.type == .removed) {
                    print("Removals: \(diff.document.data())")
                }
            }
        }
        Firestore.firestore().collection("users/\(self.currentUser.id.uuidString)/following").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            self.currentUser.following = snapshot.documents.map({$0.data().toUser(formerUUID:
            UUID(uuidString: $0.documentID) ?? UUID()
            ).truncForm})
            
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    print("Additions: \(diff.document.data())")
                }
                if (diff.type == .modified) {
                    print("Modifications: \(diff.document.data())")
                }
                if (diff.type == .removed) {
                    print("Removals: \(diff.document.data())")
                }
            }
        
            print("fol: ",self.currentUser.following)
            if let oldTimestamp = self.NewsFeedResults.timeStamp {
                                   let oldTime_plus15min = oldTimestamp.addingTimeInterval(CacheDuration.Min15.rawValue)
                                   print("now: \(Date().debugDescription)")
                                   print("old + 15: \(oldTime_plus15min.debugDescription)")
                                   if oldTime_plus15min < Date(){
                                       print("hasn't been updated in over 15 minutes")
                                                               self.update_homeView_newsfeed()
                                   } else {
                                       self.update_homeView_newsfeed(forceCommit: false)
                                   }
                               } else {
                                   print("this is the first load")
                                   self.update_homeView_newsfeed()
                               }
            
        
        
        }
        Firestore.firestore().collection("users/\(self.currentUser.id.uuidString)/followers").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            self.currentUser.followers = snapshot.documents.map({$0.data().toUser(formerUUID:
            UUID(uuidString: $0.documentID) ?? UUID()
            ).truncForm})
            
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    print("Additions: \(diff.document.data())")
                }
                if (diff.type == .modified) {
                    print("Modifications: \(diff.document.data())")
                }
                if (diff.type == .removed) {
                    print("Removals: \(diff.document.data())")
                }
            }
        }
        
    }
    func removeListener(forKey: String){
        if let oldValue = listenerCatalog[forKey] {
            oldValue.remove()
            if let removedValue = listenerCatalog.removeValue(forKey: forKey) {
                println("We have just removed '\(removedValue)' from our dictionary")
                
            } else {
                println("Could not remove dictionary item")
            }
        } else {
            println("could not find item at \"\(forKey)\" - \(String(describing: listenerCatalog[forKey]))")
        }
    }
    
    func fullUserSubscription(_ subUser:user, isSelf:Bool = true){
        //Subscribe to this user's new followers
        subscribeToTopic("user_\(subUser.id.uuidString)_followers")
        
        //Subscribe to comments and likes on all their posts
        func subscribe(recipes:[trunc_RecipePost]){
            for recipe in recipes {
                subscribeToTopic("recipe_\(recipe.id.uuidString)_comments")
                subscribeToTopic("recipe_\(recipe.id.uuidString)_likes")
            }
        }
        if let recipes = subUser.publishedRecipes {
            subscribe(recipes: recipes)
        } else {
            print("this user's recipe's weren't present yet. fetching them and subscribing")
            let query = QueryRound(queryType: .order_and_Limit, refString: "users/\(currentUser.id.uuidString)/publishedRecipes", field: "title", QueryWeight: 500, value: 100, expectedReturn: .Recipe, QueryClosure: {results, queryTime in
                
                    let mappedAnys = results.map({$0.any})
                    if let fetchedRecipes = mappedAnys as? [RecipePost] {
                        if isSelf {
                            self.currentUser.publishedRecipes = fetchedRecipes.map{$0.truncForm}
                        }
                        if let recipes = self.currentUser.publishedRecipes {
                            subscribe(recipes: recipes)
                        } else {
                            print("could not unwrap the recipes for the subscription")
                        }
                    } else {
                        print("Could not unwrap the results to recipes for comparison -- \(String(describing: mappedAnys))")
                    }
            })
            DispatchQueue.global(qos: .background).async{
                //Fetch the publishedRecipes collection
                
                DistributeQueryLoads(queryRounds: [query], completion: {results, queryTime in
                    if let closure = query.QueryClosure {
                        closure(results, queryTime)
                    }
                    
                })
                
                
            }
        }
        
        
    }
    
    func fullUserUNSUBscription(_ unsubUser:user, isSelf:Bool = true){
        //Subscribe to this user's new followers
        unsubscribeToTopic("user_\(unsubUser.id.uuidString)_followers")
        
        //Subscribe to comments and likes on all their posts
        func unsubscribe(recipes:[trunc_RecipePost]){
            for recipe in recipes {
                unsubscribeToTopic("recipe_\(recipe.id.uuidString)_comments")
                unsubscribeToTopic("recipe_\(recipe.id.uuidString)_likes")
            }
        }
        if let recipes = unsubUser.publishedRecipes {
            unsubscribe(recipes: recipes)
        } else {
            print("this user's recipe's weren't present yet. fetching them and subscribing")
            let query = QueryRound(queryType: .order_and_Limit, refString: "users/\(currentUser.id.uuidString)/publishedRecipes", field: "title", QueryWeight: 500, value: 100, expectedReturn: .Recipe, QueryClosure: {results, queryTime in
                
                    let mappedAnys = results.map({$0.any})
                    if let fetchedRecipes = mappedAnys as? [RecipePost] {
                        if isSelf {
                            self.currentUser.publishedRecipes = fetchedRecipes.map{$0.truncForm}
                        }
                        if let recipes = self.currentUser.publishedRecipes {
                            unsubscribe(recipes: recipes)
                        } else {
                            print("could not unwrap the recipes for the subscription")
                        }
                    } else {
                        print("Could not unwrap the results to recipes for comparison -- \(String(describing: mappedAnys))")
                    }
            })
            DispatchQueue.global(qos: .background).async{
                //Fetch the publishedRecipes collection
                
                DistributeQueryLoads(queryRounds: [query], completion: {results, queryTime in
                    if let closure = query.QueryClosure {
                        closure(results, queryTime)
                    }
                    
                })
                
                
            }
        }
    }

    func update_homeView_newsfeed(forceCommit:Bool = true, completion: @escaping (Bool)->Void = {_ in }){
        var queryRounds:[QueryRound] = []
        var usersToChunk:[trunc_user] = []
        func runQuery(){
            let chunkedUsers = usersToChunk.chunked(by: 10)
            for chunk in chunkedUsers{
                println(chunk)
                let ids = chunk.map{$0.id.uuidString}
                queryRounds.append(
                    QueryRound(queryType: .In, refString: "recipe", field: "postingUser.id", QueryWeight: 500, value: ids, expectedReturn: .Recipe, filters: [
                        QueryFilter(
                            queryFilterType: .order_and_Limit,
                            field: "dateCreate",
                            filterArgument: 100
                        )
                    ])
                )
            }
            println("query rounds formed - executing DistributeQueryLoads", 0)
            DistributeQueryLoads(queryRounds: queryRounds, completion: {results, queryTime in
                println("finished searching for home results")
                if let results = results.toRecipeResults(){
                    let sortedResults = results.sorted{ $0.dateCreate > $1.dateCreate}
                println("results of home page initial query")
                for result in sortedResults {
                        println(result.likes.formatForFirebase())
                }
                
                func commit(){
                    if let old_timeStamp = self.NewsFeedResults.timeStamp {
                        if queryTime > old_timeStamp {
                            self.NewsFeedResults = RecipeResults(results: sortedResults, timeStamp: queryTime)
                            completion(true)
                            
                        }
                    } else {
                        
                        self.NewsFeedResults = RecipeResults(results: sortedResults, timeStamp: queryTime)
                        completion(true)
                        print("this is the first time we are commiting results to the page")
                        print(self.NewsFeedResults.results)
                    }
                }
                
                //If force committing is true this means that regardless of whether or not the fetch is different from the current results we have, we want to update the local info with the fetched info. In contrast, when force committing is false, we're only going to update the UI if something has changed
                if !forceCommit {
                    
//                    let op_fetched = sortedResults.map{$0.any} as? [RecipePost]
//                    let op_local = self.NewsFeedResults.results.map{$0.any} as? [RecipePost]
                    
                        let string_local = self.NewsFeedResults.results.map{$0.id.uuidString}
                        let string_fetched = sortedResults.map{$0.id.uuidString}
                        if string_local != string_fetched {
                            
                            print("newsfeed has changed - commiting with the fetched results")
                            commit()
                        } else {
                            print("newsfeed has not changed - not committing")
                            completion(false)
                        }
                    
                } else {
                    commit()
                }
            }
            })
        }
        
        print("user is following: ", self.currentUser.following!.map({$0.id}))
        if let following = self.currentUser.following {
            usersToChunk = following + [self.currentUser.truncForm]
            runQuery()
        } else {
            let query = QueryRound(queryType: .order_and_Limit, refString: "users/\(self.currentUser.id.uuidString)/following", field: "name", QueryWeight: 500, value: 100, expectedReturn: .User, QueryClosure: {results, queryTime in
                
                let mappedAnys = results.map({$0.any})
                if let fetchedUsers = mappedAnys as? [user] {
                    
                    self.currentUser.following = fetchedUsers.map{$0.truncForm}
                    
                    if let following = self.currentUser.following {
                        usersToChunk = following + [self.currentUser.truncForm]
                        runQuery()
                    } else {
                        print("could not unwrap the following for the query")
                    }
                } else {
                    print("Could not unwrap the following to any for query -- \(String(describing: mappedAnys))")
                }
            })
            DispatchQueue.global(qos: .background).async{
                //Fetch the publishedRecipes collection
                
                DistributeQueryLoads(queryRounds: [query], completion: {results, queryTime in
                    if let closure = query.QueryClosure {
                        closure(results, queryTime)
                    }
                    
                })
                
                
            }
        }
        
        
        
    }
    
    func signOut(){
        self.isLoggedIn = false
        self.fullUserUNSUBscription(self.currentUser)
        self.removeListener(forKey: "self")
        self.reset_UserDefaults()
        self.NewsFeedResults = RecipeResults(results: [], timeStamp: nil)
        
    }
    
}

extension Optional where Wrapped == Data {
    func imageUnwrap() -> UIImage?{
        if let data = self {
            if let uiimage = UIImage(data: data) {
                return uiimage
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

extension String {
    var alphanumerics_andWhiteSpace: String {
        return String(unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.union(CharacterSet.alphanumerics).contains))
    }
    
    var alphanumerics: String {
        return String(unicodeScalars.filter(CharacterSet.alphanumerics.contains))
    }
    
    var passwordAllower:String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet.init(charactersIn:  ("!@#$%&")))
        return String(unicodeScalars.filter(allowed.contains))
//        allowed.formUnion(.lowercaseLetters)
//    allowed.formUnion(.uppercaseLetters)
//    allowed.formUnion(.decimalDigits)
//    allowed.insert(charactersIn: "!@#$%&")
    }
    
    func lastChar_next() -> String?{
        
        let letters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","a"]
        if let last = self.last{
            if let i = letters.firstIndex(of: last.description){
                return self.dropLast() + letters[i + 1]
            } else {
                return nil
            }
        } else {
            return nil
        }
        
    }
}

extension Dictionary where Key == String, Value:Any {
    func toRecipePost(formerUUID:UUID?) -> RecipePost {
        return RecipePost(
            id: formerUUID ?? UUID(),
            title: self["title"] as? String ?? "Title Error",
            subtitle: self["subtitle"] as? String ?? "Subtitle Error",
            steps: self["steps"] as? [[String:Any]] ?? [],
            ingredients: self["ingredients"] as? [[String:Any]] ?? [],
            postingUser: self["postingUser"] as? [String:Any] ?? [:],
            likes: self["likes"] as? [Any] ?? [],
            dateCreate: self["dateCreate"] as? String ?? "",
            tags: self["tags"] as? [String] ?? [],
            timePrep: self["timePrep"] as? Int ?? 0,
            timeCook: self["timeCook"] as? Int ?? 0,
            timeOther: self["timeOther"] as? Int ?? 0,
            estimatedServings: self["estimatedServings"] as? String ?? "",
            flagged: self["flagged"] as? Bool ?? false,
            isFeatureEligible: self["isFeatureEligible"] as? Bool ?? true
        )
    }
    
    func toUser(formerUUID:UUID?) -> user {
        return user.init(id: formerUUID ?? UUID(),
                         username: self["username"] as? String ?? "",
                         password: self["password"] as? String ?? "",
                         name: self["name"] as? String ?? "",
                         email: self["email"] as? String ?? "",
                         publishedRecipes: self["publishedRecipes"] as? [Any] ?? nil,
                         following: self["following"] as? [[String:Any]] ?? nil,
                         followers: self["followers"] as? [[String:Any]] ?? nil,
                         quantity_followers: self["quantity_followers"] as? Int ?? 0,
                         quantity_following: self["quantity_following"] as? Int ?? 0,
                         bio: self["bio"] as? String ?? "",
                         verified: self["verified"] as? Bool ?? false,
                         likes: self["likes"] as? [Any] ?? [],
                         blocked: self["blocked"] as? [Any] ?? [],
                         blockedBy: self["blockedBy"] as? [Any] ?? [],
                         firstTimeUser: self["firstTimeUser"] as? Bool ?? false,
                         referralCode_distributal: self["referralCode_distributal"] as? String ?? "",
                         referralCode_claimed: self["referralCode_claimed"] as? String ?? "",
                         flagged: self["flagged"] as? Bool ?? false,
                         hiddenContent: self["hiddenContent"] as? [String] ?? [],
                         isAdmin: self["isAdmin"] as? Bool ?? false
        )
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension UIImage {
    
    
    func aspectRatio() -> CGFloat {
        let thisAR = CGFloat(self.cgImage!.width)/CGFloat(self.cgImage!.height)
        print("thisAR: \(thisAR)")
        return (thisAR)
    }
    
    func isWiderThanTall() -> Bool {
        if let CG = self.cgImage {
            print("W: \(CG.width) || H: \(CG.height)")
            if self.cgImage!.width > self.cgImage!.height {
                return true
            } else {
                return false
            }
        } else {
            print("could not unwrap underlying CGImage")
            return false
        }
    }
    
    func sanitize_AR() -> UIImage {
        let width = self.size.width
        let height = self.size.height
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    // MARK: - UIImage+Resize
    func compressTo(_ expectedSizeInMb:Int) -> Data? {
        let sizeInBytes = expectedSizeInMb * 1024 * 1024
        var needCompress:Bool = true
        var imgData:Data?
        var compressingValue:CGFloat = 1.0
        while (needCompress && compressingValue > 0.0) {
            
            if let data:Data = self.jpegData(compressionQuality: compressingValue) {
            if data.count < sizeInBytes {
                
                println("image right size @\(compressingValue)")
                needCompress = false
                imgData = data
            } else {
                println("image too large @\(compressingValue)")
                compressingValue -= 0.1
                
            }
        }
    }

    if let data = imgData {
        if (data.count < sizeInBytes) {
            return data
        }
    }
        return self.jpegData(compressionQuality: 1)
        
    }
    
}

extension UITabBarController{
    override open func viewDidLoad() {
//        let standardAppearance = UITabBarAppearance()
        
//        tabBar.isHidden = true
    }
}

extension URL {
    subscript(queryParam:String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParam })?.value
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
