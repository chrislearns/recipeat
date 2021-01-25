//
//  NewPostView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 3/10/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import SPAlert

struct NewPostView: View {
    
    @EnvironmentObject var env: GlobalEnvironment
    
    @State var show_reviewSheet = false
    @State var showSheet = false
    @State var showDeleteSheet = false
    @State var showImagePicker = false
    @State var sourceType:UIImagePickerController.SourceType = .camera
    @State private var images:[Identifiable_UIImage] = []
    var developing = true
//    @State var halfModal_shown = false
    @State var halfModal_height:CGFloat = 380
    
    @State var halfModal_title = ""
    @State var halfModal_textField_placeholder = ""
    @State var halfModal_textField1_val = ""
    @State var halfModal_textField2_val = ""
    @State var showEditor = false
    
    @State var newItem_type:new_StepOrIngredient = .Step
    @State var ingredientUnit_index = 0
    @State var editingComponent:Int? = nil
    
    @State var gallery_photoPickerHeight:CGFloat = 200
    
    @State var newRecipePost = RecipePost()
    
    var body: some View {
        ZStack{
            NavigationLink(destination:
                            ModifyRecipePost(binding_recipePost: self.$newRecipePost, images:self.$images, isShown: self.$show_reviewSheet,
                                              actionButton: ActionableButton(text: "SUBMIT RECIPE", moreScrollText: "SCROLL FOR STEPS", sfsymbol: "", action: {
                                                 _ in
                                                 print("saving recipe")
                                                 self.submitRecipe()
                                                 
                                              })
                             )
                           , isActive: self.$show_reviewSheet){
                EmptyView()
            }
//            NavigationView{
            VStack(spacing:0){
//                Spacer().frame(height:65)
                
                ZStack{
                    if images.count > 0 {
                        GalleryView(
                            galleryHeight: UIScreen.main.bounds.height/3,
                            galleryWidth: UIScreen.main.bounds.width,
                            imageWidth: UIScreen.main.bounds.height/3,
                            imageHeight: (UIScreen.main.bounds.height/3) - 30,
                            spacing: 10,
                            contents: images
                        )
                            .background(Color.init(white:0.95))
                    } else {
                        Button(action: {
                            self.showSheet.toggle()
                        }) {
                            VStack(spacing: 10){
                                
                                
                                Image("cookBook")
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.horizontal, 30)
                                Text("Press here to pick some photos!")
                                    .foregroundColor(Color.init(white: 0.7))
                                    .font(.system(size: 14))
                                    .multilineTextAlignment(.center)
                                
                            }
                            .padding(.horizontal, 110)
                            .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.height/3)
                            .background(Color.init(white:0.95))
                        }
                    }
                    
                    VStack{
                        HStack{
                            Button(action: {
                                self.showDeleteSheet.toggle()
                            }) {
                                
                                Text("+ RESTART")
                                
                                
                                //
                            }.buttonStyle(CapsuleStyle(bgColor: darkPink, fgColor: Color.white, fontSize: 12, hPadding: 10, height: 24)).opacity(0.7)
                                .actionSheet(isPresented: $showDeleteSheet){
                                    ActionSheet(title: Text("Delete your creation?"), message: Text(""), buttons: [
                                        .default(Text("Delete Post"), action: {self.clearPage()}),
                                        .cancel()
                                    ])
                            }
                            Spacer()
                            
                            Button(action: {
                                self.showSheet.toggle()
                            }) {
                                if images.count > 0 {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 23))
                                        .foregroundColor(.black)
                                        .background(Circle().foregroundColor(Color.white).frame(width: 35, height: 35))
                                        .shadow(radius: 4)
                                        .opacity(0.7)
                                        .padding()
                                } else {
                                    Text("")
                                }
                                
                            }.actionSheet(isPresented: $showSheet){
                                ActionSheet(title: Text("Add a picture to your post"), message: nil, buttons: [
                                    .default(Text("Photo Library"), action: {
                                        self.showImagePicker = true
                                        self.sourceType = UIImagePickerController.SourceType.photoLibrary
                                    }),
                                    .cancel()
                                    
                                ])
                                
                            }
                        }
                        Spacer()
                    }.frame(height:UniversalSquare.height/3)
                }.frame(height: UniversalSquare.height/3)
                    .sheet(isPresented: $showImagePicker){
                        ZStack{
                            VStack{
                                //This spacer height is based off the gallery having a height of 170 and the annoying header on the imagepicker that im trying to hide which has a height of 57
                                Spacer().frame(height: self.gallery_photoPickerHeight-57)
                                    .animation(.easeInOut)
                                if !self.showEditor{
                                    imagePicker(images: self.$images,
                                                multiplicity: PickerMultiplicityType.Multiple,
                                                pickedClosure: {imagesPicked in
                                                    print("selected a picture")
                                                    print(imagesPicked)
                                                    withAnimation{self.showEditor = true}
                                                    self.gallery_photoPickerHeight = UniversalSquare.width
                                    },
                                                sourceType: self.sourceType)
                                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2))).zIndex(1)
                                } else {
                                    VStack(spacing:0){
                                        Spacer()
                                        Button(action: {
                                            withAnimation{self.showEditor = false}
                                            self.gallery_photoPickerHeight = 200
                                        }){
                                            VStack{
                                                //                                        Image("foodpicture")
                                                //                                            .renderingMode(.template)
                                                //                                            .resizable()
                                                //                                            .scaledToFit()
                                                //                                            .frame(width:80, height:80)
                                                //                                            .padding(.top, 40)
                                                HStack{
                                                    Image(systemName: "plus.circle")
                                                    Text("ADD ANOTHER PICTURE")
                                                }
                                                .font(.system(size: 18, weight: .semibold))
                                                
                                            }
                                            .foregroundColor(darkGreen)
                                            .padding(.horizontal, 10).padding(.vertical, 7)
                                            .background(Color.init(white: 1))
                                                
                                            .cornerRadius(8)
                                            .shadow(radius: 2)
                                            
                                        }
                                        Spacer()
                                        HStack{
                                            Text("FILTERS (Coming Soon)")
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(Color.init(white: 0.7))
                                        }.frame(width: UniversalSquare.width, height: 80).background(LinearGradient(gradient: Gradient(colors: [Color.init(white:0.8).opacity(0.7),Color.init(white:0.8).opacity(0)]), startPoint: .top, endPoint: .bottom))
                                    }.transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2))).zIndex(1)
                                }
                                
                            }
                            VStack(spacing:0){
                                if self.images.count > 0 {
                                    GalleryView(
                                        actionButton: ActionableButton(text: nil, sfsymbol: "xmark.circle.fill", action: {returnAny in
                                            if let imageIndex = returnAny as? Int {
                                                print("\(returnAny)")
                                                self.images.remove(at: imageIndex)
                                            } else {
                                                print("Couldn't remove image - action return value = \(returnAny)")
                                            }
                                            
                                        }),
                                        galleryHeight: self.gallery_photoPickerHeight,
                                        galleryWidth: UniversalSquare.width,
                                        imageWidth: self.gallery_photoPickerHeight - (self.showEditor ? 0 : 20),
                                        imageHeight: self.gallery_photoPickerHeight - (self.showEditor ? 0 : 20),
                                        spacing: 10,
                                        contents: self.images
                                    )
                                        .background(Color.init(white:0.95))
                                        .shadow(color: Color.black.opacity(0.3), radius: 3, y: 3)
                                        .animation(.easeInOut)
                                } else {
                                    HStack{
                                        Spacer()
                                        Text("Please select images from below")
                                            .foregroundColor(Color.white)
                                        Spacer()
                                    }.frame(height:self.gallery_photoPickerHeight)
                                        .background(Color.black)
                                        .shadow(color: Color.black, radius: 5, y: 3)
                                }
                                
                                Spacer()
                            }
                            VStack{
                                HStack{
                                    Button(action: {self.showImagePicker.toggle()}){
                                        
                                        Text("Back to Recipe")
                                        
                                        
                                        
                                    }.buttonStyle(CapsuleStyle(bgColor: lightGreen, fgColor: Color.white, fontSize: 16, hPadding: 10, height: 28)).padding()
                                    Spacer()
                                }
                                Spacer()
                            }
                            
                        }
                }.background(Color.init(white: 247/255)).zIndex(10)
                VStack{
                    
//                    TimeAndServingsView(estimatedServings: self.$newRecipePost.estimatedServings, timePrep: self.$newRecipePost.timePrep, timeCook: self.$newRecipePost.timeCook, timeOther: self.$newRecipePost.timeOther, standardTF: true, midSpacer: 20)
                    Spacer().frame(height: 1)
                    Button(action: {
                        self.show_reviewSheet = true
                        //self.submitRecipe()
                    }) {
                        Text("NEXT").zIndex(30)
                        
                    }.buttonStyle(CapsuleStyle(bgColor: darkGreen, fgColor: Color.white))
//                        .padding(.bottom, 10)
//                        .sheet(isPresented: $show_reviewSheet){
//
//                            ModifyRecipePost(binding_recipePost: self.$newRecipePost, images:self.$images, isShown: self.$show_reviewSheet,
//                                             actionButton: ActionableButton(text: "SUBMIT RECIPE", moreScrollText: "SCROLL FOR STEPS", sfsymbol: "", action: {
//                                                _ in
//                                                print("saving recipe")
//                                                self.submitRecipe()
//
//                                             })
//                            )
//
//                    }
                    
                    Spacer().frame(height:20)
                }
                Spacer().frame(height: self.env.tabBarHeight)
            }.navigationBarTitle("").navigationBarHidden(true)
                
