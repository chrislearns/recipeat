//
//  PostView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 3/2/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import SPAlert


struct PostView: View {
    @EnvironmentObject var env: GlobalEnvironment
    
    var profileClosure:() -> Void
    var recipeClosure:() -> Void
    
    @Binding var this_truncRP:trunc_RecipePost
    
    @State var this_truncUser:trunc_user
    @State var this_fullUser:user?
    
    @State var loadedUserImage:UIImage?
    @State var loadedRecipeImage:UIImage?
    @State var showActionSheet = false
    @State var showReporting = false
    
    @State var showHeart = false
    
     
    
    var body: some View {
        VStack(spacing:0){
            ZStack{
                
                
                Image(uiImage: loadedRecipeImage == nil ? UIImage(named: "fishPlatter")! : loadedRecipeImage!)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: loadedRecipeImage == nil ? UniversalSquare.width/3 : UniversalSquare.width,
                        height:loadedRecipeImage == nil ? UniversalSquare.width/3 : UniversalSquare.width)
                    .clipped()
                    
                    
                    .overlay(loadedRecipeImage == nil ? nil : LinearGradient(gradient: Gradient(colors: [Color.clear,Color.clear, Color.black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                        )
                    .onTapGesture(count: 2, perform: {self.likeAction()})
                    .onTapGesture(count: 1, perform: {self.recipeClosure()})
                    
                
                VStack{
                    HStack(alignment: .top, spacing:0){
                        VStack(alignment: .leading, spacing:0){
                            Button(action: {self.profileClosure()}){
                                UserCapsule(username: $this_truncUser.username, image: $loadedUserImage)
                                    
                                    .padding(.top, 7)
                                    .padding(.leading, 7)
                            }
                            Button(action: {
                                self.likeAction()
                            }){
                                HStack(spacing:0){
                                    Image(systemName: userLikesRecipe(user: self.env.currentUser, recipe: this_truncRP) ? "heart.fill" : "heart")
                                        .font(.system(size: 20 ))
                                        
                                        .foregroundColor(userLikesRecipe(user: self.env.currentUser, recipe: this_truncRP) ? lightPink : Color.init(white: 0.5))
                                        .frame(width: 26, height: 26)
                                        
                                        .padding(.vertical, 5)
                                        .padding(.leading, 5)
                                        .padding(.trailing, 2)
                                    Text("\(this_truncRP.likes.count)")
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
                            
                        }
                        .opacity(this_truncRP.dateCreate == "empty" ? 0.5 : 1)
                        
                        Spacer()
                        Button(action: {
                            self.showActionSheet = true
                        }){
                            Image(systemName:"ellipsis.circle.fill")
//                                .font(.system(size: 25))
                            .resizable()
                                .frame(width: 30, height: 30)
                                
                                .foregroundColor(Color.white)
                                .background(Circle().foregroundColor(Color.black.opacity(0.8)))
                            .padding(7)
                            .opacity(0.7)
                        }
                        .actionSheet(isPresented: $showActionSheet){
                            ActionSheet(title: Text("More options"), message: Text("Choose an action from below"), buttons:
//
                                {
                                    var buttons:[ActionSheet.Button] = []
                                    buttons.append(ActionSheet.Button.default(Text("Share"), action: {
                                        let url = URL(string: "https://recipeat.app/?dest=recipe&context=\(self.this_truncRP.id.uuidString)")
                                        let av = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
                                        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
                                    }))
                                    buttons.append(ActionSheet.Button.default(Text("Hide Post"), action: {
                                        set_hiddenContent(directingUser: self.env.currentUser, contentID: self.this_truncRP.id, type: RecipeatEntity.Recipe)
                                    }))


                                        buttons.append(ActionSheet.Button.destructive(Text("Report").foregroundColor(.red), action: {
                                            self.showActionSheet = false
                                            self.showReporting = true
                                        }
                                            )
                                        )
                                    buttons.append(ActionSheet.Button.cancel({self.showActionSheet = false}))
//
                                    return buttons

                            }()
                            )
                        }
                    .sheet(isPresented: $showReporting){
                        ReportView(isShown: self.$showReporting, report_correspondingEntityType: RecipeatEntity.Recipe, report_correspondingEntityID: self.this_truncRP.id, report_reportingUser: self.env.currentUser.truncForm,
                                   report_entityPath: "recipe/\(self.this_truncRP.id)",
                                   closureAfterSubmit: {
                                                                let alertView = SPAlertView(title: "Violation Reported", message: "Thank you for keeping our community safe. Your report has been submitted successfully", preset: SPAlertPreset.done)
                                                                alertView.duration = 3
                                                                alertView.present()
                        }
                                   )
                    }
                        
                        
                    }
                    Spacer()
                }
                if showHeart {
                    Image(systemName: "heart.fill").foregroundColor(Color.white.opacity(0.75)).font(.system(size: 75)).shadow(radius: 2)
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                        .zIndex(1)
                    
                }
                VStack{
                    Spacer()
                    Button(action: {self.recipeClosure()}){
                        HStack(alignment: .bottom){
                            VStack(alignment: .leading, spacing:0){
                                Text("\(this_truncRP.title)")
                                    .font(.system(size: 23, weight: .bold))
                                    .foregroundColor(
                                        loadedRecipeImage == nil ? Color.black.opacity(0.5) : Color.white
                                        
                                )
                                    
                                Text("\(this_truncRP.subtitle)")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(Color.gray)
                                    .lineLimit(2)
                            }
                            .animation(.linear(duration: 0.5))
                            Spacer()
                            if DateDifference_Displayable(itemDate: date_fromTimeString_UTC(this_truncRP.dateCreate)) != nil {
                                Text(DateDifference_Displayable(itemDate: date_fromTimeString_UTC(this_truncRP.dateCreate))!)
                                    .font(.footnote)
                                    .foregroundColor(Color.init(white:0.9).opacity(0.8))
                            }
                        }
                        .padding(10)
                        
                        
                    }
                    
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 5)
                //.background(Color.orange)
            }
            
            
            
        }
        .onAppear{
            print("title:: \(this_truncRP.title)")
        }
        .frame(width: UniversalSquare.width, height:UniversalSquare.width)
            .background(Color.init(red: 0.95, green: 0.95, blue: 0.95).opacity(0.8))
        .clipped()
        .onAppear(){
            DispatchQueue.main.async{
                let user_imageString = "user/\(self.this_truncUser.id.uuidString)/profilepicture"
                loadImage_cache_FireStore(imageString: user_imageString, resized: .s64, minimumRecency: .Day1, completion: {
                    imageData in
                    if let imageData = imageData {
                        self.loadedUserImage = UIImage(data: imageData)!
                    } else {
                        //            p/("couldn't grab image")
                    }
                })
                
                let recipe_imageString = "recipe/\(self.this_truncRP.id.uuidString)/img0"
                loadImage_cache_FireStore(imageString: recipe_imageString, resized: .s1024, minimumRecency: .Day10, completion: {
                    imageData in
                    if let imageData = imageData {
                        self.loadedRecipeImage = UIImage(data: imageData)!
                    } else {
                        //            p/("couldn't grab image")
                    }
                })
                
                //            p/("postview")
                //            p/("\(self.this_truncUser.dictionary)")
                //            p/("\(self.this_truncRP.dictionary)")
            }
        }
        
        
    }
    
    func likeAction(){
        if !userLikesRecipe(user: self.env.currentUser, recipe: self.this_truncRP){
            withAnimation {
                showHeart = true
            }
            
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) {_ in
                    withAnimation {
                        self.showHeart = false
                    }
                }
            }
            
        }
        likePost(postingUser: self.this_fullUser, postingUser_trunc: self.this_truncUser, recipeToLike: self.this_truncRP, likerUser: self.env.currentUser, completion:{fullUser in
            reloadRecipe(recipeString: self.this_truncRP.id.uuidString, completion: {recipe in self.this_truncRP = recipe.truncForm})
            if let fullUser = fullUser{
                self.this_fullUser = fullUser
            }
            
        })
        
    }
    
    
}



//struct PostView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScrollView{
//            PostView(profileClosure: {
//
//            }, recipeClosure: {
//
//            }, this_truncRP: trunc_RecipePost(title: "This is a title", subtitle: "this is a subtitle", dateCreate: "", likes: []), this_truncUser: trunc_user(username: "asgas", name: "sdfvsdf", verified: false), loadedUserImage: nil)
//
//        }
//    }
//}

func userLikesRecipe(user: user, recipe:trunc_RecipePost) -> Bool {
    if recipe.likes.count < 1 {
        return false
    } else {
        print(recipe.likes.formatForFirebase().firstIndex(of: user.id.uuidString) ?? "non-existent")
        if let _ = recipe.likes.formatForFirebase().firstIndex(of: user.id.uuidString) {
            return true
        } else {
            return false
        }
    }
}


