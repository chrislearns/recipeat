//
//  NewPost_TagView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 10/20/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import SPAlert

struct NewPost_TagView: View {
    @EnvironmentObject var recipeObject:RecipeObject
    @EnvironmentObject var env: GlobalEnvironment
    
    @State var reg_bannerData:BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Success)
    @State var reg_bannerShown:Bool = false
    
    @State var showactivityIndicator = false
    @Binding var isEditing:Bool
    @Binding var shown:Bool
    var body: some View {
        TagListView(
            closure: {
            tagEntities in
            print(tagEntities)
                self.recipeObject.recipe.tags = tagEntities
        }
        )
        .banner(data: $reg_bannerData, show: $reg_bannerShown)
        .navigationBarTitle("Add Tags", displayMode: .inline)
        .navigationBarItems(
            trailing:
                    ZStack{
                            Button(action: {
                                if isEditing {
                                    
                                        if let string = validateRecipe(self.recipeObject.recipe, self.recipeObject.media){
                                            reg_bannerData = BannerModifier.BannerData(title: "Almost done...", detail: string, type: .Error)
                                            withAnimation{
                                                reg_bannerShown = true
                                            }
                                            
                                        } else {
                                            updateRecipe(update_recipe: self.recipeObject.recipe, update_publishingUser: self.env.currentUser, completion: {_ in
                                                print("update successful")
                                                reloadRecipe(recipeString: self.recipeObject.recipe.id.uuidString, completion: {fetched_RP in
                                                                self.recipeObject.recipe = fetched_RP})
                                                
                                                showactivityIndicator = false
                                                self.shown = false
//                                                self.shown = false// 8888888 DELETE THIS and replce!
                                                self.env.bDataTabbedRoot = BannerModifier.BannerData(title: "Success!", detail: "Your recipe has been added! Refresh to see it.", type: .Success)
                                                self.env.bToggleTabbedRoot = true
                                                
                                            })
//                                            self.modifyingRecipe = false
                                        }
                                    
                                } else {
                                var actionsToComplete = 2 + self.recipeObject.media.count
                                var actionsCompleted = 0
                                func check_success(){
                                    print("Tasks Completed: \(actionsCompleted)/\(actionsToComplete)")
                                    if actionsCompleted == actionsToComplete {
                                        
                                        self.env.subscribeToTopic("recipe_\(self.recipeObject.recipe.id.uuidString)_comments")
                                        self.env.subscribeToTopic("recipe_\(self.recipeObject.recipe.id.uuidString)_likes")
                                        
                                        //Add a function to clear all the data on this page
                                        
//                                        self.clearPage()
                                        
                                        withAnimation{
//                                            self.env.loaderShown = false
                                            showactivityIndicator = false
//                                            self.shownew = false 88888888
                                            self.shown = false
                                            self.env.bDataTabbedRoot = BannerModifier.BannerData(title: "Success!", detail: "Your recipe has been added! Refresh to see it.", type: .Success)
                                            self.env.bToggleTabbedRoot = true
                                            
                                            //******************* THIS CODE deletes the recipe from drafts (if thats where it came from) if you've succesffully uplaoded it
                                            
                                            
                                                //This makes sure that if you delete a draft that you were working on, you cant keep editing the draft after you've finalized it
                                            
                                            
                                            
                                            let load_attempt = loadImage_draft(associatedRecipeUUID: recipeObject.recipe.id.uuidString)
                                            if let images = load_attempt{
                                                delete_NSManagedObjects(objects: images, objectType: "DraftImage", completion: {
                                                    print("images for draft deleted")
                                                })
                                                
                                            } else {
                                                print("no images assoc with this recipe draft to delete")
                                            }
                                            
                                            print("deleting draft \(recipeObject.recipe.id.uuidString)")
                                            self.env.unfinishedRecipes[recipeObject.recipe.id.uuidString] = nil
                                            self.env.sync_unfinishedRecipes()
                                            print("delete")
                                            
                                            recipeObject.recipe = RecipePost()
                                            recipeObject.media = []
                                            
                                            //****************************
                                        }
                                    }
                                }
                                
                                print(self.recipeObject.recipe.tags)
                                print("Tags - \(self.recipeObject.recipe.tags.count)")
                                if self.recipeObject.recipe.tags.count > 0 {
//                                    CODE NEEDS TO GO HERE FOR RECIPE SUBMISSION and VALIDATION
                                    if let errorString = validateRecipe(self.recipeObject.recipe, self.recipeObject.media) {
                                        reg_bannerData = BannerModifier.BannerData(title: "Let's double check...", detail: errorString, type: .Error)
                                        withAnimation{
                                            reg_bannerShown = true
                                        }
                                    } else {
                                        print("recipeValid")
                                        showactivityIndicator = true
                                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                                            
                                            self.recipeObject.recipe.dateCreate = currentTime_UTC()
                                            self.recipeObject.recipe.postingUser = self.env.currentUser.truncForm
                                            let thisRecipePost = self.recipeObject.recipe
                                            print(thisRecipePost.fireBaseFormat)

                                
                                            firestoreSubmit_data(docRef_string: "recipe/\(thisRecipePost.id.uuidString)", dataToSave: thisRecipePost.fireBaseFormat, completion: {_ in
                                                actionsCompleted += 1
                                                check_success()
                                            })
                                            firestoreSubmit_data(docRef_string: "users/\(self.env.currentUser.id.uuidString)/publishedRecipes/\(thisRecipePost.id.uuidString)", dataToSave: thisRecipePost.fireBaseFormat, completion: {_ in
                                                actionsCompleted += 1
                                                check_success()
                                            })

                                //Cycle through media and begin uploading images and videos
                                for i in 0...self.recipeObject.media.count-1 {
                                    if let im = self.recipeObject.media[i].media as? Identifiable_UIImage {
                                        let image = im.image.filtered == nil ? (im.image.croppedImage == nil ?
                                        im.image.raw :
                                        im.image.croppedImage!) :
                                        im.image.filtered!
                                        uploadImage("recipe/\(thisRecipePost.id)/img\(i)", image: image, completion: {outcome, secondObject  in
                                                if outcome == .failed {
                                                    let alertView = SPAlertView(title: "Hmmm...", message: "We had an issue uploading your picture. Err - \(secondObject)", preset: SPAlertPreset.error)
                                                    alertView.duration = 3
                                                    alertView.present()
                                                }
                                                actionsCompleted += 1
                                                check_success()
                                            })
                                } else
                                    if let vid = self.recipeObject.media[i].media as? Identifiable_Video {
                                        uploadVideo(localURL: vid.videoLocation, firebaseURL: "recipe/\(thisRecipePost.id)/vid\(i)", uploadCompletion: {outcome, secondObject  in
                                            if outcome == .failed {
                                                let alertView = SPAlertView(title: "Hmmm...", message: "We had an issue uploading your picture. Err - \(String(describing: secondObject))", preset: SPAlertPreset.error)
                                                alertView.duration = 3
                                                alertView.present()
                                            }
                                            actionsCompleted += 1
                                            check_success()
                                        })
                                    }
                                }

                                print("Submitting")
                                print("\(self.recipeObject.media.count) images/videos")
                                print(self.recipeObject.recipe.fireBaseFormat)
                                            
                                        }
                                    }


                                                
                                } else {
                                    reg_bannerData = BannerModifier.BannerData(title: "Almost done!", detail: "Make sure to add at least one tag in order to submit your recipe.", type: .Error)
                                    withAnimation{
                                        reg_bannerShown = true
                                    }
                                }
                            }
                            }){
                                Text("Submit")
//                                    .foregroundColor(self.recipeObject.recipe.tags.count > 0 ? Color.blue : Color.gray)
                                    .foregroundColor(.blue)
                            }
                                
                        
                    }
                )
        .fullScreenCover(isPresented: self.$showactivityIndicator){
            
            CustomActivityIndicator()
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2))).zIndex(1)
                .animation(
                    Animation.easeInOut(duration: 0.2)
            )
            
