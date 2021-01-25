//
//  NewPost_ImageSelectionView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 10/8/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import Firebase
import SwiftUI
import LightCompressor
import PhotosUI


struct NewPost_ImageSelectionView: View {

    @EnvironmentObject var env: GlobalEnvironment
    @Binding var shown:Bool
    
    @State var recipeObject = RecipeObject()
    @State var isEditing = false
    
    @State var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
    
    @State var selectionIndex:Int = 0
//    @ObservedObject var newRecipePost = RecipePost()
    @State var cancelAlertShown = false
    @State var presentPicker = false
    
    @State var reg_bannerData:BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Success)
    @State var reg_bannerShown:Bool = false
    
    
    @State var next = false
    
    @State var tabExpanded = false
    
    @State var showCropping = false
    @State var showFilters = false
    
    @State var PVModel = PagingGalleryModel(updater: 0, media: [])
    
    var body: some View {
        NavigationView{
            ZStack{
                NavigationLink(destination: NewPost_TitleDescriptionSelectionView(isEditing:$isEditing, shown: $shown), isActive: $next){
                    EmptyView()
                }
                ScrollView(.vertical){
                
                VStack(spacing: 0){

            ZStack{
                if PVModel.media.count > 0 {
                    PagingGalleryView(galleryHeight: UniversalSquare.width, galleryWidth: UniversalSquare.width, imageWidth: UniversalSquare.width, imageHeight: UniversalSquare.width, selection: $selectionIndex, tabView_updater: $PVModel.updater, contents:
                                        $PVModel.media
                        )
                        .frame(width: UniversalSquare.width, height: UniversalSquare.width)
                        .clipped()
//                        .background(Color.green)
                        .zIndex(300)
                    .background(Color.init(white:0.95))
            } else {
                Button(action: {
                        presentPicker = true
                    
                }){
                    ZStack{
                    Image(systemName: "plus.rectangle.on.rectangle")
                    .font(.system(size: 60))
                    .foregroundColor(Color.init(white: 0.8))
                        .frame(width: (UIScreen.main.bounds.width), height: (UIScreen.main.bounds.width), alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .background(Color.init(white: 0.95))//.shadow(radius: 4))
                }
                }
            }
            }.padding(.bottom, 5)
            
            Spacer()
                    if PVModel.media.count > 0 {
//                        Rectangle().frame(height: 1)
                        if isEditing {
                            Group{
                                Text("When editing an already existing recipe, you cannot change any of the images. You may, however, update all other pieces of the recipe. You can press ").foregroundColor(.init(white: 0.7)) + Text("Next").foregroundColor(.blue).fontWeight(.semibold) + Text(" in the top right corner to continue editing the recipe").foregroundColor(.init(white: 0.7))
                            }
                                .padding()
                        } else {
                            ImageModifyingButtonsView(showCropping: $showCropping, showFilters: $showFilters, media: $PVModel.media, selectionIndex: $selectionIndex)
                        }
//                        Rectangle().frame(height: 1).padding(.horizontal).foregroundColor(.init(white: 0.7))
//                        FilteringView(images: $images, selectionIndex: $selectionIndex)
                    } else {
                        VStack{
                            
                                Text("Start by adding photos")
                                    .font(.system(size: 14, weight: .semibold))
                            MediaAdderView(tabExpanded: $tabExpanded, presentPicker: $presentPicker, PVModel: $PVModel, vType: .standalone)
                            
                            if self.env.unfinishedRecipes.count > 0 {
                                Spacer().frame(height: 10)
                                Text("Finish a draft you've saved")
                                    .font(.system(size: 14, weight: .semibold))
                                    ScrollView(.horizontal){
                                        HStack(alignment: .top){
                                            Spacer().frame(width: 8)
                                            ForEach(self.env.unfinishedRecipes.sorted(by: {$0.key > $1.key}), id: \.key){key, value in
                                                UnfinishedRecipeThumbnailView(activeRecipe: $recipeObject, activeMedia: $PVModel.media, thisRecipeDraft: value)
                                            }
                                            Spacer().frame(width: 8)
                                        }
                                    }
//                                    .frame(height: 70)
//                                    .background(Color.blue)
                                
                            }
                        }
                    }
                    
//            .background(Color.red)
            
            }
            
            }
            .navigationBarTitle("New Post", displayMode: .inline)
            .navigationBarItems(
                leading:
                    Button(action: {
                        if isEditing{
                            self.shown = false
                        } else {
                            if self.recipeObject.isEmpty() && self.PVModel.media.count == 0 {
                            self.shown = false
                        } else {
                            self.cancelAlertShown = true
                        }
                        }
                    }){
                        Text("Cancel")
                            .foregroundColor(Color.init(white: 0.4))
                    }, trailing:
                        ZStack{
                            if PVModel.media.count > 0 {
//                                NavigationLink("Next", destination: NewPost_TitleDescriptionSelectionView())
                                
                                Button(action: {
                                    self.next = true //SWITCH THE WAY NAVIGATION LINK IS USED/DECLARED/HANDLED and move to the version where you flip a bool to activate the link in a zstack
                                    self.recipeObject.media = self.PVModel.media
    
                                }){
                                    Text("Next")
                                }
                                
                            } else {
                                    Text("Next")
                                    .foregroundColor(Color.init(white: 0.6))
                            }
                        }
                            
                    )
                
                    Color.black.opacity(tabExpanded ? 0.3 : 0)
                        .animation(.linear(duration: 0.3))
                        .onTapGesture {
                            tabExpanded = false
                        }
                
                if PVModel.media.count > 0 && !isEditing {
                    VStack(spacing: 0){
                    Spacer()
                        MediaAdderView(tabExpanded: $tabExpanded, presentPicker: $presentPicker, PVModel: $PVModel, vType: .bottom)
                    }.animation(.easeInOut(duration: 0.3)).edgesIgnoringSafeArea(.bottom)
                    
                
                }
            }
        
        }
        .banner(data: $reg_bannerData, show: $reg_bannerShown)
        .environmentObject(recipeObject)
        .actionSheet(isPresented: $cancelAlertShown){
            ActionSheet(title: Text("End new recipe?"), message: Text("You can delete your progress or save it as a draft for later"), buttons: [
                .default(Text("Save as Draft"), action: {
                    
                    if PVModel.media.count > 0 {
                        recipeObject.recipe.dateCreate = currentTime_UTC()
                        self.env.unfinishedRecipes[recipeObject.recipe.id.uuidString] = recipeObject.recipe
                        //This saves the data of the draft but not the images
                        self.env.sync_unfinishedRecipes()
                        //Here we will save the images
                        var mediaToUpload = PVModel.media.count
                        for i in 0..<PVModel.media.count {
                            let im = PVModel.media[i].media
                            print("saving media \(i) in drafts")
                            if im is Identifiable_UIImage {
                            saveImage_draft(associatedRecipeUUID: recipeObject.recipe.id.uuidString, IDAble_image: (im as! Identifiable_UIImage), order_index: Int16(i))
                            mediaToUpload = mediaToUpload - 1
                            
                            if mediaToUpload == 0 {
                                self.env.bToggleTabbedRoot = true
                                self.env.bDataTabbedRoot = BannerModifier.BannerData(title: "Draft Saved", detail: "Your draft has been saved \(PVModel.media.count). You can come back to post it at any point.", type: .Info)

                                self.shown = false
                            }
                            }
                        }
                            
                        
                    } else {
                        reg_bannerData = BannerModifier.BannerData(title: "One last thing", detail: "You need at least one photo to save a draft.", type: .Error)
                        withAnimation{
                            reg_bannerShown = true
                        }
                    }
                    
                }),
                .destructive(Text("Delete New Post"), action: {
                                self.shown = false
                    
                }),
                .cancel()
            ])
    }
        
        .fullScreenCover(isPresented: $showCropping){
            ImageCroppingView(shown: $showCropping, image: (PVModel.media[selectionIndex].media as! Identifiable_UIImage).image.raw, media: $PVModel.media, selectionIndex: $selectionIndex)
        }
        
        
    }
}

