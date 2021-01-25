//
//  Structs_Enums_Classes.swift
//  recipeat
//
//  Created by Christopher Guirguis on 3/2/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import Foundation
import SwiftUI
import AVFoundation
import Firebase
import LightCompressor

var UniversalSquare = UIScreen.main.bounds.size
var UniversalSafeOffsets = UIApplication.shared.windows.first?.safeAreaInsets


var vLightBLue = Color.init(red: 130/255, green: 209/255, blue: 255/255)
var lightBlue = Color.init(red: 117/255, green: 188/255, blue: 230/255)
var mediumBlue = Color.init(red: 98/255, green: 157/255, blue: 191/255)
var darkBlue = Color.init(red: 65/255, green: 105/255, blue: 128/255)
var vDarkBlue = Color.init(red:33/255, green: 52/255, blue: 64/255)

var darkPink = Color.init(hex: "#E53951")
var lightPink = Color.init(hex: "#F07280")
var darkGreen = Color.init(hex: "#069F82")
var lightGreen = Color.init(hex: "#0BBF9E")
var lightYellow = Color.init(hex: "#FFF2B5")
var darkRed = Color.init(hex: "#BF212E")

var verifiedDarkBlue = Color.init(hex: "#5A8FE3")
var verifiedLightBlue = Color.init(hex: "#B1CDFB")


struct BannerData {
    var title:String
    var detail:String
    var type: BannerType
}







struct ActionableButton:Identifiable {
    var id = UUID()
    var text:String?
    var moreScrollText:String?
    var sfsymbol:String
    var action:(Any) -> Void
}

struct HashableNavigationUnit{
    var navigationContext:Any? = nil
    var navigationSelector:Int? = nil
}

struct ImageObject {
    var raw:UIImage
    var filtered:UIImage?
    var croppedImage:UIImage?
}


struct Identifiable_UIImage: Identifiable,MediaTypeProtocol {
    var id:UUID
    var image:ImageObject

    
    init(id: UUID = UUID(), rawImage:UIImage, filtered:UIImage? = nil, croppedImage:UIImage? = nil) {
        self.id = id
        self.image = ImageObject(raw: rawImage, filtered: filtered, croppedImage: nil)
        if croppedImage == nil {
        self.image.croppedImage = defaultCrop()
        } else {
            self.image.croppedImage = croppedImage
        }
    }
    func defaultCrop() -> UIImage?{
        let cgImage: CGImage = image.raw.cgImage!
        print("image: \(cgImage.width) x \(cgImage.height)")
        let dim:CGFloat = getDimension(w: CGFloat(cgImage.width), h: CGFloat(cgImage.height))
        
        let xOffset = CGFloat(cgImage.width/2) - (dim/2)
        let yOffset = CGFloat(cgImage.height/2) - (dim/2)

        print("xOffset = \(xOffset)")
        if let cImage = cgImage.cropping(to: CGRect(x: xOffset, y: yOffset, width: dim, height: dim)){
            print("crop success")
            return UIImage(cgImage: cImage)
        } else {
            print("crop fail")
            return nil
        }
    }
    
    func deepestLevel() -> UIImage {
        if let im = image.filtered {
            return im
        } else if let im = image.croppedImage {
            return im
        } else {
            return image.raw
        }
    }
}
 
struct Identifiable_Media:Identifiable{
    var id = UUID()
    var media:MediaTypeProtocol
    
    func videoSize() -> CGSize?{
        guard let vid = self.media as? Identifiable_Video else {return nil}
        if let dim = vid.getVideoDimensions() {
            return dim
        } else {
            return nil
        }
    }
//    init(media:MediaTypeProtocol) {
//        self.media = media
//        if media is Identifiable_UIImage {
//            
//        }
//    }
}

struct Identifiable_AnyView: Identifiable {
    var id = UUID()
    var anyView:AnyView
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct Filter:Identifiable{
    var id = UUID()
    var filter:(String,String)
}

var filters = [
    Filter(filter: ("None","")),
    Filter(filter: ("Chrome","CIPhotoEffectChrome")),
    Filter(filter: ("Fade","CIPhotoEffectFade")),
    Filter(filter: ("Instant","CIPhotoEffectInstant")),
    Filter(filter: ("Noir","CIPhotoEffectNoir")),
    Filter(filter: ("Process","CIPhotoEffectProcess")),
    Filter(filter: ("Tonal","CIPhotoEffectTonal")),
    Filter(filter: ("Transfer","CIPhotoEffectTransfer")),
    Filter(filter: ("Sepia","CISepiaTone"))
]


