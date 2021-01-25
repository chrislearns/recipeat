//
//  PagingGalleryView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 11/9/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct PagingGalleryModel{
    var updater:Int
    var media:[Identifiable_Media]
}

struct PagingGalleryView: View {
    var galleryHeight:CGFloat
    var galleryWidth:CGFloat
    
    var imageWidth:CGFloat
    var imageHeight:CGFloat
    @Binding var selection:Int
    @Binding var tabView_updater: Int
    @Binding var contents:[Identifiable_Media]
    var body: some View {
        TabView(selection: $selection){
            if contents.count > 0 {
            ForEach(contents){IDable_Media in
//                Text("\(contents[i])")
                if IDable_Media.media is Identifiable_UIImage {
                Image(uiImage: (IDable_Media.media as! Identifiable_UIImage).image.filtered == nil ? ((IDable_Media.media as! Identifiable_UIImage).image.croppedImage == nil ? UIImage(systemName: "photo")! : (IDable_Media.media as! Identifiable_UIImage).image.croppedImage!) : (IDable_Media.media as! Identifiable_UIImage).image.filtered!)
                    
                    .resizable()
                        .scaledToFill()
                        .clipped()
                    .tag(contents.firstIndex(where: {$0.id == (IDable_Media).id}) ?? 0)
                    .onAppear{
                        self.selection = contents.firstIndex(where: {$0.id == IDable_Media.id}) ?? 0
                    }
                } else if IDable_Media.media is Identifiable_Video {
                    VideoPlayerView(selection: $selection, baseIndex: (contents.firstIndex(where: {$0.id == IDable_Media.id}) ?? 3), model: PlayerViewModel((IDable_Media.media as! Identifiable_Video).videoLocation))
                        .tag(contents.firstIndex(where: {$0.id == (IDable_Media).id}) ?? 0)
                        .onAppear{
                            self.selection = contents.firstIndex(where: {$0.id == (IDable_Media.media as! Identifiable_Video).id}) ?? 0
                        }
                    } else {
                    VideoPlayerView(selection: $selection, baseIndex: 0, model: PlayerViewModel("https://firebasestorage.googleapis.com/v0/b/recipeat-1d425.appspot.com/o/trial_deleteLater%2FJamaican%20Jerk%20Potatoes.mp4?alt=media&token=5c9bc3fd-5f46-47be-89bb-3d3176c0bcba"))
//                        .tag(i)
                }
            }
//            VideoPlayerView(selection: $selection, baseIndex: 0, model: PlayerViewModel("https://firebasestorage.googleapis.com/v0/b/recipeat-1d425.appspot.com/o/trial_deleteLater%2FJamaican%20Jerk%20Potatoes.mp4?alt=media&token=5c9bc3fd-5f46-47be-89bb-3d3176c0bcba"))
            
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .id(tabView_updater)

        
    }
}

