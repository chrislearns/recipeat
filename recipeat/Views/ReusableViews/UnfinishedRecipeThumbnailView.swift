//
//  UnfinishedRecipeThumbnailView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 11/1/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import CoreData

struct UnfinishedRecipeThumbnailView: View {
    @EnvironmentObject var env: GlobalEnvironment
    
    @Binding var activeRecipe:RecipeObject
    @Binding var activeMedia:[Identifiable_Media]
    
    @State var show_actionSheet = false
    
    
    @State var thisRecipeDraft:RecipePost
    @State var thisRecipe_media:[Identifiable_Media] = []
    var body: some View {
        Button(action: {show_actionSheet = true}){
            VStack(alignment: .leading){
                Image(uiImage: thisRecipe_media.count > 0 ?
                        (thisRecipe_media[0].media is Identifiable_UIImage ? (thisRecipe_media[0].media as! Identifiable_UIImage).deepestLevel() : UIImage(named: "activityIndicatorPadded_bw")!)
                        : UIImage(named: "activityIndicatorPadded_bw")!)
                    
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                    .background(Color.init(white: 237/255))
                .cornerRadius(13)
            Text(thisRecipeDraft.title == "" ? "Untitled" : thisRecipeDraft.title)
                .foregroundColor(thisRecipeDraft.title == "" ? .init(white: 0.6) : .black)
                .lineLimit(1)
                .font(.system(size: 13, weight: .semibold))
            }
            .frame(width: 80)
            .padding(.horizontal, 8).padding(.vertical, 5)
        }
        .onAppear{
            let load_attempt = loadImage_draft(associatedRecipeUUID: thisRecipeDraft.id.uuidString)
            if let images = load_attempt{
                print("found images - \(images.count)")
                thisRecipe_media = images.map({
                    Identifiable_Media(media:
                        Identifiable_UIImage(rawImage: $0.rawImage.imageUnwrap() ?? UIImage(systemName: "exclamationmark.triangle")!, filtered: $0.filteredImage.imageUnwrap(), croppedImage: $0.croppedImage.imageUnwrap())
                    )
                    
                })
            } else {
                print("results of image load was nil - \(load_attempt)")
            }
        }
        .actionSheet(isPresented: $show_actionSheet){
            ActionSheet(title: Text("Manage Draft"), message: Text("You can continue working on an old draft or delete it entirely."), buttons: [
                .default(Text("Edit draft"), action: {
                    print("edit")
                    self.activeRecipe = RecipeObject(recipe: thisRecipeDraft, media: thisRecipe_media)
                    self.activeMedia = thisRecipe_media
                    
                }),
                .destructive(Text("Delete draft"), action: {
                    if activeRecipe.recipe.id.uuidString == thisRecipeDraft.id.uuidString {
                        //This makes sure that if you delete a draft that you were somehow also working on, you cant keep editing the draft after you;ve deleted it
                        activeRecipe.recipe = RecipePost()
                        activeRecipe.media = []
                    }
                    
                    let load_attempt = loadImage_draft(associatedRecipeUUID: thisRecipeDraft.id.uuidString)
                    if let images = load_attempt{
                        delete_NSManagedObjects(objects: images, objectType: "DraftImage", completion: {
                            print("images for draft deleted")
                        })
                        
                    } else {
                        print("no images assoc with this recipe draft to delete")
                    }
                    
                    self.env.unfinishedRecipes[thisRecipeDraft.id.uuidString] = nil
                    self.env.sync_unfinishedRecipes()
                    print("delete")
                }),
                .cancel()
            ])
    }
    }
}
