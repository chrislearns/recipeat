//
//  HomeView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 3/2/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import FirebaseFirestore
import Firebase

struct HomeView: View {
    
    @EnvironmentObject var env: GlobalEnvironment
    var developing = true
    @State var NavigationUnit = HashableNavigationUnit()
    @State var innerProxy:CGFloat = 0
    @State var outerProxy:CGFloat = 0
    @State var refreshing = false
    @State var animateLoader = false
    @Binding var newsFeedRecipes:[RecipePost]
    var body: some View {
        ZStack{
            Color.init(white: 247/255)
            
//                .opacity(Double(get_refreshOpacity()))
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
            NavigationLink(
                destination: RecipePostView(isShown_selection: self.$NavigationUnit.navigationSelector, RP_String: NavigationUnit.navigationContext as? String ?? "")
                           , tag: NavigationDestination.RecipePostView.hashValue, selection: self.$NavigationUnit.navigationSelector){
                EmptyView()
            }
            //This means wehavetried to grab something for this user but they have nothing to show
            if self.newsFeedRecipes.count > 0 {
                VStack{
                    HStack{
                        Image(systemName: "heart.circle")
                            .font(.system(size: 26))
                            .foregroundColor(Color.init(white: 0.75))
                        Spacer()
//                        Text("\(innerProxy)")
                        Image("recipeat_logo_v2")
                            .resizable().scaledToFit()
                            .padding(7)
                            .frame(height: 40)
                        Spacer()
                        Image(systemName: "envelope.circle")
                            .font(.system(size: 26))
                            .foregroundColor(Color.init(white: 0.75))
                    }.clipped()
                    .padding(.horizontal)
                    .background(Color.init(white: 247/255))
                    ZStack{
                        VStack(spacing:0){
                            GeometryReader{geo -> AnyView in
                            DispatchQueue.main.async{
                                outerProxy = geo.frame(in: .global).minY
                            }
                            return AnyView(EmptyView())
                        }.background(Color.blue).frame(height:0)
                            HStack{
                                if !refreshing{
                                    Text("REFRESHING")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.init(white: 0))
                                        .opacity(-(outerProxy - (innerProxy))/60 < 0 ? 0 : -(Double(outerProxy - (innerProxy)))/80)
                                        .animation(.linear)
                                } else {
                                    PullDownAnimationView()
                                        .animation(.easeInOut(duration: 0.2))
                                    
                                }
                            }
                            .frame(width: UniversalSquare.width, height: refreshing ? 80 : limited_refreshDrag())
                            
                            .animation(.easeInOut(duration: 0.2))
                            Spacer()
                            
                        }
                            ScrollView(showsIndicators: false){
                        VStack(spacing:0){
                            GeometryReader{geo -> AnyView in
                                DispatchQueue.main.async{
                                    
                                    innerProxy = geo.frame(in: .global).minY
                                    if limited_refreshDrag() >= 80 && !refreshing {
                                        print("refreshing initiated")
                                        withAnimation {
                                            refreshing = true
                                            self.env.update_homeView_newsfeed(forceCommit: true, completion: {val in
                                                print("update completed: \(val)")
                                                
                                                    print("all rps")
                                                    print(self.newsFeedRecipes.map({$0.title}))
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    withAnimation {
                                                        refreshing = false
                                                        animateLoader = false
                                                    }
                                                }
                                                
                                                
                                            })
                                        }
                                        
                                        
                                        
                                    }
                                }
                                return AnyView(EmptyView())
                            }.background(Color.blue).frame(height:0)
                            if refreshing{
                                VStack{
                                    Spacer()
                                        
                                        .frame(height: 40)
                                        .offset(x: animateLoader ? 80 + (UniversalSquare.width/2) : -80 - (UniversalSquare.width/2))
                                        
                                        .animation(
                                            Animation
                                                .easeOut(duration: 1.5)
                                                .delay(1)
                                                .repeatForever(autoreverses: false))
                                        .onAppear{
                                            animateLoader = true
                                        }
                                }.frame(height: limited_refreshDrag() >= 80 ? 0 : 80)
                                    .onAppear(perform: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                            withAnimation {
//                                                refreshing = false
//                                                animateLoader = false
                                            }
                                        }
                                    })
                            }
                        LazyVStack(spacing:0){
                            
                            ForEach(0..<self.newsFeedRecipes.count
//                                        .filter({
//                                rp in
//                                let comparableString = "\(RecipeatEntity.Recipe.minimized()).\(rp.id.uuidString)"
//                                return self.env.currentUser.hiddenContent.first(where: {$0 == comparableString}) == nil
//                            }).chunked(by: 20)[0]
                            ){i in
                                if self.env.currentUser.hiddenContent.first(where: {$0 ==
                                    "\(RecipeatEntity.Recipe.minimized()).\(self.newsFeedRecipes[i].id.uuidString)"
                                }) == nil {
                                VStack{
                                    //                                            Text(thisRP.dateCreateString)
                                    PostView(profileClosure: {
                                        self.NavigationUnit.navigationContext = self.newsFeedRecipes[i].postingUser.id.uuidString
                                        self.NavigationUnit.navigationSelector = NavigationDestination.UserHomeView.hashValue
                                        println("navigating to profile")
                                        
                                    },
                                    recipeClosure: {
                                        println("navigating to recipe")
                                        self.NavigationUnit.navigationContext = self.newsFeedRecipes[i].id.uuidString
                                        self.NavigationUnit.navigationSelector = NavigationDestination.RecipePostView.hashValue
                                    },
                                    this_truncRP: self.$newsFeedRecipes[i].truncked,
                                    this_truncUser: self.newsFeedRecipes[i].postingUser)
                                    
                                }
                                }
                                
                                
                            }
                            Spacer().frame(height: self.env.tabBarHeight)
                        }
                        }
                    }.background(Color.clear)
                        
                    }
                }
            } else {
                Color.white
                if self.env.NewsFeedResults.timeStamp == nil {
                    
                    ScrollView{
                        VStack(spacing:0){
                            ForEach(0..<3){ i -> AnyView in
                                return AnyView(
                                    VStack{
                                        PostView(profileClosure: {},
                                                 recipeClosure: {},
                                                 this_truncRP: .constant(RecipePost().truncForm),
                                                 this_truncUser: user().truncForm)
                                    }
                                )
                            }
                        }
                    }.background(Color.clear)
                } else {
                    ScrollView{
                        VStack{
                            Image("discoverLove")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width:80, height:80)
                                .padding(.top, 20)
                            Text(self.env.NewsFeedResults.timeStamp == nil ? "JUST A MINUTE" : "YOU MADE IT")
                                .font(.system(size: 20, weight: .semibold))
                            Text(self.env.NewsFeedResults.timeStamp == nil ? "We're finding you things you'll love!" : "Let's find some things you'll love!")
                                .frame(width: UniversalSquare.width - 100)
                                .multilineTextAlignment(.center)
                            Spacer().frame(height:40)
                            //This means we search for something for you and there was still nothing
                            if self.env.NewsFeedResults.timeStamp != nil {
                                ExploreView()
                            }
                            Spacer().frame(height: self.env.tabBarHeight)
                            
                            
                        }.foregroundColor(Color.init(white: 0.8)).frame(width: UniversalSquare.width)
                    }
                }
                
                
                
            }

        }
        
