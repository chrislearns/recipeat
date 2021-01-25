//
//  RecipePostView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 4/5/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SPAlert

enum RecipePostSection{
    case instructions, comments
}

struct RecipePostView: View {
    @Binding var isShown_selection:Int?
    var developing = false
    var headerHeight:CGFloat = 42
    
    @State var selectionIndex:Int = 0
    
    @State var multiplier:Int = 1
    @State var thisRecipePost:RecipePost?
    @State var fullPostingUser:user?
    
    @State var showReporting = false
    
    @State var showActionSheet = false
    @State var showShareSheet = false
    var RP_String:String
    //@Binding var thisTruncUser:trunc_user
    @EnvironmentObject var env: GlobalEnvironment
    
    
    @State var PVModel = PagingGalleryModel(updater: 0, media: [])
    
    @State var comments:SearchResults = SearchResults(results: [])
    @State var modifyingRecipe = false
    
    @State var section:RecipePostSection = RecipePostSection.instructions
    @State var animatedIntro = false
    
    @State var postingUser_profPic:UIImage?
    
    @State var NavigationUnit = HashableNavigationUnit()
    
    var body: some View {
        
        ZStack{
            NavigationLink(destination: CategoryView(categoryVal: NavigationUnit.navigationContext as? String ?? ""), tag: NavigationDestination.CategoryView.hashValue, selection: self.$NavigationUnit.navigationSelector){
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
            
            if thisRecipePost == nil {
                CustomActivityIndicator(fgColor: Color.black, bgColor: Color.white)
            } else {
                
                ZStack{
                    ScrollView(){
                        VStack(alignment: .center, spacing:0){
                            PagingGalleryView(galleryHeight: UniversalSquare.width, galleryWidth: UniversalSquare.width, imageWidth: UniversalSquare.width, imageHeight: UniversalSquare.width, selection: $selectionIndex, tabView_updater:     $PVModel.updater, contents:
                                                $PVModel.media
                                )
                            .frame(width: UniversalSquare.width, height: UniversalSquare.width)
                                .clipped()
                                .background(Color.white)
                                .zIndex(300)
                            VStack(alignment: .center){
                                //General Info
                                HStack(alignment: .top){
                                    //Basic Info
                                    VStack(alignment: .leading){
                                        //Title
                                        Text("\(thisRecipePost?.title ?? "TITLE ERR")")
                                            .font(.system(size: 25, weight: .medium))
                                        //Subtitle
                                        Text("\(thisRecipePost?.subtitle ?? "SUBTITLE ERR")")
                                            .font(.system(size: 15, weight: .regular))
                                            .foregroundColor(.init(white: 0.3))
                                        //Subtitle
                                        Button(action: {}){
                                            HStack{
                                                Image(systemName: "heart.fill")
                                                Text("\(thisRecipePost?.likes.count ?? -1) likes")
                                            }.font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(lightPink)
                                        }
                                    }
                                    Spacer()
                                    
                                    Button(action: {
                                        self.showActionSheet = true
                                    }){
                                        Image(systemName:"ellipsis")
                                            .padding()
                                            .foregroundColor(.black)
                                    }
                                    .actionSheet(isPresented: $showActionSheet){
                                        ActionSheet(title: Text("More options"), message: Text("Choose an action from below"), buttons:
                                            
                                            {
                                                var buttons:[ActionSheet.Button] = []
                                                buttons.append(ActionSheet.Button.default(Text("Share"), action: {
                                                    let url = URL(string: "https://recipeat.app/?dest=recipe&context=\(self.thisRecipePost?.id.uuidString ?? "")")
                                                    let av = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
                                                    UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
                                                }))
                                                
                                                if is_sameUser(user_forPage: thisRecipePost?.postingUser, comparingUser: self.env.currentUser.truncForm) {
                                                    buttons.append(ActionSheet.Button.default(Text("Edit Post"), action: {
                                                        self.modifyingRecipe = true
                                                    })
                                                    )
                                                    buttons.append(ActionSheet.Button.destructive(Text("Delete Post").foregroundColor(.red), action: {
                                                        if let uw_thisRecipePost = self.thisRecipePost {
                                                            
                                                            deleteRecipe(
                                                                recipe: uw_thisRecipePost.truncForm,
                                                                postingUser: self.env.currentUser.truncForm,
                                                                completion: {_ in
                                                                    //Need to add the success indicator and the navigation undinding here
                                                                    let alertView = SPAlertView(title: "Recipe Deleted", message: "Your recipe was deleted successfully!", preset: SPAlertPreset.done)
                                                                    self.env.unsubscribeToTopic("recipe_\(uw_thisRecipePost.id.uuidString))_comments")
                                                                    self.env.unsubscribeToTopic("recipe_\(uw_thisRecipePost.id.uuidString))_likes")
                                                                    alertView.duration = 3
                                                                    alertView.present()
                                                                    self.isShown_selection = nil
                                                            }
                                                            )
                                                        }
                                                    }
                                                        )
                                                    )
                                                } else {
                                                    buttons.append(ActionSheet.Button.destructive(Text("Report").foregroundColor(.red), action: {
                                                        self.showActionSheet = false
                                                        self.showReporting = true
                                                    }
                                                        )
                                                    )
                                                }
                                                buttons.append(ActionSheet.Button.cancel())
                                                if self.env.currentUser.isAdmin {
                                                    if self.thisRecipePost != nil {
                                                        if self.thisRecipePost!.isFeatureEligible {
                                                            buttons.append(ActionSheet.Button.destructive(Text("Mark Ineligible").foregroundColor(.red), action: {
                                                            self.env.alertShown = true
                                                            }))
                                                        } else {
                                                            buttons.append(ActionSheet.Button.default(Text("Mark Eligible").foregroundColor(.red), action: {
                                                            self.env.alertShown = true
                                                            }))
                                                        }
                                                    }
                                                    
                                                }
                                                
                                                return buttons
                                                
                                        }()
                                        )
                                    }
                                    
                                }.alert(isPresented: self.$env.alertShown){
                                    
                                    
                                        if self.thisRecipePost!.isFeatureEligible {
                                            return          Alert(title: Text("Are you sure this is not eligible?"), message: Text("If marked ineligible, this post will no longer be visible in any featured areas"), primaryButton: .default(Text("OK"), action: {
                                                
                                                firestoreUpdate_data(docRef_string: "recipe/\(self.RP_String)", dataToUpdate: ["isFeatureEligible":false], completion: {outcome, any in
                                                reloadRecipe(recipeString: self.RP_String, completion: {fetched_RP in
                                                self.thisRecipePost = fetched_RP})
                                                print("updating: recipe/{id}", outcome)})
                                                
                                                
                                                
                                            }), secondaryButton: .cancel())
                                            
                                            
                                        } else {
                                            
                                            return Alert(title: Text("Mark this post as eligible?"), message: Text("If marked eligible, this post will be visible in any featured areas"), primaryButton: .default(Text("OK"), action: {
                                                
                                               firestoreUpdate_data(docRef_string: "recipe/\(self.RP_String)", dataToUpdate: ["isFeatureEligible":true], completion: {outcome, any in
                                                reloadRecipe(recipeString: self.RP_String, completion: {fetched_RP in
                                                self.thisRecipePost = fetched_RP})
                                                print("updating: recipe/{id}", outcome)})
                                                
                                                
                                                
                                            }), secondaryButton: .cancel())
                                            
                                        }
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                }
                                .sheet(isPresented: $showReporting){
                                    ReportView(isShown: self.$showReporting, report_correspondingEntityType: RecipeatEntity.Recipe, report_correspondingEntityID: self.thisRecipePost?.id ?? UUID(), report_reportingUser: self.env.currentUser.truncForm,
                                               report_entityPath: "recipe/\(self.thisRecipePost!.id)",
                                               closureAfterSubmit: {
                                                                            let alertView = SPAlertView(title: "Violation Reported", message: "Thank you for keeping our community safe. Your report has been submitted successfully", preset: SPAlertPreset.done)
                                                                            alertView.duration = 3
                                                                            alertView.present()
                                    }
                                               )
                                }
                                .padding(8)
                                .background(Color.init(white: 1))
                                ZStack{
                                    HStack(spacing:0){
                                        Spacer().frame(height: 30).frame(maxWidth: .infinity)//.background(Color.red)
                                        Spacer().frame(height: 30).frame(maxWidth: section == RecipePostSection.comments ? 0 : 50)//.background(Color.yellow)
                                        //                                        Spacer().frame(height: 30).frame(maxWidth: section != RecipePostSection.comments ? 0 : .infinity).background(Color.green)
                                        Spacer().frame(height: 30).frame(maxWidth: section == RecipePostSection.comments ? 0 : .infinity)//.background(Color.blue)
                                        Circle().frame(width: 50, height: 50).foregroundColor(lightPink)
                                        //                                        Spacer().frame(height: 30).frame(maxWidth: section == RecipePostSection.comments ? 0 : .infinity).background(Color.purple)
                                        Spacer().frame(height: 30).frame(maxWidth: section != RecipePostSection.comments ? 0 : .infinity)//.background(Color.black)
                                        Spacer().frame(height: 30).frame(maxWidth: section != RecipePostSection.comments ? 0 : 50)//.background(Color.white)
                                        Spacer().frame(height: 30).frame(maxWidth: .infinity)//.background(Color.orange)
                                    }.animation(Animation.interpolatingSpring(stiffness: 330, damping: 20.0, initialVelocity: 5.5))
                                    
                                    
                                    HStack(spacing:0){
                                        Spacer()
                                        Button(action: {self.section = RecipePostSection.comments}){
                                            Image(systemName: "text.bubble")
                                                .font(.system(size: 25))
                                                .foregroundColor(section == RecipePostSection.comments ? Color.white : Color.init(white: 0.8))
                                            
                                        }.frame(width: 50, height:50)//.background(Color.green.opacity(0.4))
                                        Spacer()
                                        Button(action: {self.section = RecipePostSection.instructions}){
                                            Image(systemName: "list.bullet.below.rectangle")
                                                .font(.system(size: 25))
                                                .foregroundColor(section == RecipePostSection.instructions ? Color.white : Color.init(white: 0.8))
                                            
                                        }.frame(width: 50, height:50)//.background(Color.green.opacity(0.4))
                                        Spacer()
                                    }.animation(Animation.interpolatingSpring(stiffness: 330, damping: 20.0, initialVelocity: 7))
                                }
                                .padding(.vertical, 10)
                                .frame(height:50)
                                //                                .background(Color.blue)
                                if self.section == RecipePostSection.instructions {
                                    VStack(alignment: .center){
                                        if thisRecipePost!.timePrep > 0 || thisRecipePost!.timeCook > 0  || thisRecipePost!.timeOther > 0 {
                                            if possible_stringToDouble(thisRecipePost!.estimatedServings)! > 0 {
                                                //Details
                                                RecipeDetailsView(thisRecipePost: thisRecipePost!, animatedIntro: $animatedIntro)
                                            }
                                        }
                                        
                                        if possible_stringToDouble(thisRecipePost!.estimatedServings) != nil {
                                            if possible_stringToDouble(thisRecipePost!.estimatedServings)! > 0 {
                                                RecipeServingsView(thisRecipePost: thisRecipePost!, multiplier: $multiplier, animatedIntro: $animatedIntro)
                                            }
                                        }
                                        
                                        //Ingredients
                                        RecipePostIngredientsView(thisRecipePost: thisRecipePost!, animatedIntro: $animatedIntro, multiplier: $multiplier)
                                        
                                        //Steps
                                        RecipePostStepsView(thisRecipePost: thisRecipePost!, animatedIntro: $animatedIntro)
                                        
                                    }
                                    .padding(.horizontal, 8)
                                    .transition(AnyTransition.asymmetric(insertion: AnyTransition.move(edge: .trailing), removal: AnyTransition.move(edge: .leading)))
                                        
                                    .animation(Animation.easeInOut(duration: 0.4))
                                } else {
                                    
                                    VStack(spacing:10){
                                        if comments.results.count > 0 {
                                            ForEach(comments.results.sorted{ ($0.any as? Comment)?.dateCreate ?? "" < ($1.any as? Comment)?.dateCreate ?? "" }, id: \.id){comment in
                                                ZStack{
                                                    if comment.any as? Comment != nil {
                                                        CommentView_Default(
                                                            comment: comment.any as! Comment,
                                                            isOwner: (comment.any as! Comment).commentingUser.id.uuidString == self.thisRecipePost!.postingUser.id.uuidString,
                                                            isSelf: (comment.any as! Comment).commentingUser.id.uuidString == self.env.currentUser.id.uuidString,
                                                            goToCommenter: {
                                                                self.NavigationUnit.navigationContext = (comment.any as! Comment).commentingUser.id.uuidString
                                                                self.NavigationUnit.navigationSelector = NavigationDestination.UserHomeView.hashValue
                                                                print("navigating to profile")
                                                        },
                                                            completion: {outcome in
                                                                println("comment delete outcome: \(outcome)",0)
                                                                self.reloadComments()
                                                        },
                                                            commentPath: "recipe/\(self.thisRecipePost!.id.uuidString)/comments/\((comment.any as! Comment).id.uuidString)"
                                                            )
                                                    } else {
                                                        EmptyView()
                                                    }
                                                }
                                            }
                                        } else {
                                            VStack(spacing:0){
                                                Image("comments")
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width:80, height:80)
                                                    .padding(.top, 20)
                                                Text(comments.timeStamp == nil ? "LOADING" : "YOU'RE NUMBER 1")
                                                    .font(.system(size: 20, weight: .semibold))
                                                Text(comments.timeStamp == nil ? "Stay right here, we're grabbing something from the pantry..." : "Be the first to comment")
                                                    .frame(width: UniversalSquare.width - 100)
                                                    .multilineTextAlignment(.center)
                                                Spacer().frame(height: 50)
                                            }.frame(height: 200)
                                        }
                                        CommentView_Add(recipeID: RP_String, completion: {outcome in
                                            println("comment add outcome: \(outcome)",0)
                                            
                                            self.reloadComments()
                                            if outcome == completionHander_outcome.success {
                                                if let thisRecipePost = self.thisRecipePost {
                                                    if self.env.currentUser.id.uuidString != thisRecipePost.postingUser.id.uuidString {
                                                        notifyComment(targetRecipe: thisRecipePost.truncForm, commentingUser: self.env.currentUser.truncForm)
                                                    }
                                                } else {
                                                    println("failed to unwrap recipe after comment - \(String(describing: self.thisRecipePost))", 0)
                                                }
                                            }
                                        })
                                        
                                        Spacer().frame(height: 20)
                                    }.padding().foregroundColor(Color.init(white: 0.8))
                                        
                                        
                                        
                                        
                                        .transition(AnyTransition.asymmetric(insertion: AnyTransition.move(edge: .leading), removal: AnyTransition.move(edge: .trailing)))
                                        
                                        .animation(Animation.easeInOut(duration: 0.55))
                                    
                                }
                                
                                if thisRecipePost!.tags.count > 0 {
                                    ScrollView(.horizontal, showsIndicators: false){
                                        HStack{
                                            Text("TAGS: ")
                                            ForEach(thisRecipePost!.tags, id: \.id){thisTag in
                                                
                                                TagItemView(wordPadding: StandardTagViewAttributes().wordPadding, bgColor: Color.init(white: 0.9), fgColor: Color.black, font: .system(size: StandardTagViewAttributes().fontSize, weight: .medium), text: .constant(thisTag.displayVal),
                                                            selected: .constant(true)
                                                ).onTapGesture {
                                                    self.NavigationUnit.navigationContext = thisTag.dbVal
                                                    self.NavigationUnit.navigationSelector = NavigationDestination.CategoryView.hashValue
                                                }
                                            }
                                        }.padding(.horizontal, 15)
                                    }
                                    
                                }
                            }.padding(.bottom, 10)
                                .background(Color.white)
                                .zIndex(600)
                            
                            Spacer().frame(height: self.env.tabBarHeight + (UniversalSafeOffsets?.bottom ?? 0))
                            
                        }
                    }
                    
                    
                    
                    
                    VStack(alignment: .leading, spacing: 0){
                        HStack{
                            Button(action: {
                                self.NavigationUnit.navigationContext = self.thisRecipePost?.postingUser.id.uuidString
                                self.NavigationUnit.navigationSelector = NavigationDestination.UserHomeView.hashValue
                                print("navigating to profile")
                            }){
                                
                                UserCapsule(username: .constant(thisRecipePost!.postingUser.username), image: $postingUser_profPic)
                                    
                                    .padding(.top, 7)
                                    .padding(.leading, 7)
                            }
                            Spacer()
                        }
                        Button(action: {
                            likePost(postingUser: self.fullPostingUser, postingUser_trunc: self.thisRecipePost!.postingUser, recipeToLike: self.thisRecipePost!.truncForm, likerUser: self.env.currentUser, completion:{fullUser in
                                
                                reloadRecipe(recipeString: self.RP_String, completion: {fetched_RP in
                                    self.thisRecipePost = fetched_RP})
                                if let fullUser = fullUser{
                                    self.fullPostingUser = fullUser
                                }
                                
                            })
                            
                            
                            reloadRecipe(recipeString: self.RP_String, completion: {fetched_RP in
                                self.thisRecipePost = fetched_RP})
                        }){
                            HStack(spacing:0){
                                Image(systemName: userLikesRecipe(user: self.env.currentUser, recipe: self.thisRecipePost!.truncForm) ? "heart.fill" : "heart")
                                    .font(.system(size: 20 ))
                                    
                                    .foregroundColor(userLikesRecipe(user: self.env.currentUser, recipe: self.thisRecipePost!.truncForm) ? lightPink : Color.init(white: 0.5))
                                    .frame(width: 26, height: 26)
                                    
                                    .padding(.vertical, 5)
                                    .padding(.leading, 5)
                                    .padding(.trailing, 2)
                                Text("\(self.thisRecipePost!.likes.count)")
                                    .fontWeight(.medium)
                                    .padding(.trailing, 10)
                                    .foregroundColor(Color.init(white: 0.5))
                            }.background(Color.white.opacity(0.8))
                                .foregroundColor(Color.black)
                                .cornerRadius(18)
                                .shadow(radius: 2)
                                .padding(.top, 7)
                                .padding(.leading, 7)
                        }
                        
                        
                        
                        //                        HStack(spacing:0){
                        //                            Button(action: {
                        //                                self.NavigationUnit.navigationContext = self.thisRecipePost?.postingUser.id.uuidString
                        //                                self.NavigationUnit.navigationSelector = NavigationDestination.UserHomeView.hashValue
                        //                                print("navigating to profile")
                        //                            }){
                        //                                HStack(spacing:0){
                        //                                    Image(uiImage: postingUser_profPic == nil ? UIImage(named: "chefAvatar")! : postingUser_profPic!)
                        //
                        //                                        .renderingMode(.original)
                        //                                        .resizable()
                        //                                        .scaledToFill()
                        //                                        .frame(width: headerHeight - 16, height: headerHeight - 16)
                        //                                        .cornerRadius((headerHeight - 16)/2)
                        //                                        .padding(8)
                        //                                    Text(self.thisRecipePost == nil ? "@..." : "@\(self.thisRecipePost!.postingUser.username)")
                        //                                        .fontWeight(.medium)
                        //                                    if self.thisRecipePost != nil {
                        //                                        if self.thisRecipePost!.postingUser.verified{
                        //                                            Image("verified_128")
                        //                                                .renderingMode(.original)
                        //                                                .resizable()
                        //                                                .scaledToFit()
                        //                                                .frame(width: 20, height: 20)
                        //                                                .padding(0)
                        //                                        }
                        //                                    }
                        //                                }
                        //                                .foregroundColor(Color.black)
                        //                            }
                        //                            Spacer()
                        //                        }.background(Color.init(white: 0.95).opacity(0.7))
                        
                        Spacer()
                        
                    }
                }.KeyboardAwarePadding()
            }
        }.onAppear(){
            print(self.RP_String)
            
            func set_userPhoto(imageString:String){
                DispatchQueue.main.async{
                    if self.postingUser_profPic == nil {
                        loadImage_cache_FireStore(imageString: imageString, resized: .s64,  minimumRecency: .Hour12, completion: {
                            imageData in
                            if let imageData = imageData {
                                self.postingUser_profPic = UIImage(data: imageData)!
                            } else {
                                print("couldn't grab image")
                            }
                        })
                    }
                }
            }
            //This loads the recipe - note the periodic inclusion of "set_userPhoto()" in the function which allows us to update the posting user's photo once we know who the posting user is
            if let this_RP = self.thisRecipePost {
                print("unwrapped RP")
                set_userPhoto(imageString: "user/\(this_RP.postingUser.id.uuidString)/profilepicture")
            } else {
                print("reloading recipe")
                reloadRecipe(recipeString: self.RP_String, completion: {fetched_RP in
                    print("recipe gathered - \(fetched_RP.title)")
                    self.thisRecipePost = fetched_RP
                    
                    firebaseStorage_listAll(directory: "recipe/\(fetched_RP.id.uuidString)", completion: {
                        listOfReferences in
                        if let listOfReferences = listOfReferences as? [StorageReference] {
                            print("listCount = \(listOfReferences.count)")
                            for i in 0..<listOfReferences.count {
                                
                                func addImage_toMedia(){
                                    print("adding fish platter")
                                    self.PVModel.media.append(
                                        Identifiable_Media(media: Identifiable_UIImage(rawImage: UIImage(named: "fishPlatter_padded")!))
                                    )
                                    self.PVModel.updater = Int.random(in: 0...1000)
                                    
                                    print("fetching image at: \(ref.fullPath)")
                                    
                                    DispatchQueue.main.async{
                                        loadImage_cache_FireStore(imageString: ref.fullPath, resized: .s1024, minimumRecency: .Hour12, completion: {
                                            imageData in
                                            guard let imageData = imageData else {
                                                print("couldnt unwrap optional image data")
                                                return
                                            }
                                            guard let newImage = UIImage(data: imageData) else {
                                                print("image couldnt be fetched. will remove from array to remove placeholder image")
                                                self.PVModel.media.remove(at: i)
                                                self.PVModel.updater = Int.random(in: 0...1000)
                                                return
                                            }
                                            
                                                print("image fetched and attached to media object")
                                                self.PVModel.media[i].media = Identifiable_UIImage(rawImage: newImage)
                                                self.PVModel.updater = Int.random(in: 0...1000)
                                            
                                        })
                                    }
                                }
                                func addVideo_toMedia(){
                                    self.PVModel.media.append(
                                        Identifiable_Media(media:
                                                            Identifiable_Video(videoLocation: ref.fullPath)
                                        )
                                    )
                                    self.PVModel.updater = Int.random(in: 0...1000)
                                    
                                    print("getting download URL: \(ref.fullPath)")
                                    
                                    DispatchQueue.main.async{
                                        ref.downloadURL(completion: {url, err in
                                            if let err = err {
                                                print("ran into an error getting the download url")
                                                print("err ... ", err.localizedDescription)
                                                self.PVModel.media.remove(at: i)
                                                self.PVModel.updater = Int.random(in: 0...1000)
                                                return
                                            } else if let url = url{
                                                self.PVModel.media[i] = Identifiable_Media(media:
                                                        Identifiable_Video(videoLocation: url.absoluteString)
                                                    )
                                                self.PVModel.updater = Int.random(in: 0...1000)
                                            } else {
                                                print("somehow the url and err were both nil - this should never happen - need to investigate")
                                            }
                                        })
                                    }
                                }
                                
                                
                                let ref = listOfReferences[i]
                                ref.getMetadata(completion: {met, err in
                                    if let err = err {
                                        print("there was an issue gathering metadata")
                                        print("err --- ", err.localizedDescription)
                                        print("will attempt to conform to uiimage")
                                        
                                        addImage_toMedia()
                                                                                
                                    } else if let met = met{
                                        print("metadata present - will evaluate type")
                                        print("contentType --- \(met.contentType ?? "default type")")
                                        if met.contentType == "application/octet-stream" {
                                            addImage_toMedia()
                                        } else{
                                            if met.contentType == "video/mp4" {
                                                print("found video")
                                                print("\(ref.fullPath)")
                                                print("\(ref.bucket)")
                                                
                                                addVideo_toMedia()
                                            }
                                        }
                                    } else {
                                        print("err - somehow the error and met both came back as nil")
                                        addImage_toMedia()
                                    }
                                })
                            }
                        }
                    })
                    set_userPhoto(imageString: "user/\(fetched_RP.postingUser.id.uuidString)/profilepicture")
                })
            }
            self.reloadComments()
        }
        .navigationBarTitle(Text("Recipe"), displayMode: .inline)
//        .fullScreenCover(isPresented: self.$modifyingRecipe){
//            NewPost_ImageSelectionView(
//                shown: $modifyingRecipe,
//                recipeObject: RecipeObject(
//                    recipe: self.thisRecipePost.unsafelyUnwrapped,
//                    images: self.PVModel.media
//                ),
//                images: self.PVModel.media,
//                isEditing:true
//            )
//        }
        
        
        
        
    }
    
