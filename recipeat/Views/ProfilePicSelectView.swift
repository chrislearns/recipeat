//
//  ProfilePicSelectView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/20/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import SPAlert

struct ProfilePicSelectView: View {
        @EnvironmentObject var env: GlobalEnvironment
        @Binding var user_forPage:user
        @State var showNext:Bool = false
        @State var uploading = false
    
        var dimensions = UniversalSquare.width - 200
        var closureAfterUpload:(completionHander_outcome) -> Void
    
        @State var showImagePicker_profilePic = false
    
        @State var imagePickerChosenPic:Identifiable_UIImage? = nil
        
    var body: some View {
        NavigationView{
            ZStack{
                
        Color.init(white: 247/255)
            VStack{
                                    Text("WELCOME")
                                        .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color.init(white: 0.5))
                                    Text("Choose a profile picture")
                                        .frame(width: UniversalSquare.width - 100)
                                        .multilineTextAlignment(.center)
                
                .frame(width: UniversalSquare.width - 100)
                    .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color.init(white: 0.5))
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
                Button(action: {
                    self.showImagePicker_profilePic = true
                    
                }){
                    Image(uiImage: imagePickerChosenPic?.image.raw ?? UIImage(named: "chefAvatar_plus")!)
                    .resizable()
                        .renderingMode(.original)
                    .scaledToFill()
                    .frame(width: dimensions, height: dimensions)
                    
                    
                    
                    
                        .cornerRadius(imagePickerChosenPic?.image.raw == nil ? 0 : dimensions/2)
                        .clipped()
                    .padding(.bottom, 30)
                }
                if uploading {
                    VStack {
                                ProgressView("Uploading…")
                            }
                } else {
                Button(action: {
//                    self.showNext = true
                    if self.imagePickerChosenPic != nil {
                        uploading = true
                        print("will upload pic here")
                        UIApplication.shared.endEditing()
                        self.env.loaderShown = true
                        DispatchQueue.main.async {
                            if let chosenPic = self.imagePickerChosenPic {
                                uploadImage("user/\(self.user_forPage.id.uuidString)/profilepicture", image: chosenPic.image.raw, completion: {outcome,anyObj in
                                    self.env.currentUser.firstTimeUser = false
                                    
                                    print("upload successful")
                                    firestoreUpdate_data(docRef_string: "users/\(self.user_forPage.id.uuidString)", dataToUpdate: [
                                        "firstTimeUser":self.env.currentUser.firstTimeUser
                                    ], completion: {_,_ in
                                        self.env.loaderShown = false
                                    })
                                    
                                    
                                    let alertView = SPAlertView(title: "Updated", message: "Your picture has been updated!", preset: SPAlertPreset.done)
                                    alertView.duration = 3
                                    alertView.present()
                                    
                                })
                                
                                
                            } else {
                                
                                let alertView = SPAlertView(title: "Error uploading profile picture", message: "err: vs592 vseo8", preset: SPAlertPreset.error)
                                alertView.duration = 3
                                alertView.present()
                                self.env.loaderShown = false
                            }
                        }
                        
                    }
                    
                    
                }){
                    Text("LET'S GET COOKIN'")
                    
                    
                }
                .buttonStyle(CapsuleStyle(bgColor: imagePickerChosenPic != nil ? darkGreen : Color.init(white: 0.7), fgColor: Color.white))
                }
                Spacer().frame(height: 130)
                
            }.sheet(isPresented: $showImagePicker_profilePic){
                    
                    
                    
                            imagePicker(images: .constant([]),
                                        allowsEditing: true,
                                        multiplicity: PickerMultiplicityType.Single ,
                                        pickedClosure: {imagesPicked in
                                            print("selected profile picture")
                                            print(imagesPicked)
                                            self.imagePickerChosenPic = imagesPicked
                                            self.showImagePicker_profilePic = false
                                            
                            },
                                        sourceType: .photoLibrary)
            }
        }.navigationBarTitle("Add Profile Picture", displayMode: .inline)
        }
        
    }
        
    }

struct FirstTime_BioView:View {
    @EnvironmentObject var env: GlobalEnvironment
    @Binding var imagePickerChosenPic:Identifiable_UIImage?
    var user_forPage:user
    @State var bioString = ""
    var body: some View {
        VStack{
            Spacer().frame(height: 15)
            Text("What do you want people to know about you?").padding(20)
                .multilineTextAlignment(.center)
        TextField("Bio", text: $bioString)
            .padding().background(Color.clear)
            .frame(height:35)
            .modifier(RoundedOutline())
            .padding()
        Button(action: {
            if self.imagePickerChosenPic != nil {
                print("will upload pic here")
                UIApplication.shared.endEditing()
                self.env.loaderShown = true
                DispatchQueue.main.async {
                    if let chosenPic = self.imagePickerChosenPic {
                        uploadImage("user/\(self.user_forPage.id.uuidString)/profilepicture", image: chosenPic.image.raw, completion: {outcome,anyObj in
                            self.env.currentUser.firstTimeUser = false
                            self.env.currentUser.bio = self.bioString
                            print("upload successful")
                            firestoreUpdate_data(docRef_string: "users/\(self.user_forPage.id.uuidString)", dataToUpdate: [
                                "bio":self.env.currentUser.bio,
                                "firstTimeUser":self.env.currentUser.firstTimeUser
                            ], completion: {_,_ in
                                self.env.loaderShown = false
                            })
                            
                            
                            let alertView = SPAlertView(title: "Updated", message: "Your picture has been updated!", preset: SPAlertPreset.done)
                            alertView.duration = 3
                            alertView.present()
                            
                        })
                        
                        
                    } else {
                        
                        let alertView = SPAlertView(title: "Error uploading profile picture", message: "err: vs592 vseo8", preset: SPAlertPreset.error)
                        alertView.duration = 3
                        alertView.present()
                        self.env.loaderShown = false
                    }
                }
                
            }
        })
            {
                Text("LET'S GET STARTED")
                
                
            }
            .buttonStyle(CapsuleStyle(bgColor: darkGreen, fgColor: Color.white))
            Spacer()
    }
    }
}

struct ProfilePicSelectView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePicSelectView(user_forPage: .constant(user()), closureAfterUpload: {outcome in})
    }
}