//            .navigationBarTitle("Home", displayMode: .inline)
//        .navigationBarHidden(true)
            
    }
    
    func get_refreshOpacity() -> CGFloat {
        if refreshing {
            return 1
        } else {
            return limited_refreshDrag()/80
        }
    }
    
    func limited_refreshDrag() -> CGFloat {
        let val =  -(outerProxy - (innerProxy))
        if val < 0 {
            return 0
        } else if val > 80 {
            return 80
        } else {
            return val
        }
    }
    
    
    
}
//
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()\
//    }
//}

func executeMigrations(){
    let query = QueryRound(queryType: .order_and_Limit, refString: "users", field: "name", QueryWeight: 500, value: 200, expectedReturn: .User, QueryClosure: {results, queryTime in
        
        let mappedAnys = results.map({$0.any})
        if let fetchedUsers = mappedAnys as? [user] {
            print("fetched users - \(fetchedUsers.map{$0.username})")
            print("fetched users - \(fetchedUsers.filter({$0.following?.count != nil}).filter({$0.following!.count > 0}).map{$0.following})")
            //                1. for each set of followers need to grab their full self and upload them into the subcollection
            //                for thisUser in fetchedUsers {
            //                    if let followers = thisUser.followers {
            //                        print("followers: \(followers.count)")
            //
            //                        for follower in followers {
            //                            DistributeQueryLoads(queryRounds: [QueryRound(queryType: .isEqualTo, refString: "users", field: "id", QueryWeight: 500, value: follower.id.uuidString, expectedReturn: .User)], completion: {results, queryTime in
            //                                if results.count > 1 {
            //                                    print("Somthing went wrong - found more than one user with the id of \(follower.id.uuidString)")
            //                                } else {
            //                                    if let thisFollower = results.first?.any as? user {
            //                                        print("found the follower")
            //                                        print("\(thisFollower.dictionary)")
            //                                        firestoreSubmit_data(docRef_string: "users/\(thisUser.id.uuidString)/followers/\(follower.id.uuidString)", dataToSave: thisFollower.dictionary.value, completion: {outcome in print(outcome)})
            //                                    } else {print("something went wrong -- ", results.first as Any)}
            //                                }
            //                            })
            //                        }
            //                    }
            //                }
            
            //2. for each set of following need to grab their full self and upload them into the subcollection
            //                for thisUser in fetchedUsers {
            //                    if let followings = thisUser.following {
            //                        print("following: \(followings.count)")
            //
            //                        for following in followings {
            //                            DistributeQueryLoads(queryRounds: [QueryRound(queryType: .isEqualTo, refString: "users", field: "id", QueryWeight: 500, value: following.id.uuidString, expectedReturn: .User)], completion: {results, queryTime in
            //                                if results.count > 1 {
            //                                    print("Somthing went wrong - found more than one user with the id of \(following.id.uuidString)")
            //                                } else {
            //                                    if let thisFollowing = results.first?.any as? user {
            //                                        print("found the following")
            //                                        print("\(thisFollowing.dictionary)")
            //                                        firestoreSubmit_data(docRef_string: "users/\(thisUser.id.uuidString)/following/\(following.id.uuidString)", dataToSave: thisFollowing.dictionary.value, completion: {outcome in print(outcome)})
            //                                    } else {print("something went wrong -- ", results.first as Any)}
            //                                }
            //                            })
            //                        }
            //                    }
            //                }
            
            //3. for each set of pubkished recipes need to grab their full self and upload them into the subcollection
            //                for thisUser in fetchedUsers {
            //
            //                    if let pubRPs = thisUser.publishedRecipes {
            //                        print("RPs: \(pubRPs.count)")
            //
            //                        for pubRP in pubRPs {
            //                            DistributeQueryLoads(queryRounds: [QueryRound(queryType: .isEqualTo, refString: "recipe", field: "id", QueryWeight: 500, value: pubRP.id.uuidString, expectedReturn: .Recipe)], completion: {results, queryTime in
            //                                if results.count > 1 {
            //                                    print("Somthing went wrong - found more than one RP with the id of \(pubRP.id.uuidString)")
            //                                } else {
            //                                    if let thisPubRP = results.first?.any as? RecipePost {
            //                                        print("found the RP")
            //                                        print("\(thisPubRP.dictionary)")
            //                                        firestoreSubmit_data(docRef_string: "users/\(thisUser.id.uuidString)/publishedRecipes/\(thisPubRP.id.uuidString)", dataToSave: thisPubRP.dictionary, completion: {outcome in print(outcome)})
            //                                    } else {print("something went wrong -- ", results.first as Any)}
            //                                }
            //                            })
            //                        }
            //                    }
            //
            //                }
            //4. Delete the FieldValues for the old form of the above fields
            //                for thisUser in fetchedUsers {
            //                    if thisUser.username == "watchkiraeat"{
            //                    let docRef = Firestore.firestore().document("users/\(thisUser.id.uuidString)")
            //                    println("removing all values in deprecated format")
            //                    docRef.updateData([
            //                        "followers": FieldValue.delete(),
            //                        "following": FieldValue.delete(),
            //                        "publishedRecipes": FieldValue.delete()
            //                        ], completion: {(error) in
            //                            if let error = error {
            //                                println("err: 546rt sdfhs = \(error)", 0)
            //
            //                            } else {
            //                                println("old data deleted successfully", 0)
            //                            }
            //                    })
            //                    }
            //                }
            
            
        } else {
            print("Could not unwrap the results to user for deletion portion of migration -- \(String(describing: mappedAnys))")
        }
    })
    
    DistributeQueryLoads(queryRounds: [query], completion: {results, queryTime in
        if let closure = query.QueryClosure {
            closure(results, queryTime)
        }
    })
}

