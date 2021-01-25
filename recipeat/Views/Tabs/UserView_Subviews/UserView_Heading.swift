//
//  UserView_Heading.swift
//  recipeat
//
//  Created by Christopher Guirguis on 4/29/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import SPAlert

struct UserView_Heading: View {
    @EnvironmentObject var env: GlobalEnvironment
    @State var showActionSheet = false
    @State var showSheet = false
    @Binding var user_forPage:user?
    @State var uiImage:UIImage?
    @Binding var changed:Int32
    
    @State var sheetDestination:Int
    
    var reloadClosure:() -> Void
    
    @State var imagePickerChosenPic:Identifiable_UIImage? = nil
    @Binding var NavigationUnit:HashableNavigationUnit
    var body: some View {
        ZStack{
            VStack(alignment: .leading, spacing: 5){
                HStack{
                    ZStack{
                        if user_forPage != nil {
                            Image(uiImage: (uiImage == nil ? UIImage(named: "chefAvatar")!: uiImage!))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height:80)
                                .cornerRadius(40)
                                .foregroundColor(Color.init(white: 0.8))
                                .overlay(Circle().stroke(lineWidth: 1).foregroundColor(Color.init(white: 0.8)))
                                .shadow(radius: 4)
                                .opacity((uiImage == nil ? 0.6 : 1))
                                .onAppear(){self.loadData()}
                            
                            if is_sameUser(user_forPage: user_forPage?.truncForm, comparingUser: self.env.currentUser.truncForm){
                                Button(action: {
                                    print("editing profile pic")
                                    sheetDestination = NavigationDestination.ImagePickerView.rawValue
                                    self.showSheet = true
                                }){
                                    Image(systemName: "camera.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .background(Color.black)
                                        .frame(width:30, height: 30)
                                        .foregroundColor(Color.white.opacity(1.0))
                                        .cornerRadius(20)
                                        .opacity((uiImage == nil ? 1 : 0.45))
                                        .shadow(radius: 2)
                                        .shadow(radius: 3)
                                    
                                }.offset(y: 30)
                                    
                            }
                        }
                    }
                    Spacer()
                    VStack(alignment: .center){
                        Text("\(user_forPage?.publishedRecipes?.count ?? 0)")
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(Color.init(white:0.0))
                            .padding(2)
                        Text("Recipes")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.init(white:0.3))
                    }
                    Spacer()
                    Button(action: {
                        self.NavigationUnit.navigationContext = self.user_forPage?.followers
                        self.NavigationUnit.navigationSelector = NavigationDestination.ListUser.hashValue
                    }){
                        VStack(alignment: .center){
                            Text("\(user_forPage?.followers?.count ?? 0)")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundColor(Color.init(white:0.0))
                                .padding(2)
                            Text("Followers")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.init(white:0.3))
                        }.foregroundColor(Color.black)
                    }
                    Spacer()
                    Button(action: {
                        self.NavigationUnit.navigationContext = self.user_forPage?.following
                        self.NavigationUnit.navigationSelector = NavigationDestination.ListUser.hashValue
                    }){
                        VStack(alignment: .center){
                            Text("\(user_forPage?.following?.count ?? 0)")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundColor(Color.init(white:0.0))
                                .padding(2)
                            Text("Following")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.init(white:0.3))
                        }.foregroundColor(Color.black)
                    }
                }
                
                
                
                HStack(spacing:0){
                    Text("\(user_forPage?.name ?? "...")")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.black)
                        .shadow(radius:0)
                    