//                .sheet(isPresented: $halfModal_shown){
//                    AddNewComponent_View(newItem_type: self.newItem_type, bindable_RP: self.$newRecipePost, hideFunc: {_ in
//                        UIApplication.shared.endEditing()
//                        self.halfModal_shown = false
//                        self.update_halfModal(itemType: .Ingredient, height: 300)
//                    }, editingComponent: self.$editingComponent, initialEditingVals_haveBeenSet: .constant(true))
//
//            }
            
            
//            HalfModalView(isShown: $halfModal_shown, modalHeight:halfModal_height){
//
//            }
//        }
        }
    }
    
    func update_halfModal(itemType:new_StepOrIngredient, height:CGFloat){
        newItem_type = itemType
        halfModal_height = height
    }
    
    
    
    
    
    func clearPage(){
        images.removeAll()
        newRecipePost = RecipePost()
    }
    
    func submitRecipe(){
        var actionsToComplete = 2 + self.images.count
        var actionsCompleted = 0
        func check_success(){
            print("Tasks Completed: \(actionsCompleted)/\(actionsToComplete)")
            if actionsCompleted == actionsToComplete {
                
                self.env.subscribeToTopic("recipe_\(self.newRecipePost.id.uuidString)_comments")
                self.env.subscribeToTopic("recipe_\(self.newRecipePost.id.uuidString)_likes")
                
                //Add a function to clear all the data on this page
                let alertView = SPAlertView(title: "Recipe Submitted", message: "Recipe submitted successfully!", preset: SPAlertPreset.done)
                alertView.duration = 3
                alertView.present()
                self.clearPage()
                
                withAnimation{
                    self.env.loaderShown = false
                }
            }
        }
        if let string = validateRecipe(newRecipePost, images){
            let alertView = SPAlertView(title: "Hold up!", message: string, preset: SPAlertPreset.exclamation)
            alertView.duration = 3
            alertView.present()
            
        } else {
            self.show_reviewSheet = false
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) {_ in
                withAnimation{
                    self.env.loaderShown = true
                }
                UIApplication.shared.endEditing()
                DispatchQueue.global(qos: .background).async {
                    self.newRecipePost.dateCreate = currentTime_UTC()
                    self.newRecipePost.postingUser = self.env.currentUser.truncForm
                    let thisRecipePost = self.newRecipePost
                    print(thisRecipePost.fireBaseFormat)
                    
                    
                    
                    
                    firestoreSubmit_data(docRef_string: "recipe/\(thisRecipePost.id.uuidString)", dataToSave: thisRecipePost.fireBaseFormat, completion: {_ in
                        actionsCompleted += 1
                        check_success()
                    })
                    firestoreSubmit_data(docRef_string: "users/\(self.env.currentUser.id.uuidString)/publishedRecipes/\(thisRecipePost.id.uuidString)", dataToSave: thisRecipePost.fireBaseFormat, completion: {_ in
                        actionsCompleted += 1
                        check_success()
                    })
                    
                    for i in 0...self.images.count-1 {
                        let image = self.images[i].image
                        uploadImage("recipe/\(thisRecipePost.id)/img\(i)", image: image.raw, completion: {outcome, secondObject  in
                            if outcome == .failed {
                                let alertView = SPAlertView(title: "Hmmm...", message: "We had an issue uploading your picture. Err - \(secondObject)", preset: SPAlertPreset.error)
                                alertView.duration = 3
                                alertView.present()
                            }
                            actionsCompleted += 1
                            check_success()
                        })
                    }
                }
            }
        }
    }
}








struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView()
    }
}

