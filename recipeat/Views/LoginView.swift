//
//  LoginView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 3/3/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import FirebaseFirestore
import Firebase
import SPAlert

struct LoginView: View {
    @EnvironmentObject var env: GlobalEnvironment
    @State private var signUp_visible = false
    @State private var forgotPassword_visible = false
    @State private var username:String = ""
    @State private var password:String = ""
    
    
    
    
    var body: some View {
        
        ZStack{
            //Background
            LoginBackground().opacity(0.5)
            //Gradient
            LinearGradient(gradient: Gradient(colors: [
                Color.white.opacity(0.01),
                Color.white.opacity(0.8),
            ]), startPoint: .top, endPoint: .bottom)
            VStack(spacing:0){
                Image("logoIcon_red_drop")
                    .resizable()
                    .scaledToFit()
                    .frame(width:4 * UIScreen.main.bounds.size.width/5, height:4 * UIScreen.main.bounds.size.width/5)
                
                VStack(spacing:0){
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .padding().background(Color.clear)
                        .frame(height:50)
                        .padding(5)
                    Rectangle()
                        .frame(height:1)
                        .foregroundColor(Color.init(white: 0.8))
                    SecureField("Password", text: $password)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.clear)
                        .frame(height:50)
                        .padding(5)
                }
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1).foregroundColor(Color.init(white: 0.8)))
                    .padding()
                
                
                
                
                Button(action: {
                    withAnimation{
                        self.env.loaderShown = true
                    }
                    
                    UIApplication.shared.endEditing()
                    Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) {_ in
                        DispatchQueue.global(qos: .background).async {
                            print("searching for user: \(self.username)")
                            Firestore.firestore().collection("users").whereField("username", isEqualTo: self.username).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                    withAnimation{
                                        self.env.loaderShown = false
                                    }
                                } else {
                                    
                                    if querySnapshot!.documents.count <= 0 {
                                        let alertView = SPAlertView(title: "No users found", message: "No users have the username you entered", preset: SPAlertPreset.error)
                                        alertView.duration = 3
                                        alertView.present()
                                        withAnimation{
                                            self.env.loaderShown = false
                                        }
                                    } else if querySnapshot!.documents.count > 1 {
                                        let alertView = SPAlertView(title: "Something went wrong", message: "Multiple accounts exist with this username", preset: SPAlertPreset.error)
                                        alertView.duration = 3
                                        alertView.present()
                                        withAnimation{
                                            self.env.loaderShown = false
                                        }
                                    } else {
                                        
                                        for document in querySnapshot!.documents {
                                            print("\(document.documentID) => \(document.data())")
                                            if document.data()["password"] as? String ?? "" == (self.password) {
                                                if let loadedUser_UUID = UUID(uuidString: document.documentID) {
                                                    self.env.currentUser = document.data().toUser(formerUUID: loadedUser_UUID)
                                                    //LOGIN HAPPENS HERE! - This is where you are right before you flip to the next screen
                                                    self.env.save_UserDefaults()
                                                    self.env.initializeListener_currentUser()
                                                    self.env.isLoggedIn = true
                                                    withAnimation{
                                                        self.env.loaderShown = false
                                                    }
                                                    
                                                } else {
                                                    let alertView = SPAlertView(title: "Login Error", message: "Info correct - error code: ch28d 9gh1k", preset: SPAlertPreset.error)
                                                    alertView.duration = 3
                                                    alertView.present()
                                                    withAnimation{
                                                        self.env.loaderShown = false
                                                    }
                                                }
                                            } else {
                                                let alertView = SPAlertView(title: "Password doesn't match", message: nil, preset: SPAlertPreset.error)
                                                alertView.duration = 3
                                                alertView.present()
                                                withAnimation{
                                                    self.env.loaderShown = false
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                    
                }) {
                    HStack{
                        Text("Login")
                        Image(systemName: "arrow.right")
                    }
                    .frame(height:50)
                    .padding(.horizontal, 50)
                    .foregroundColor(.white)
                    
                }.background(lightGreen).cornerRadius(25)
                    .shadow(radius: 3, y: 3)
                    .padding(5)
                
                
                
                
                
                Spacer().frame(height:15)
                Button(action: {
                    self.signUp_visible.toggle()
                }) {
                    Text("Sign up")
                        
                }.buttonStyle(CapsuleStyle(bgColor: Color.white, fgColor: darkGreen))
                    .sheet(isPresented: $signUp_visible, content: {SignUp(closure: {showLoader in self.env.loaderShown = showLoader}, isShown: self.$signUp_visible)})
                Spacer().frame(height:15)
                Button(action: {
                    self.forgotPassword_visible = true
                }) {
                    Text("Forgot your password?")
                }
            .foregroundColor(darkGreen)
                .sheet(isPresented: self.$forgotPassword_visible, content: {ForgotPasswordView(isShown: self.$forgotPassword_visible)})
                Spacer().frame(height:150)
            }
            .KeyboardAwarePadding()
            .animation(.easeInOut(duration: 0.25))
            
        }
    }
    
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