                    if user_forPage != nil {
                        if user_forPage!.verified == true {
                            Image("verified_128")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                    }
                    Button(action: {showActionSheet = true}){
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.init(white: 0.2))
                            .padding(.leading, 8)
                    }.actionSheet(isPresented: $showActionSheet){
                        ActionSheet(title: Text("More options"), message: Text("Choose an action from below"), buttons: //[.cancel()]
                            
                            {
                                var buttons:[ActionSheet.Button] = []
                                if !is_sameUser(user_forPage: user_forPage?.truncForm, comparingUser: self.env.currentUser.truncForm){
                                buttons.append(ActionSheet.Button.destructive(Text(
                                    userIsBlocked(listOfBlockedUser: self.env.currentUser.blocked, checkingFor: self.user_forPage!.id) ? "Unblock" : "Block"
                                ).foregroundColor(.red), action: {
                                    //If you're blocking the person, you need to unfollow eachother
                                    if !userIsBlocked(listOfBlockedUser: self.env.currentUser.blocked, checkingFor: self.user_forPage!.id) {

                                        followUser(targetUser: self.env.currentUser, followerUser: self.user_forPage!, follow: false, completion: {_ in
                                            followUser(targetUser: self.user_forPage!, followerUser: self.env.currentUser, follow: false, completion: {_ in
                                                //This refreshes the subcollections of the user you just blocked
            //                                    self.completeUser()
                                                let alertView = SPAlertView(title: "Block completed", message: "You have blocked @\(self.user_forPage!.username). They can no longer see you or the content you post until you unblock them.", preset: SPAlertPreset.done)
                                                alertView.duration = 5
                                                alertView.present()
                                            })
                                        })
                                    }
                                    var act = FSArrayAction.union
                                    if userIsBlocked(listOfBlockedUser: self.env.currentUser.blocked, checkingFor: self.user_forPage!.id) {
                                        act = .remove
                                    } else {
                                        act = .union
                                    }
                                    FS_ArrayModify(docRef_string: "users/\(self.env.currentUser.id.uuidString)", field: "blocked", value: self.user_forPage!.id.uuidString, action: act, completion: {_,_  in
                                        print("")})
                                    FS_ArrayModify(docRef_string: "users/\(self.user_forPage!.id.uuidString)", field: "blockedBy", value: self.env.currentUser.id.uuidString, action: act, completion: {_,_  in
                                    print("")})
                                    print("needed to modify a value somewhere to trigger the detection of a change with the firbase listener that's looking for a data change")
            //                        firestoreUpdate_data(docRef_string: "users/\(self.env.currentUser.id.uuidString)", dataToUpdate: ["verified":self.env.currentUser.verified], completion: {outcome, any in })
                                }
                                ))
                                }
                                buttons.append(ActionSheet.Button.destructive(Text("Report").foregroundColor(.red), action: {
                                    self.showActionSheet = false
                                    
                                    sheetDestination = NavigationDestination.ReportView.rawValue
                                    self.showSheet = true
                                }
                                    )
                                )
                                //                                                   }
                                buttons.append(ActionSheet.Button.cancel())
                                //
                                return buttons
                        //
                                                                   }()
                                    
                                                                   )

                    }
                }
                if user_forPage?.bio != nil {
                    if user_forPage!.bio != "" {
                        Text("\(user_forPage!.bio)")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.init(white: 0.3))
                            .shadow(radius:0)
                    }
                }
                if !is_sameUser(user_forPage: user_forPage?.truncForm, comparingUser: self.env.currentUser.truncForm){
                    Spacer().frame(height: 1)
                    Button(action: {
                        if let userList = self.user_forPage?.followers, let targetUser = self.user_forPage {
                            if self.env.currentUser.blocked.first(where: {$0.uuidString == self.user_forPage!.id.uuidString}) == nil {
                                let searchObject = self.env.currentUser.truncForm
                                
                                if checkFollowUser(userList: userList, searchObject: searchObject){
                                    print("unfollowing user")
                                    followUser(targetUser: targetUser, followerUser: self.env.currentUser, follow: false, completion: {_ in
                                        self.reloadClosure()
                                    })
                                } else {
                                    print("following user")
                                    followUser(targetUser: targetUser, followerUser: self.env.currentUser, follow: true, completion: {_ in
                                        self.reloadClosure()
                                    })
                                }
                            } else {
                                let alertView = SPAlertView(title: "User Blocked", message: "You previously blocked this user. To follow them you must unblock them by pressing the more options button (...) in the top right corner of the screen.", preset: SPAlertPreset.exclamation)
                                alertView.duration = 5
                                alertView.present()
                            }
                        } else {
                            let alertView = SPAlertView(title: "Something went wrong", message: "err: 8ve9s 3i4wg", preset: SPAlertPreset.error)
                            alertView.duration = 3
                            alertView.present()
                        }
                        
                    }){
                        HStack{
                            
                            Text(
                                user_forPage == nil ? "LOADING" :
                                    (self.user_forPage!.followers == nil ? "LOADING" :
                                        (checkFollowUser(userList: self.user_forPage!.followers!, searchObject:self.env.currentUser.truncForm) ? "UNFOLLOW" :
                                            (self.env.currentUser.blocked.first(where: {$0.uuidString == self.user_forPage!.id.uuidString}) != nil ? "FOLLOW - BLOCKED" :
                                            "+ FOLLOW")
                                        )
                                )
                            )
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(
                            (self.env.currentUser.blocked.first(where: {$0.uuidString == self.user_forPage?.id.uuidString ?? ""}) != nil ? Color.red :
                            Color.black)
                        )
                            .frame(height:20)
                            
                            .frame(maxWidth: .infinity).padding(5)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1)
                                .foregroundColor(
                                    (self.env.currentUser.blocked.first(where: {$0.uuidString == self.user_forPage?.id.uuidString ?? ""}) != nil ? Color.red :
                                        Color.black)
                                )
                        )
                            .shadow(color: Color.white.opacity(0.5), radius: 4, x: 0, y: 1)
                    }
                }
                Spacer().frame(height:20)
                
            }
            .padding(.horizontal, 20)
            
            
        }.frame(width: UIScreen.main.bounds.width)
        .sheet(isPresented: $showSheet){
            if sheetDestination == NavigationDestination.ReportView.rawValue{
            ReportView(isShown: self.$showSheet, report_correspondingEntityType: RecipeatEntity.User, report_correspondingEntityID: self.user_forPage?.id ?? UUID(), report_reportingUser: self.env.currentUser.truncForm,
                       report_entityPath: "users/\(self.user_forPage!.id)",
                       closureAfterSubmit: {
                                                    let alertView = SPAlertView(title: "Violation Reported", message: "Thank you for keeping our community safe. Your report has been submitted successfully", preset: SPAlertPreset.done)
                                                    alertView.duration = 3
                                                    alertView.present()
            }
                       )
            } else if sheetDestination == NavigationDestination.ImagePickerView.rawValue {
                imagePicker(images: .constant([]),
                            allowsEditing: true,
                            multiplicity: PickerMultiplicityType.Single ,
                            pickedClosure: {imagesPicked in
                                print("selected profile picture")
                                print(imagesPicked)
                                self.imagePickerChosenPic = imagesPicked
                                
                                
                                print("will upload pic here")
                                if let newProfilePic = self.imagePickerChosenPic {
                                    if let uwUser = self.user_forPage { uploadImage("user/\(uwUser.id.uuidString)/profilepicture", image: newProfilePic.image.raw, completion: {outcome,anyObj in
                                        
                                        print("upload successful")
                                        
                                        
                                        self.loadData(minimumRecency: .Now)
                                        withAnimation{
                                            self.env.loaderShown = false
                                        }
                                        //Reset the picker defaults
                                        self.showSheet = false
                                        
                                        self.imagePickerChosenPic = nil
                                        
                                    })
                                    }
                                    
                                } else {
                                    withAnimation{
                                        self.env.loaderShown = false
                                    }
                                    let alertView = SPAlertView(title: "Error uploading profile picture", message: "err: asfb8 4wmef", preset: SPAlertPreset.error)
                                    alertView.duration = 3
                                    alertView.present()
                                }
                                
                },
                            sourceType: .photoLibrary)
            }
        }
        
        
    }
    func loadData(minimumRecency:CacheDuration = CacheDuration.Hour12){
        //This loadData is checking for resources like the user's profile pic
        DispatchQueue.main.async{
            if let user_forPage = self.user_forPage {
            let imageString = "user/\(user_forPage.id.uuidString)/profilepicture"
            loadImage_cache_FireStore(imageString: imageString,  resized: .s128, minimumRecency: minimumRecency, completion: {
                imageData in
                if let imageData = imageData {
                    self.uiImage = UIImage(data: imageData)!
                } else {
                    print("couldn't grab image")
                }
            })
        }
        }
    }
}





//struct UserView_Heading 
