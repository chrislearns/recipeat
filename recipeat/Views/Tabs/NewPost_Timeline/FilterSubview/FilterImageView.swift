//
//  FilterImageView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 10/11/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct FilterImageView: View {
    var filter:CIFilter?
    @Binding var media:[Identifiable_Media]
    @State var thumbnail:UIImage?
    @State var blur:CGFloat = 0
    @Binding var i:Int
    @State var overlay_progressView:Bool = false
    
    @Binding var ciContext:CIContext
    @Binding var ciImage:CIImage?
    
    
    @Binding var shown:Bool
    var body: some View {
        ZStack{
            Button(action: {
                if thumbnail != nil && media[i].media is Identifiable_UIImage{
                    var preImage = media[i].media as! Identifiable_UIImage
                    preImage.image.filtered = thumbnail
                    media[i].media = preImage
//                    shown = false
                }
                
            }){
                Image(uiImage: thumbnail == nil ?
                        (media[i].media is Identifiable_UIImage ? ((media[i].media as! Identifiable_UIImage).image.croppedImage == nil ? UIImage(systemName: "photo")! : (media[i].media as! Identifiable_UIImage).image.croppedImage!) : UIImage(systemName: "photo")!  )
                        
                        : thumbnail!)
                .resizable()
                .scaledToFill()
                .frame(width: 140, height:140)
                .clipped()
                .blur(radius: blur)
                .clipped()
            }
                .onAppear(){
                    reprocess()
    //                let ciContext = CIContext(options: nil)
    //                if let im = images[i].croppedImage{
    //                    let coreImage = CIImage(image: im)
    //                print(filter)
    //                if let filter = filter {
    //                    print("filter unwrapped")
    //                    filter.setDefaults()
    //                    filter.setValue(coreImage, forKey: kCIInputImageKey)
    //                    let filteredImageData = filter.value(forKey: kCIOutputImageKey) as! CIImage
    //                    let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
    //                    let imageForButton = UIImage(cgImage: filteredImageRef!);
    //                    thumbnail = imageForButton
    //                }
    //                } else {
    //                    print("cropped image is nil")
    //                }
                }
                .onChange(of: i){_ in
                    reprocess()
                }
//                .onChange(of: media[i].image.croppedImage){_ in
//                    reprocess()
//                }
                .overlay(overlay_progressView ? Color.white.opacity(0.6) : nil)
            if overlay_progressView{
                ProgressView()
                
            }
        }
    }
    
    func reprocess(){
        if let thisMedia = media[i].media as? Identifiable_UIImage {
            if let ci = thisMedia.image.croppedImage {
                thumbnail = ci
            } else {
                thumbnail = UIImage(systemName: "photo")
            }
        } else {
            thumbnail = UIImage(systemName: "photo")
        }
        blur = 4
        overlay_progressView = true
        DispatchQueue.global(qos: .userInteractive).async {
            let j = i
            
            
            
            if let coreImage = ciImage{
//                print(filter)
                if let filter = filter {
//                    print("filter unwrapped")
                    filter.setDefaults()
                    filter.setValue(coreImage, forKey: kCIInputImageKey)
                    let filteredImageData = filter.value(forKey: kCIOutputImageKey) as! CIImage
                    let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
                    let imageForButton = UIImage(cgImage: filteredImageRef!);
                    thumbnail = imageForButton
//                    print("j: \(j)")
//                    print("i: \(i)")
                    if j == i{
                        thumbnail = imageForButton
                        blur = 0
                        overlay_progressView = false
                    }
                } else {
                    blur = 0
                    overlay_progressView = false
                }
            } else {
                print("cropped image is nil")
            }
            
            
        }
    }
}

//struct FilterImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        FilterImageView()
//    }
//}
