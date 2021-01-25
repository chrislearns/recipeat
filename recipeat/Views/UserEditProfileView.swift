//
//  UserEditProfileView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/14/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import SPAlert
import FirebaseStorage
import FirebaseFirestore
import Firebase



struct UserEditProfileView: View {
    
    var showLoader:(Bool) -> Void
    var user_forPage:user
    @State var uiImage:UIImage?
    @State var bio:String = ""
    @State var name:String = ""
    @State var username:String = ""
    @State var password:String = ""
    @State var confirmpassword:String = ""
    
    
    @Binding var isShown:Bool
    var body: some View {
        ScrollView{
            VStack(spacing:0){
            HStack{
                    VStack(alignment: .leading, spacing:0){
                Text("Edit Profile")
                    .multilineTextAlignment(.leading)
                .lineLimit(5)
                    .font(.system(size: 40, weight: .heavy))
                Text("When you finish, press the SUBMIT button below")
                    .multilineTextAlignment(.leading)
                    .lineLimit(8)
                    .font(.system(size: 15))
                    .foregroundColor(Color.init(white: 0.5))
            }
                    Spacer()
                }
            VStack(spacing:0){
                
                    HStack{
                        Text("BIO")
                        Spacer()
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.bottom, 8)
                REP_TextView(text: $bio, keyboardType: .default)
//                TextField("Bio", text: $bio)
                .autocapitalization(.sentences)
                .padding(5).background(Color.clear)
                .font(.system(size: 15))
                .frame(height:90).frame(maxWidth: .infinity)
                .modifier(RoundedOutline())
                
                
                
                Spacer().frame(height: 10)
                
                HStack{
                    Text("PERSONAL INFO")
                    Spacer()
                }
                .font(.system(size: 13, weight: .semibold))
                .padding(.bottom, 8)
            VStack(spacing:0){
                TextField("Name", text: $name)
                    .autocapitalization(.words)
                .disableAutocorrection(true)
                    .padding().background(Color.clear)
                    .frame(height:35)
                    .padding(5)
                Rectangle().frame(height:1).foregroundColor(Color.init(white: 0.8))
                TextField("Username (3+ characters)", text: $username)
                    .autocapitalization(.none)
                    .padding().background(Color.clear)
                    .frame(height:35)
                    .padding(5)
                Rectangle().frame(height:1).foregroundColor(Color.init(white: 0.8))
                SecureField("Password (8+ characters)", text: $password)
                    .autocapitalization(.none)
                    .padding().background(Color.clear)
                    .frame(height:35)
                    .padding(5)
                Rectangle().frame(height:1).foregroundColor(Color.init(white: 0.8))
                SecureField("Re-Enter Password (8+ characters)", text: $confirmpassword)
                    .autocapitalization(.none)
                    .padding().background(Color.clear)
                    .frame(height:35)
                    .padding(5)
            }
            .modifier(RoundedOutline())
//            .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1).foregroundColor(Color.init(white: 0.8)))
//            .padding(.horizontal, 15).padding(.vertical, 10)
            
            
            Button(action: {
                
                
                if self.editProfile_validation() {
                    if self.username == self.user_forPage.username {
                        print("user didn't attempt to change their username, therefore we won't take the time to validate if their username is unique as we try to update their info")
                        self.executeUpdate()
                    } else {
                    Firestore.firestore().collection("users").whereField("username", isEqualTo: self.username).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            let alertView = SPAlertView(title: "Something went wrong", message: "err: as9sd 438fa", preset: SPAlertPreset.error)
                            alertView.duration = 3
                            alertView.present()
                            print(err)
                        } else {
                            if querySnapshot!.documents.count == 0 {
                                self.executeUpdate()
                                
                            } else {
                                withAnimation{
                                    let alertView = SPAlertView(title: "Aww man!", message: "Looks like this username is already taken!", preset: SPAlertPreset.error)
                                    alertView.duration = 3
                                    alertView.present()
                                    
                                }
                            }
                        }
                        
                    }
                    
                    }
                }
                
            }) {
                Text("SUBMIT")
            }.buttonStyle(CapsuleStyle(bgColor: .white, fgColor: darkGreen))
//            Spacer().frame(height:120)
            
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .modifier(RoundedOutline(color: darkGreen))
            .padding(.vertical, 10)
            }
                .padding(.horizontal, 15)
            .KeyboardAwarePadding()
            .padding(.vertical, 20)
        .frame(width: UniversalSquare.width)
        .onAppear(){
            self.name = self.user_forPage.name
            self.bio = self.user_forPage.bio
            self.username = self.user_forPage.username
            self.password = self.user_forPage.password
            self.confirmpassword = self.user_forPage.password
        }
        }
        
