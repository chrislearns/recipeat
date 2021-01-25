//
//  ForgotPasswordView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/15/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import Firebase
import SPAlert

struct ForgotPasswordView: View {
    @State private var username:String = ""
    @Binding var isShown:Bool
    
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
                    Text("FORGOT PASSWORD")
                        .font(.headline)
                        .foregroundColor(Color.init(white:0.3))
                        .padding(5)
                    
                    VStack(spacing:0){
                        TextField("Username", text: $username)
                            .autocapitalization(.none)
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
                    DispatchQueue.global(qos: .background).async {
                        Firestore.firestore().collection("users").whereField("username", isEqualTo: self.username).getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                let alertView = SPAlertView(title: "Something went wrong", message: "err: as9sd 438fa", preset: SPAlertPreset.error)
                                alertView.duration = 3
                                alertView.present()
                                print(err)
                            } else {
                                if querySnapshot!.documents.count == 0 {
                                    let alertView = SPAlertView(title: "No account is associated with that username", message: "Try another username", preset: SPAlertPreset.error)
                                    alertView.duration = 3
                                    alertView.present()
                                    print(err)
                                    self.isShown = false
                                    
                                    print("nobody has thisusername")
                                    
                                } else {
                                    
                                    if let loadedUser_UUID = UUID(uuidString: querySnapshot!.documents[0].documentID){
                                        let document = querySnapshot!.documents[0]
                                        let recoveringUser = document.data().toUser(formerUUID: loadedUser_UUID)
                                        print("unwrapped user - sending recovery message")
                                        recoverPassword(recoveringUser: recoveringUser)
                                        self.isShown = false
                                        
                                    } else {
                                        print("could not unwrap doc - \(querySnapshot?.documents[0].documentID)")
                                        self.isShown = false
                                        let alertView = SPAlertView(title: "Something went wrong", message: "Try contacting us at support@recipeat.app or try again later", preset: SPAlertPreset.error)
                                        alertView.duration = 3
                                        alertView.present()
                                        
                                        print(err)
                                        
                                    }
                                    
                                    
                                    
                                    
                                    
                                    
                                }
                            }
                            
                        }
                        
                    }
                }) {
                    Text("Recover Password")
                }.buttonStyle(CapsuleStyle(bgColor: .white, fgColor: darkGreen))
                Spacer().frame(height:50)
            }.padding(30)
            
        }
    }
    
}

//struct ForgotPasswordView_Previews: PreviewProvider {
//    static var previews: some View {
//        ForgotPasswordView()
//    }
//}
//