//            Button(action: {showactivityIndicator = false}){
//
//            }
        }
    }
    func clearPage(){
        self.recipeObject.media.removeAll()
        self.recipeObject.recipe = RecipePost()
    }
}

struct TagListView: View {
    
//    @EnvironmentObject var env: GlobalEnvironment
    
//    @Binding var newRecipePost:RecipePost
    @EnvironmentObject var recipeObject:RecipeObject
    
    var closure:([TagEntity]) -> Void
    
    @State var tagObjects:[TagEntity] = FoodTagDictionary.map{
        $0.value
    }.sorted{ $0.displayVal < $1.displayVal}
    
    @State var selectedTags:[TagEntity] = []
    
    var body: some View {
        ZStack{
                VStack{
                    Text("Select at least one tag")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.init(white: 0.5))
                        .padding(5)
                    List{
                        ForEach(tagObjects, id: \.id){tagObject in
                            Button(action: {
                                DispatchQueue.main.async {
                                    if let i = self.recipeObject.recipe.tags.firstIndex(where: {$0.dbVal == tagObject.dbVal}){
                                        print("removing tag \(tagObject.dbVal)")
                                        self.recipeObject.recipe.tags.remove(at: i)
                                        selectedTags.remove(at: i)
                                        print("recipeTags = \(self.recipeObject.recipe.tags)")
                                    } else {
                                        print("adding tag \(tagObject.dbVal)")
                                        self.recipeObject.recipe.tags.append(tagObject)
                                        selectedTags.append(tagObject)
                                        print("recipeTags = \(self.recipeObject.recipe.tags)")
                                    }
//                                    self.tagObjects[self.tagObjects.getIndexOf(tagObject)].selected.toggle()
                                }
                                
                            }){
                                HStack{
                                    Text("\(tagObject.displayVal)")
                                        .animation(.easeInOut(duration: 0.3))
                                    if selectedTags.firstIndex(where: {$0.dbVal == tagObject.dbVal}) != nil {
                                        Image(systemName: "checkmark.circle")
                                            .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
                                            .animation(.easeInOut(duration: 0.3))
                                    }
                                }.foregroundColor(selectedTags.first(where: {$0.dbVal == tagObject.dbVal}) != nil ? darkGreen : Color.black)
                                .onAppear(){
                                    print("selectedTags - onappear" + "\(self.recipeObject.recipe.tags)")
                                    selectedTags = self.recipeObject.recipe.tags
                                }
                                
                            }
                        }
                    }.padding(.vertical, 15)
                        .overlay(
                            VStack{
                                
                                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(1),Color.white.opacity(0)]), startPoint: .top, endPoint: .bottom).frame(height: 35)
                                Spacer()
                                
                                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0),Color.white.opacity(1)]), startPoint: .top, endPoint: .bottom).frame(height: 35)
                            }.frame(width: UniversalSquare.width)
                    )
                    
                    
                    //                        FloatingTagsView(tagObjects: tagObjects, tagRows: $tagObjectLists)
                    
//                    Button(action: {
//                        //                    var allTaggedObjects:[TagObject] = []
//                        //                    allTaggedObjects = .filter{$0.selected == true}
//                        ////                    for TO_list in self.tagObjectLists {
//                        ////                        allTaggedObjects = allTaggedObjects + TO_list.tagEntities
//                        ////                    }
//                        let selectedEntities = self.tagObjects.filter{$0.selected == true}.map{$0.tagEntity}
//                        
//                        self.closure(selectedEntities)
//                    }) {
//                        Text("SAVE")
//                    }
//                        .zIndex(20)
//                        .buttonStyle(CapsuleStyle(bgColor: darkGreen, fgColor: Color.white, height: 50))
//                        .padding(.bottom, 20)
                    
                }
                .padding(.vertical).padding(.horizontal, 15)
                    
                .clipped()
                
            
        }
    }
    
    
    
}

//struct NewPost_TagView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewPost_TagView()
//    }
//}
