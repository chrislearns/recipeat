//Follower Icons from <div>Icons made by <a href="https://www.flaticon.com/authors/freepik" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a></div>

//
//  UserView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 3/2/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseStorage
import SPAlert

enum DisplayType {
    case grid, list
}

struct UserView: View {
    
    
    
    @State var contentPriorityMode:ContentPriority = .recent
    @State var displayMode:DisplayType = .grid
    @EnvironmentObject var env: GlobalEnvironment
    
//    @State var showActionSheet = false
//    @State var showReporting = false
    
    //These variables indicate what will be passed forward and which type of navigation to use
    @State var NavigationUnit = HashableNavigationUnit()
    @State var user_forPage:user? = nil
    @State var user_forPage_string:String
    
          
    @State var changed:Int32 = 0
    var body: some View {
        //        NavigationView{
        
        ZStack{
            NavigationLink(destination: RecipePostView(isShown_selection: self.$NavigationUnit.navigationSelector, RP_String: NavigationUnit.navigationContext as? String ?? ""), tag: NavigationDestination.RecipePostView.hashValue, selection: self.$NavigationUnit.navigationSelector){
                EmptyView()
            }
            
            NavigationLink(destination: ListUserView(userList: (NavigationUnit.navigationContext as? [trunc_user]) ?? []), tag: NavigationDestination.ListUser.hashValue, selection: self.$NavigationUnit.navigationSelector){
                EmptyView()
            }
            
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
            
            ScrollView{
                
                //Spacer().frame(height: UniversalSafeOffsets?.top)
                VStack(spacing:0){
                    Spacer().frame(height: 10)
                    UserView_Heading(user_forPage: $user_forPage, changed: $changed, sheetDestination: NavigationDestination.ImagePickerView.rawValue, reloadClosure: {self.completeUser()}, NavigationUnit: $NavigationUnit)
                        
                        .zIndex(2)
                    
                    
                    
                    
                    HStack{
                        Button(action: {
                            self.displayMode = DisplayType.grid
                        }){
                            Image(systemName: "circle.grid.3x3")
                                .padding(7)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(displayMode == .grid ? lightGreen : .init(white: 0.8))
                                .padding(10)
                                .shadow(radius: 0)
                        }
                        Button(action: {
                            self.displayMode = DisplayType.list
                        }){
                            Image(systemName: "list.dash")
                                .padding(7)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(displayMode == .list ? lightGreen : .init(white: 0.8))
                                .padding(EdgeInsets.init(top: 10, leading: 10, bottom: 10, trailing: 0))
                                .shadow(radius: 0)
                        }
                        
                        Rectangle().frame(width:1, height: 30).foregroundColor(.init(white: 0.8))
                        
                        Button(action: {
                            self.contentPriorityMode = .recent
                        }){
                            Text("NEWEST")
                                .fontWeight(.semibold)
                                .font(.system(size: 14))
                                .foregroundColor(self.contentPriorityMode == .recent ? lightGreen : .init(white: 0.8))
                                .animation(.easeInOut(duration: 1))
                                .padding(10)
                                .shadow(radius: 0)
                        }
                        
                                                Button(action: {
                                                    self.contentPriorityMode = .popular
                                                }){
                                                    Text("POPULAR")
                                                        .fontWeight(.semibold)
                                                        .font(.system(size: 14))
                                                        .foregroundColor(self.contentPriorityMode == .popular ? lightGreen : .init(white: 0.8))
                                                        .animation(.easeInOut(duration: 1))
                                                        .padding(10)
                                                        .shadow(radius: 0)
                                                }
                        
                        Spacer()
                    }
                    .background(Color.white)
                    .zIndex(1)
                    .overlay(Rectangle().stroke(lineWidth: 1).foregroundColor(Color.init(white:0.9)))
                    
                    
                    if user_forPage != nil {
                        if user_forPage?.publishedRecipes != nil{
                            if user_forPage!.publishedRecipes!.count < 1 {
                                VStack{
                                    Image("closedBook")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                    
                                    
                                    Text((user_forPage!.username == self.env.currentUser.username ? "Get started by creating your first recipe!" : "This user has no recipes."))
                                        .multilineTextAlignment(.center)
                                }
                                .foregroundColor(Color.init(white: 0.8))
                                .padding(.top, 80)
                                .padding(.horizontal, 80)
                                
                                
                            } else {
                                if displayMode == .grid {
                                    if user_forPage?.publishedRecipes != nil {
                                        LazyVGrid(columns: [
                                                    GridItem(.flexible(minimum: 0, maximum: UniversalSquare.width/3)),//
                                            GridItem(.fixed((UniversalSquare.width/3))),
                                            GridItem(.flexible(minimum: 0, maximum: UniversalSquare.width/3))
                                            
                                        ], spacing: 4){
                                            ForEach(user_forPage!.publishedRecipes!.sorted(by: {
                                                if contentPriorityMode == ContentPriority.recent{
                                                    return $1.dateCreate > $0.dateCreate
                                                } else if contentPriorityMode == ContentPriority.popular{
                                                    return $1.likes.count > $0.likes.count
                                                } else {
                                                    return $1.dateCreate > $0.dateCreate
                                                }
                                            }).reversed()){thisContent in
                                                    ZStack{
                                                        Image(uiImage: (thisContent.imageDict[ThumbnailSizes.s128] == nil ? UIImage(named: "loader_border") : thisContent.imageDict[ThumbnailSizes.s128])!)
                                                            
                                                        .resizable()
                                                        .scaledToFill()
                                                            .frame(width: (UniversalSquare.width/3), height: (UIScreen.main.bounds.width/3))
                                                            .clipped()
                                                            .opacity(thisContent.imageDict[ThumbnailSizes.s128] == nil ? 0.3 : 1)
                                                            .background(Color.init(white: 247/255))
                                                            .onAppear(){
                                                                let imageString = "recipe/\(thisContent.id.uuidString)/img0"
                                                                
                                                                loadImage_cache_FireStore(imageString: imageString, resized: .s128, minimumRecency: CacheDuration.Day10, completion: {
                                                                    imageData in
                                                                    if let imageData = imageData {
                                                                        if let i = user_forPage?.publishedRecipes?.firstIndex(where: {$0.id == thisContent.id}){
                                                                            user_forPage?.publishedRecipes![i].imageDict[ThumbnailSizes.s128] = UIImage(data: imageData)!
                                                                        }
                                                                        
                                                                    } else {
                                                                        print("couldn't grab image")
                                                                    }
                                                                })
                                                            }
                                                        Button(action: {
                                                            self.NavigationUnit.navigationContext = thisContent.id.uuidString
                                                                                                        self.NavigationUnit.navigationSelector = NavigationDestination.RecipePostView.hashValue
                                                        }){
                                                            Image("square")
                                                        .resizable()
                                                        .scaledToFill()
                                                            .frame(width: UIScreen.main.bounds.width/3, height: UIScreen.main.bounds.width/3)
                                                            .clipped()
                                                                .opacity(0.0000001)
                                                                
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                                Spacer()
                                            
                                        }.background(Color.clear).frame(width: UniversalSquare.width)
                                    }
                                    

                                } else {
                                    ForEach(user_forPage!.publishedRecipes!.sorted(by: {
                                        if contentPriorityMode == ContentPriority.recent{
                                            return $1.dateCreate > $0.dateCreate
                                        } else if contentPriorityMode == ContentPriority.popular{
                                            return $1.likes.count > $0.likes.count
                                        } else {
                                            return $1.dateCreate > $0.dateCreate
                                        }
                                    }).reversed()){tRecip in
                                        
                                        PostView(profileClosure: {
                                            self.NavigationUnit.navigationContext = self.user_forPage!
                                            self.NavigationUnit.navigationSelector = NavigationDestination.UserHomeView.hashValue
                                            print("navigating to profile")
                                            
                                        }, recipeClosure: {
                                            print("navigating to recipe")
                                            self.NavigationUnit.navigationContext = tRecip.id.uuidString
                                            self.NavigationUnit.navigationSelector = NavigationDestination.RecipePostView.hashValue
                                        }, this_truncRP: .constant(tRecip),
                                        this_truncUser:self.user_forPage!.truncForm)
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                    //                    Spacer().frame(height: UniversalSafeOffsets?.bottom).background(Color.init(white: 1))
                    
                }
                
            }
            .frame(width: UniversalSquare.width)
            
        }.onAppear(){
            //NOTE - originally i had this to make sure we loaded the user if we didnt have them. now we reolad them no matter what
            //            if let uw_user = self.user_forPage {
            //                print("full user() passed successfully - displaying \(uw_user.username) ")
            //                print(self.user_forPage?.fireBaseFormat as Any)
            //
            //            } else {
            //
            //            }
            self.refreshUser()
            self.changed = Int32.random(in: 0...1000000)
        }
        
//        .sheet(isPresented: $showReporting){
//            ReportView(isShown: self.$showReporting, report_correspondingEntityType: RecipeatEntity.User, report_correspondingEntityID: self.user_forPage?.id ?? UUID(), report_reportingUser: self.env.currentUser.truncForm,
//                       report_entityPath: "users/\(self.user_forPage!.id)",
//                       closureAfterSubmit: {
//                                                    let alertView = SPAlertView(title: "Violation Reported", message: "Thank you for keeping our community safe. Your report has been submitted successfully", preset: SPAlertPreset.done)
//                                                    alertView.duration = 3
//                                                    alertView.present()
//            }
//                       )
//        }
    
//            .navigationBarTitle(Text(user_forPage != nil ? (user_forPage!.username == self.env.currentUser.username ? "Me" : user_forPage!.username): "..."), displayMode: .inline)
//            .navigationBarItems(trailing:
//                VStack{
//                    if user_forPage != nil {
//                        if user_forPage!.username == self.env.currentUser.username {
//                            Button(action: {
//                                withAnimation(.easeInOut(duration: 0.3)) {
//                                    self.show_accountMenu = true
//                                }
//                            }) {
//                                Image(systemName: "text.justify").imageScale(.large).padding()
//                                    .foregroundColor(Color.black)
//                            }
//                        } else {
//                            Button(action: {
//                                withAnimation(.easeInOut(duration: 0.3)) {
//                                    self.showActionSheet = true
//                                }
//                            }) {
//                                Image(systemName: "ellipsis").imageScale(.large).padding()
//                                    .foregroundColor(Color.black)
//                            }
//                        }
//                    } else {
//                        EmptyView()
//                    }
//                }
//        )
        
        
        //        }
    }
    
    func refreshUser(){
        DispatchQueue.global(qos: .background).async{
            print("no user() passed - fetching from string \(self.user_forPage_string)")
            firestoreRetrieve_document(docRef_string: "users/\(self.user_forPage_string)", completion: {outcome, returnData in
                if outcome == .success {
                    if let document = returnData as? DocumentSnapshot {
                        
                        
                        if let loadedUser_UUID = UUID(uuidString: document.documentID){
                            if let fetched_user = document.data()?.toUser(formerUUID: loadedUser_UUID) {
                                print("user recipes")
                                //                            print(document.data()?["publishedRecipes"] as? [Any])
                                if let uw_user = self.user_forPage {
                                    if uw_user.bio == fetched_user.bio &&
                                        uw_user.username == fetched_user.username &&
                                        uw_user.name == fetched_user.name
                                    {
                                        print("general piecesare identical - no need to make any changes here")
                                        self.completeUser()
                                    } else {
                                        self.user_forPage = fetched_user
                                        self.completeUser()
                                        print("updated user is unique - updating")
                                    }
                                } else {
                                    self.user_forPage = fetched_user
                                    self.completeUser()
                                    
                                    print("user had no initial value - updating")
                                }
                            } else {
                                print("could not unwrap the user from the document data")
                            }
                        } else {
                            let alertView = SPAlertView(title: "Failed to fetch user", message: "err: 3fw9w vsdfk", preset: SPAlertPreset.error)
                            alertView.duration = 3
                            alertView.present()
                        }
                        
                        
                        
                        
                    } else {
                        print("could not cast to [String:Any] --> \(returnData)")
                    }
                    print("\(returnData)")
                } else if outcome == .failed {
                    print("failed to fetch recipe - \(returnData)")
                    let alertView = SPAlertView(title: "Couldn't Fetch Recipe - \(self.user_forPage_string)", message: "err: ass8w g472j", preset: SPAlertPreset.error)
                    alertView.duration = 3
                    alertView.present()
                }
            })
        }
        
        
    }
    
    func completeUser(){
        var modifiableUser = user_forPage
        var tasksToComplete = 3
        func checkComplete(){
            print("checking completion...")
            if tasksToComplete == 0 {
                print("updating user with modifiable user because tasksToComplete = \(tasksToComplete)")
                self.user_forPage = modifiableUser
            } else {
                print("cannot update user - still must complete \(tasksToComplete) tasks")
            }
            
            self.changed = Int32.random(in: 0...1000000)
        }
        let queries = [
            QueryRound(queryType: .order_and_Limit, refString: "users/\(self.user_forPage_string)/publishedRecipes", field: "title", QueryWeight: 500, value: 100, expectedReturn: .Recipe, QueryClosure: {results, queryTime in
                
                let mappedAnys = results.map({$0.any})
                if let fetchedRecipes = mappedAnys as? [RecipePost] {
                    if let localRecipes = self.user_forPage?.publishedRecipes {
                        let localUUIDs = localRecipes.map{$0.id.uuidString}
                        let fetchedUUIDs = fetchedRecipes.map{$0.id.uuidString}
                        
                        let localDates = localRecipes.map{$0.dateCreate}
                        let fetchedDates = fetchedRecipes.map{$0.dateCreate}
                        
                        let localLikes = localRecipes.map{$0.likes.count}
                        let fetchedLikes = fetchedRecipes.map{$0.likes.count}
                        
                        print("localDates", localDates)
                        print("fetchedDates", fetchedDates)
                        if localUUIDs.sorted(by: {$0 > $1}) == fetchedUUIDs.sorted(by: {$0 > $1})
                            && localLikes.sorted(by: {$0 > $1}) == fetchedLikes.sorted(by: {$0 > $1})
                            && localDates.sorted(by: {$0 > $1}) == fetchedDates.sorted(by: {$0 > $1}){
                            
                            print("No changes in the published recipes - no need to update")
                            modifiableUser!.publishedRecipes = localRecipes.sorted(by: {$0.dateCreate < $1.dateCreate})
                            tasksToComplete = tasksToComplete - 1
                            checkComplete()
                            
                        } else {
                            if let _ = self.user_forPage{
                                modifiableUser!.publishedRecipes = fetchedRecipes.map{$0.truncForm}.sorted(by: {$0.dateCreate < $1.dateCreate})
                                tasksToComplete = tasksToComplete - 1
                                checkComplete()
                                
                                
                            }
                        }
                        
                    } else {
                        print("Could not unwrap the local recipes for comparison -- \(String(describing: self.user_forPage?.publishedRecipes))")
                        modifiableUser!.publishedRecipes = fetchedRecipes.map{$0.truncForm}.sorted(by: {$0.dateCreate < $1.dateCreate})
                        tasksToComplete = tasksToComplete - 1
                        checkComplete()
                        
                    }
                    
                } else {
                    print("Could not unwrap the results to recipes for comparison -- \(String(describing: mappedAnys))")
                }
            }),
            QueryRound(queryType: .order_and_Limit, refString: "users/\(self.user_forPage_string)/followers", field: "name", QueryWeight: 500, value: 100, expectedReturn: .User, QueryClosure: {results, queryTime in
                
                let mappedAnys = results.map({$0.any})
                if let fetchedFollowers = mappedAnys as? [user] {
                    if let localFollowers = self.user_forPage?.followers {
                        let localUUIDs = localFollowers.map{$0.id.uuidString}
                        let fetchedUUIDs = fetchedFollowers.map{$0.id.uuidString}
                        
                        if localUUIDs.sorted(by: {$0 > $1}) == fetchedUUIDs.sorted(by: {$0 > $1})
                        {
                            print("No changes in the followers - no need to update")
                            modifiableUser!.followers = localFollowers.sorted(by: {$0.name < $1.name})
                            tasksToComplete = tasksToComplete - 1
                            checkComplete()
                        } else {
                            if let _ = self.user_forPage{
                                modifiableUser!.followers = fetchedFollowers.map{$0.truncForm}.sorted(by: {$0.name < $1.name})
                                tasksToComplete = tasksToComplete - 1
                                checkComplete()
                            }
                        }
                        
                    } else {
                        print("Could not unwrap the local followers for comparison -- \(String(describing: self.user_forPage?.followers))")
                        modifiableUser!.followers = fetchedFollowers.map{$0.truncForm}.sorted(by: {$0.name < $1.name})
                        tasksToComplete = tasksToComplete - 1
                        checkComplete()
                    }
                    
                } else {
                    print("Could not unwrap the results to followers for comparison -- \(String(describing: mappedAnys))")
                }
            }),
            QueryRound(queryType: .order_and_Limit, refString: "users/\(self.user_forPage_string)/following", field: "name", QueryWeight: 500, value: 100, expectedReturn: .User, QueryClosure: {results, queryTime in
                
                let mappedAnys = results.map({$0.any})
                if let fetchedFollowing = mappedAnys as? [user] {
                    if let localFollowing = self.user_forPage?.following {
                        let localUUIDs = localFollowing.map{$0.id.uuidString}
                        let fetchedUUIDs = fetchedFollowing.map{$0.id.uuidString}
                        
                        if localUUIDs.sorted(by: {$0 > $1}) == fetchedUUIDs.sorted(by: {$0 > $1})
                        {
                            print("No changes in the following - no need to update")
                            modifiableUser!.following = localFollowing.sorted(by: {$0.name < $1.name})
                            tasksToComplete = tasksToComplete - 1
                            checkComplete()
                        } else {
                            if let _ = self.user_forPage{
                                modifiableUser!.following = fetchedFollowing.map{$0.truncForm}.sorted(by: {$0.name < $1.name})
                                tasksToComplete = tasksToComplete - 1
                                checkComplete()
                                print("Local Following: ", localFollowing.count)
                                print("Fetched Following: ", fetchedFollowing.count)
                            }
                        }
                        
                    } else {
                        print("Could not unwrap the local following for comparison -- \(String(describing: self.user_forPage?.following))")
                        print("Will attached fetched following to this user -- \(String(describing: fetchedFollowing))")
                        modifiableUser!.following = fetchedFollowing.map{$0.truncForm}.sorted(by: {$0.name < $1.name})
                        tasksToComplete = tasksToComplete - 1
                        checkComplete()
                    }
                    
                } else {
                    print("Could not unwrap the results to following for comparison -- \(String(describing: mappedAnys))")
                }
            })
            
            
            
            
        ]
        self.fetchUserCollections(queries: queries)
    }
    
    func fetchUserCollections(queries:[QueryRound]){
        
        DispatchQueue.global(qos: .background).async{
            //Fetch the publishedRecipes collection
            for query in queries{
                DistributeQueryLoads(queryRounds: [query], completion: {results, queryTime in
                    if let closure = query.QueryClosure {
                        closure(results, queryTime)
                    }
                })
            }   
        }
    }
    
    
        
    
}





//struct UserView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserView()
//    }
//}