struct MediaAdderView:View {
    enum viewType{
        case bottom
        case standalone
    }
    @Binding var tabExpanded:Bool
    @Binding var presentPicker:Bool
    @State var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
    @Binding var PVModel:PagingGalleryModel
    var vType:viewType
    var body : some View {
        ZStack{
            if vType == .bottom{
                VStack(spacing:0){
            HStack{
            Spacer()
            Button(action: {tabExpanded.toggle()}){HStack{
                Image(systemName: "plus")
                Text("Add media")
            }
                .font(.system(size: 14, weight: .bold))
                .padding(.vertical, 8).padding(.horizontal, 12)
            .padding(.bottom, UniversalSafeOffsets?.bottom == nil || tabExpanded == true ? 0 : 15)
                
            .background(tabExpanded ? Color.white : verifiedLightBlue)
                .foregroundColor(verifiedDarkBlue)
                .cornerRadius(10, corners: [.topRight, .topLeft])
                .shadow(radius: 3)
            }
            Spacer().frame(width: 10)
        }
            if tabExpanded {
                HStack {
                    Spacer()
                    Button(action: {presentPicker = true}){
                        VStack{
                            Image("picker_library_blue")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            Text("Library")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(verifiedDarkBlue)
                        }
                    }
                    .font(.system(size: 20, weight: .bold))
                    Button(action: {
                        InAppNotication(text: "We're getting there! You'll be able to add pictures directly from your camera in an upcoming update.", duration: 4)
                    }){
                        VStack{
                        Image("picker_camera_gray")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                        Text("Camera")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.init(white: 0.5))
                        }
                    }
                    .font(.system(size: 20, weight: .bold))
                    //                                Spacer()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(Color.white)
            }
        }
            } else {
                HStack {
                    
                    Button(action: {presentPicker = true}){
                        VStack{
                            Image("picker_library_blue")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            Text("Library")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(verifiedDarkBlue)
                        }
                    }
                    .font(.system(size: 20, weight: .bold))
                    Button(action: {
                        InAppNotication(text: "We're getting there! You'll be able to add pictures directly from your camera in an upcoming update.", duration: 4)
                    }){
                        VStack{
                        Image("picker_camera_gray")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                        Text("Camera")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.init(white: 0.5))
                        }
                    }
                    .font(.system(size: 20, weight: .bold))
                    //                                Spacer()
                }
            }
        }
        