        .animation(.easeIn(duration: 0.35))
    }
    
    func loadData(minimumRecency:CacheDuration = CacheDuration.Hour12){
        //This loadData is checking for resources like the user's profile pic
        DispatchQueue.main.async{
            let imageString = "user/\(self.user_forPage.id.uuidString)/profilepicture"
            loadImage_cache_FireStore(imageString: imageString,  resized: .s256, minimumRecency: minimumRecency, completion: {
                imageData in
                if let imageData = imageData {
                    self.uiImage = UIImage(data: imageData)!
                } else {
                    print("couldn't grab image")
                }
            })
            
        }
    }
    
    func editProfile_validation() -> Bool{
        var errorMessage = ""
        var returnVal = true
        if name.count < 1 {
            returnVal = false
            errorMessage = "Please add a name"
        } else if username.count < 3 {
            returnVal = false
            errorMessage = "Please make sure your username is at least 3 characters long"
        } else if username.alphanumerics.count != username.count {
            returnVal = false
            errorMessage = "Please make sure your username only contains numbers and letters"
        } else if password.count < 8{
            returnVal = false
            errorMessage = "Please make sure your password is at least 8 characters long"
        } else if password.passwordAllower.count != password.count {
            returnVal = false
            errorMessage = "Please make sure your password only contains letters, numbers, or the following characters: !@#$%&"
        } else if confirmpassword != password{
            returnVal = false
            errorMessage = "Please make sure both of your password fields are identical"
        } else if username.count > 1000 || name.count > 1000 || password.count > 1000 || bio.count > 1000 || confirmpassword.count > 1000 {
                returnVal = false
                errorMessage = "None of the fields on this page may exceed 1000 characters in length."
            
        }
        
        if returnVal == false {
            let alertView = SPAlertView(title: "Something is off...", message: errorMessage, preset: SPAlertPreset.exclamation)
            alertView.duration = 3
            alertView.present()
        }
        return returnVal
    }
    
    
    func executeUpdate(){
        
        var modifiableUser = self.user_forPage
        modifiableUser.username = self.username
        modifiableUser.password = self.password
        modifiableUser.bio = self.bio
        modifiableUser.name = self.name
        
        //This will keep track of everything we need to do
        
        var tasksToComplete = 5
        ///They are:
            ///(1) update the comments
            ///(2) update the published recipes
            ///(3) update the follower
            ///(4) update the following
            ///(5) update the actual "user" document
        
        func checkCompletion(){
            print("tasks left = \(tasksToComplete)")
            if tasksToComplete == 0 {
                withAnimation{
                    self.showLoader(false)
                }
                
                println("user updated")
                let alertView = SPAlertView(title: "Updated!", message: "We updated your profile!", preset: SPAlertPreset.done)
                alertView.duration = 3
                alertView.present()
                self.loadData(minimumRecency: CacheDuration.Now)
            }
        }
        
        func update_allComments(){
            println("batch updating all comments",0)
            let batch = Firestore.firestore().batch()
            
            Firestore.firestore().collectionGroup("comments").whereField("commentingUser.id", isEqualTo: self.user_forPage.id.uuidString).getDocuments { (querySnapshot,err) in
                if let err = err {
                    let alertView = SPAlertView(title: "Something went wrong", message: "err: sadg9 79tei", preset: SPAlertPreset.error)
                    alertView.duration = 3
                    alertView.present()
                    println(err, 0)
                } else {
                    for document in querySnapshot!.documents {
                        let thisRef = document.reference
                        batch.updateData(["commentingUser":self.user_forPage.truncForm.dictionary.value], forDocument: thisRef)
                    }
                    
                    print("committing batch - comments")
                    // Commit the batch
                    batch.commit() { err in
                        if let err = err {
                            println("Error writing batch \(err)", 0)
                        } else {
                            print("Batch write succeeded.")
                        }
                        tasksToComplete = tasksToComplete - 1
                        checkCompletion()
                    }
                    
                }
                
            }
            
        }
        
        func update_publishedRecipes(){
            println("batch updating all publishedRecipes",0)
            let batch = Firestore.firestore().batch()
            
            Firestore.firestore().collectionGroup("recipe").whereField("postingUser.id", isEqualTo: self.user_forPage.id.uuidString).getDocuments { (querySnapshot,err) in
                if let err = err {
                    let alertView = SPAlertView(title: "Something went wrong", message: "err: sadg9 79tei", preset: SPAlertPreset.error)
                    alertView.duration = 3
                    alertView.present()
                    println(err, 0)
                } else {
                    for document in querySnapshot!.documents {
                        let thisRef = document.reference
                        batch.updateData(["postingUser":self.user_forPage.truncForm.dictionary.value], forDocument: thisRef)
                    }
                    print("committing batch - publishedRecipes")
                    // Commit the batch
                    batch.commit() { err in
                        if let err = err {
                            println("Error writing batch \(err)", 0)
                        } else {
                            print("Batch write succeeded.")
                        }
                        tasksToComplete = tasksToComplete - 1
                        checkCompletion()
                    }
                    
                }
                
            }
        }
        
        func update_followers(){
            
            println("batch updating all publishedRecipes",0)
            let batch = Firestore.firestore().batch()
            
            Firestore.firestore().collectionGroup("followers").whereField("id", isEqualTo: self.user_forPage.id.uuidString).getDocuments { (querySnapshot,err) in
                if let err = err {
                    let alertView = SPAlertView(title: "Something went wrong", message: "err: sadg9 79tei", preset: SPAlertPreset.error)
                    alertView.duration = 3
                    alertView.present()
                    println(err, 0)
                } else {
                    for document in querySnapshot!.documents {
                        let thisRef = document.reference
                        batch.setData(self.user_forPage.fireBaseFormat, forDocument: thisRef)
                    }
                    print("committing batch - followers")
                    // Commit the batch
                    batch.commit() { err in
                        if let err = err {
                            println("Error writing batch \(err)", 0)
                        } else {
                            print("Batch write succeeded.")
                        }
                        tasksToComplete = tasksToComplete - 1
                        checkCompletion()
                    }
                    
                }
                
            }
        }
        
        func update_following(){
            
            println("batch updating all publishedRecipes",0)
            let batch = Firestore.firestore().batch()
            
            Firestore.firestore().collectionGroup("following").whereField("id", isEqualTo: self.user_forPage.id.uuidString).getDocuments { (querySnapshot,err) in
                if let err = err {
                    let alertView = SPAlertView(title: "Something went wrong", message: "err: sadg9 79tei", preset: SPAlertPreset.error)
                    alertView.duration = 3
                    alertView.present()
                    println(err, 0)
                } else {
                    for document in querySnapshot!.documents {
                        let thisRef = document.reference
                        batch.setData(self.user_forPage.fireBaseFormat, forDocument: thisRef)
                    }
                    print("committing batch - following")
                    // Commit the batch
                    batch.commit() { err in
                        if let err = err {
                            println("Error writing batch \(err)", 0)
                        } else {
                            print("Batch write succeeded.")
                        }
                        tasksToComplete = tasksToComplete - 1
                        checkCompletion()
                    }
                    
                }
                
            }
        }
        
        self.isShown = false
        self.showLoader(true)
        DispatchQueue.global(qos: .background).async {
            firestoreUpdate_data(
                docRef_string: "users/\(self.user_forPage.id.uuidString)",
                dataToUpdate: [
                    "bio": self.bio,
                    "username": self.username,
                    "password":self.password,
                    "name":self.name,
                    "tags_name":self.name.alphanumerics_andWhiteSpace.lowercased().components(separatedBy: " "),
                    "lowercased_name":self.name.alphanumerics_andWhiteSpace.lowercased(),
                    "lowercased_username":self.username.alphanumerics_andWhiteSpace.lowercased(),
                ],
                completion: {outcome,_  in
                    
                    if outcome == .success {
                        tasksToComplete = tasksToComplete - 1
                        update_publishedRecipes()
                        update_followers()
                        update_following()
                        update_allComments()
                        
                    } else {
                        println("issue updating user")
                        let alertView = SPAlertView(title: "Hmmm...", message: "Something went wrong. Please let us know and we'll make sure it doesn't happen again.", preset: SPAlertPreset.error)
                        alertView.duration = 3
                        alertView.present()
                    }
                    
            })
            
            
            
            
            
            
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    }
}

//struct UserEditProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserEditProfileView(user_forPage: user(), isShown: .constant(true))
//    }
//}
