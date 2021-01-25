//
//  SignUp.swift
//  recipeat
//
//  Created by Christopher Guirguis on 3/3/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import Firebase
import SPAlert



struct SignUp: View {
    var closure:(Bool) -> Void
    @Binding var isShown:Bool
    @State private var name:String = ""
    @State private var username:String = ""
    @State private var password:String = ""
    @State private var confirmpassword:String = ""
    @State private var email:String = ""
    
    @State private var docRef:DocumentReference!
    
    var body: some View {
        ZStack {
            
            LoginBackground().opacity(0.4)
            //Gradient
            LinearGradient(gradient: Gradient(colors: [
                Color.white.opacity(0.1),
                Color.white.opacity(0.8),
            ]), startPoint: .top, endPoint: .bottom)
            VStack(spacing:0){
                VStack(spacing:0){                
                    Text("JOIN OUR FAMILY!")
                        .font(.headline)
                        .foregroundColor(Color.init(white:0.3))
                        .padding(5)
                    
                    VStack(spacing:0){
                        TextField("Name", text: $name)
                            .autocapitalization(.words)
                            .padding().background(Color.clear)
                            .frame(height:35)
                            .padding(5)
                        Rectangle().frame(height:1).foregroundColor(Color.init(white: 0.8))
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                            .padding().background(Color.clear)
                            .frame(height:35)
                            .padding(5)
                            .keyboardType(.emailAddress)
                        Rectangle().frame(height:1).foregroundColor(Color.init(white: 0.8))
                        TextField("Username (3+ characters)", text: $username)
                            .autocapitalization(.none)
                            .padding().background(Color.clear)
                            .frame(height:35)
                            .padding(5)
                        Rectangle().frame(height:1).foregroundColor(Color.init(white: 0.8))
                        SecureField("Password (8+ characters)", text: $password)
                            .autocapitalization(.none)
                        .disableAutocorrection(true)
                            .padding().background(Color.clear)
                            .frame(height:35)
                            .padding(5)
                        Rectangle().frame(height:1).foregroundColor(Color.init(white: 0.8))
                        SecureField("Re-Enter Password (8+ characters)", text: $confirmpassword)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding().background(Color.clear)
                            .frame(height:35)
                            .padding(5)
                        
                    }
                        
                    .background(Color.white)
                        
                    .cornerRadius(10)
                    .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.init(white: 0.8)))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1).foregroundColor(Color.init(white: 0.8)))
                    .padding()
                }
                .KeyboardAwarePadding()
                .animation(.easeInOut(duration: 0.25))
                Spacer().frame(height:15)
                
                
                Button(action: {
                    if self.suView_tfValdiation() {
                        self.isShown = false
                        withAnimation{
                            self.closure(true)
                        }
                        DispatchQueue.global(qos: .background).async {
                            Firestore.firestore().collection("users").whereField("username", isEqualTo: self.username).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    let alertView = SPAlertView(title: "Something went wrong", message: "err: as9sd 438fa", preset: SPAlertPreset.error)
                                    alertView.duration = 3
                                    alertView.present()
                                    print(err)
                                    withAnimation{
                                        self.closure(false)
                                    }
                                } else {
                                    if querySnapshot!.documents.count == 0 {
                                        print("nobody has thisusername - creating account")
                                        let newUser = user(id: UUID(), username: self.username, password: self.password, name: self.name, email: self.email, publishedRecipes: [], following: [], followers: [], quantity_followers: 0, quantity_following: 0, bio: "", verified: false, likes: [], blocked:[], blockedBy:[], firstTimeUser: true, referralCode_distributal: randomString(length: 8), referralCode_claimed: "", flagged: false, hiddenContent: [], isAdmin: false)
                                        
                                        var unstampedData = newUser.fireBaseFormat
                                        unstampedData["dateCreate"] = currentTime_UTC()
                                        print("setting ref")
                                        self.docRef = Firestore.firestore().document("users/\(newUser.id.uuidString)")
                                        
                                        print("setting data")
                                        self.docRef.setData(unstampedData){ (error) in
                                            if let error = error {
                                                print("error = \(error)")
                                            } else {
                                                let alertView = SPAlertView(title: "Account created successfully", message: "We're excited you're here!", preset: SPAlertPreset.done)
                                                alertView.duration = 3
                                                alertView.present()
                                                withAnimation{
                                                    self.closure(false)
                                                    self.isShown = false
                                                }
                                                
                                                print("no error")
                                            }
                                        }
                                        
                                    } else {
                                        withAnimation{
                                            let alertView = SPAlertView(title: "Aww man!", message: "Looks like this username is already taken!", preset: SPAlertPreset.error)
                                            alertView.duration = 3
                                            alertView.present()
                                            withAnimation{
                                                self.closure(false)
                                            }
                                        }
                                    }
                                }
                                
                            }
                            
                        }
                    }
                }) {
                    Text("Sign up")
                }.buttonStyle(CapsuleStyle(bgColor: .white, fgColor: darkGreen))
                
                Spacer().frame(height:25)
                VStack(alignment: .leading, spacing: 8){
                Button(action: {
                    if let url = URL(string: "https://www.chrisguirguis.com/recipeat/terms.html") {
                       UIApplication.shared.open(url)
                   }
                }) {
                    Text("1. By signing up, you have read and agree with our ").foregroundColor(Color.black) + Text("Terms of Service").foregroundColor(lightGreen)
                }
                Button(action: {
                    if let url = URL(string: "https://www.chrisguirguis.com/recipeat/privacy.html") {
                       UIApplication.shared.open(url)
                   }
                }) {
                    Text("2. By signing up, you have read and agree with our ").foregroundColor(Color.black) + Text("Privacy Policy").foregroundColor(lightGreen)
                }
                Button(action: {
                    if let url = URL(string: "https://www.chrisguirguis.com/recipeat/eula.html") {
                       UIApplication.shared.open(url)
                   }
                }) {
                    Text("3. By signing up, you have read and agree with our ").foregroundColor(Color.black) + Text("End User License Agreement").foregroundColor(lightGreen)
                }
                }.font(.system(size: 12))
                
                Spacer().frame(height:50)
            }.padding(30)
            
        }
    }
    
    func suView_tfValdiation() -> Bool{
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
            errorMessage = "Pleas make sure both of your password fields are identical"
        } else if email.split(separator: "@").count != 2 {
            returnVal = false
            errorMessage = "Please enter a valid email address (i.e. ___@___.___)"
        } else if username.count > 1000 || name.count > 1000 || password.count > 1000 || confirmpassword.count > 1000 {
                returnVal = false
                errorMessage = "None of the fields on this page may exceed 1000 characters in length."
            
        }
        
        if returnVal == false {
            let alertView = SPAlertView(title: "I think we're missing something!", message: errorMessage, preset: SPAlertPreset.exclamation)
            alertView.duration = 3
            alertView.present()
        }
        return returnVal
    }
}

//struct SignUp_Previews: PreviewProvider {
//    static var previews: some View {
//        SignUp(isShown: .constant(true))
//    }
//}