        .sheet(isPresented: $presentPicker, onDismiss: {self.tabExpanded = false}) {
            PhotoPickerView(configuration: $configuration, updater: $PVModel.updater, results: $PVModel.media, isPresented: $presentPicker)
        }
    }
}

struct ImageModifyingButtonsView:View{
    @Binding var showCropping:Bool
    @Binding var showFilters:Bool
    
    @Binding var media:[Identifiable_Media]
    @Binding var selectionIndex:Int
    var body: some View{
        HStack{
            Spacer()
            if media[selectionIndex].media is Identifiable_UIImage{
                Button(action: {showCropping.toggle()}){
                    HStack{
                        Text("Crop")
                        Image(systemName: "crop")
                    }.padding(.horizontal).frame(height:40).background(Color.init(white: 0.9)).cornerRadius(20)
                }
            
                Button(action: {showFilters.toggle()}){
                HStack{
                    Text("Filter")
                    Image(systemName: "paintbrush")
                }.padding(.horizontal).frame(height:40).background(Color.init(white: 0.9)).cornerRadius(20)
                }
            } else {
                Button(action: {
//                    print("attempting video upload")
//                    Storage.storage().reference().child("recipe/D4346263-0582-43AF-83E0-2FB6B676C723/vid0").putFile(from: URL(string: (media[selectionIndex].media as! Identifiable_Video).videoLocation)!    , metadata: nil, completion: { (metadata, error) in
//                        if error == nil {
//                            print("Successful video upload")
//                        } else {
//                            print(error?.localizedDescription)
//                        }
//                    })
                    
                    if let idVid = media[selectionIndex].media as? Identifiable_Video {
                        idVid.getCompressedVideo(compressionCompletion: {outcome, path in
                            print("compression outcome")
                            print(outcome)
                            if let path = path {
                                print(path.absoluteString)
                            }
                            
                        })
                        
                    }
                }){
                    HStack{
                        Text("Temp")
                        Image(systemName: "dot.square")
                            
                    }
                    .foregroundColor(darkGreen)
                    .padding(.horizontal)
                    .frame(height:40)
                    .background(Color.init(red: 0.9, green: 1, blue: 0.9))
                    .cornerRadius(20)
                }
            }
            Button(action: {
                media.remove(at: selectionIndex)
                if selectionIndex > 0 {
                    selectionIndex -= 1
                    
                } else {
                    selectionIndex = 0
                }
            }){
                HStack{
                    Text("Delete")
                    Image(systemName: "trash")
                        
                }
                .foregroundColor(darkRed)
                .padding(.horizontal)
                .frame(height:40)
                .background(Color.init(red: 1, green: 0.9, blue: 0.9))
                .cornerRadius(20)
            }
            Spacer()
        }
        .animation(.linear(duration: 0.3))
        .font(.system(size: 13))
        .padding(.horizontal)
        
        .fullScreenCover(isPresented: $showFilters){
            FilteringView(media: $media, selectionIndex: $selectionIndex, shown: $showFilters)
        }
    }
}

struct NewPost_ImageSelectionView_Previews: PreviewProvider {
    static var previews: some View {
          Group {
            NewPost_ImageSelectionView(shown: .constant(true))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")

//            NewPost_ImageSelectionView()
//                .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
//                .previewDisplayName("iPhone 11 Pro")
          }
       }
}