    func reloadComments(){
        loadComments(recipePost: self.RP_String, completion: {outcome, results, queryTime in
            
            if outcome == .failed {
                println("something went wrong loading the comments", 0)
                self.comments.results = []
                self.comments.timeStamp = queryTime
            } else {
                if let oldTime = self.comments.timeStamp {
                    
                    println("loaded comments - (\((results ?? []).count))", 0)
                    if queryTime > oldTime {
                        self.comments.results = results ?? []
                        self.comments.timeStamp = queryTime
                    }
                    
                    
                } else {
                    println("this is the first set of comments loaded")
                    self.comments.results = results ?? []
                    self.comments.timeStamp = queryTime
                }
            }
        })
    }
}



struct RecipePostView_Previews: PreviewProvider {
    
    static var previews: some View {
        RecipePostView(
            isShown_selection: .constant(1),
            thisRecipePost: RecipePost(id: UUID(), title: "blah blah", subtitle: "this is a random subtitle", steps: [Step(subtitle: "ashasdg"),Step(subtitle: "3ergsdf"),Step(subtitle: "afgasdg")], ingredients: [], postingUser: user().truncForm, likes: [], tags: [], timePrep: 0, timeCook: 0, timeOther: 0, estimatedServings: "", flagged: false, isFeatureEligible: true),
            RP_String: RecipePost().id.uuidString
        )
        .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
        
    }
}





























/*Pics
 
 Icons made by <a href="https://www.flaticon.com/authors/pause08" title="Pause08">Pause08</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>
 
 Icons made by <a href="https://www.flaticon.com/authors/freepik" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>
 
 Icons made by <a href="https://www.flaticon.com/authors/freepik" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>
 
 Icons made by <a href="https://www.flaticon.com/authors/vitaly-gorbachev" title="Vitaly Gorbachev">Vitaly Gorbachev</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>
 
 Icons made by <a href="https://www.flaticon.com/authors/freepik" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>
 
 Icons made by <a href="https://www.flaticon.com/authors/monkik" title="monkik">monkik</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>
 
 Icons made by <a href="https://www.flaticon.com/authors/freepik" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>
 
 Icons made by <a href="https://www.flaticon.com/authors/freepik" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>
 
 Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>
 */
