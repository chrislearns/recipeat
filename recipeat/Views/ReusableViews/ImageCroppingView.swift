//
//  ImageCroppingView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 10/28/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct ImageCroppingView: View {
    @State var imageWidth:CGFloat = 0
    @State var imageHeight:CGFloat = 0
    
    @Binding var shown:Bool
    
    @State var croppingOffset = CGSize(width: 0, height: 0)
    @State var croppingMagnification:CGFloat = 1
    
    var image:UIImage
    @State var croppedImage:UIImage? = nil
    @Binding var media:[Identifiable_Media]
    @Binding var selectionIndex:Int
    var body: some View {
        ZStack{
            Color.black
                .edgesIgnoringSafeArea(.vertical)
            
            
            VStack{
                Spacer()
                    .frame(height: UniversalSafeOffsets?.top ?? 0)
                HStack(alignment: .top){
                    Button(action: {shown = false}){
                        Text("Cancel")
                            .foregroundColor(.red)
                    }
                    Spacer()
                    Text("You may need to re-select your filter after cropping")
                        .font(.system(size: 12))
                        .foregroundColor(.init(white: 0.7))
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                    Spacer()
                    Button(action: {
                        let cgImage: CGImage = image.cgImage!
                        print("image: \(cgImage.width) x \(cgImage.height)")
                        let scaler = CGFloat(cgImage.width)/imageWidth
                        let dim:CGFloat = getDimension(w: CGFloat(cgImage.width), h: CGFloat(cgImage.height))
                        
                        let xOffset = (((imageWidth/2) - (getDimension(w: imageWidth, h: imageHeight) * croppingMagnification/2)) + croppingOffset.width) * scaler
                        let yOffset = (((imageHeight/2) - (getDimension(w: imageWidth, h: imageHeight) * croppingMagnification/2)) + croppingOffset.height) * scaler
                        print("xOffset = \(xOffset)")
                        let scaledDim = dim * croppingMagnification
                        
                        
                        if let cImage = cgImage.cropping(to: CGRect(x: xOffset, y: yOffset, width: scaledDim, height: scaledDim)){
                            croppedImage = UIImage(cgImage: cImage)
                            //Selecting a new crop will make you need to re-filter the image
                            if let pre_image = media[selectionIndex].media as? Identifiable_UIImage {
                                var post_media = Identifiable_UIImage(id: pre_image.id, rawImage: pre_image.image.raw, filtered: pre_image.image.filtered, croppedImage: pre_image.image.croppedImage)
                                post_media.image.croppedImage = croppedImage
                                post_media.image.filtered = nil
                                
                                media[selectionIndex].media = post_media
//                                (media[selectionIndex].media as! Identifiable_UIImage).image.croppedImage = croppedImage
//                                (media[selectionIndex].media as! Identifiable_UIImage).image.filtered = nil
                            shown = false
                            }
                        }
                        
                        
                    
                }){
                    Text("Done")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
                    
                }
                .font(.system(size: 20))
                .padding()
                
                Spacer()
                ZStack{
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .overlay(GeometryReader{geo -> AnyView in
                            DispatchQueue.main.async{
                                self.imageWidth = geo.size.width
                                self.imageHeight = geo.size.height
                            }
                            return AnyView(EmptyView())
                        })
                    
                    ViewFinderView(imageWidth: self.$imageWidth, imageHeight: self.$imageHeight, finalOffset: $croppingOffset, finalMagnification: $croppingMagnification)
                        
                        
                }
                .padding()
                Spacer()
            }
            
        }.edgesIgnoringSafeArea(.vertical)
    }
}

struct ViewFinderView:View{
    @Binding var imageWidth:CGFloat
    @Binding var imageHeight:CGFloat
    @State var center:CGFloat = 0
    
    @State var activeOffset:CGSize = CGSize(width: 0, height: 0)
    @Binding var finalOffset:CGSize
    
    @State var activeMagnification:CGFloat = 1
    @Binding var finalMagnification:CGFloat
    
    @State var dotSize:CGFloat = 13
    var dotColor = Color.init(white: 1).opacity(0.9)
    var surroundingColor = Color.black.opacity(0.45)
    
    var body: some View {
        ZStack{
            Group{
                Rectangle()
                    .foregroundColor(surroundingColor)
                    .frame(width: ((imageWidth-getDimension(w: imageWidth, h: imageHeight))/2) + activeOffset.width + (getDimension(w: imageWidth, h: imageHeight) * (1 - activeMagnification) / 2), height: imageHeight)
                    .offset(x: getSurroundingViewOffsets(horizontal: true, left_or_up: true), y: 0)
                Rectangle()
                    .foregroundColor(surroundingColor)
                    .frame(width: ((imageWidth-getDimension(w: imageWidth, h: imageHeight))/2) - activeOffset.width + (getDimension(w: imageWidth, h: imageHeight) * (1 - activeMagnification) / 2), height: imageHeight)
                    .offset(x: getSurroundingViewOffsets(horizontal: true, left_or_up: false), y: 0)
                Rectangle()
                    .foregroundColor(surroundingColor)
                    .frame(width: getDimension(w: imageWidth, h: imageHeight) * activeMagnification, height: ((imageHeight-getDimension(w: imageWidth, h: imageHeight))/2) + activeOffset.height + (getDimension(w: imageWidth, h: imageHeight) * (1 - activeMagnification) / 2))
                    .offset(x: activeOffset.width, y: getSurroundingViewOffsets(horizontal: false, left_or_up: true))
                Rectangle()
                    .foregroundColor(surroundingColor)
                    .frame(width: getDimension(w: imageWidth, h: imageHeight) * activeMagnification, height: ((imageHeight-getDimension(w: imageWidth, h: imageHeight))/2) - activeOffset.height + (getDimension(w: imageWidth, h: imageHeight) * (1 - activeMagnification) / 2))
                    .offset(x: activeOffset.width, y: getSurroundingViewOffsets(horizontal: false, left_or_up: false))
            }
            
            Rectangle()
            .frame(width: getDimension(w: imageWidth, h: imageHeight)*activeMagnification, height: getDimension(w: imageWidth, h: imageHeight)*activeMagnification)
                .foregroundColor(Color.white.opacity(0.05))
                .offset(x: activeOffset.width, y: activeOffset.height)
                .gesture(
                    DragGesture()
                        .onChanged{drag in
                            let workingOffset = CGSize(
                                width: finalOffset.width + drag.translation.width,
                               height: finalOffset.height + drag.translation.height
                            )
                            
                            print(workingOffset.width + (getDimension(w: imageWidth, h: imageHeight)/2))
                            if workingOffset.width + (finalMagnification * getDimension(w: imageWidth, h: imageHeight)/2) <= imageWidth/2 &&
                                (workingOffset.width - (finalMagnification * getDimension(w: imageWidth, h: imageHeight)/2)) >= -imageWidth/2 {
                                self.activeOffset.width = workingOffset.width
                            } else if workingOffset.width + (finalMagnification * getDimension(w: imageWidth, h: imageHeight)/2) > imageWidth/2 {
                                self.activeOffset.width = (imageWidth/2) - (finalMagnification * getDimension(w: imageWidth, h: imageHeight)/2)
                            } else {
                                self.activeOffset.width = -(imageWidth/2) + (finalMagnification * getDimension(w: imageWidth, h: imageHeight)/2)
                            }
                            
                            if workingOffset.height + (finalMagnification * getDimension(w: imageWidth, h: imageHeight)/2) <= imageHeight/2 &&
                                ((workingOffset.height) - (finalMagnification * getDimension(w: imageWidth, h: imageHeight)/2)) >= -imageHeight/2 {
                                self.activeOffset.height = workingOffset.height
                            }
                            else if workingOffset.height + (finalMagnification * getDimension(w: imageWidth, h: imageHeight)/2) > imageWidth/2 {
                                self.activeOffset.height = (imageHeight/2) - (finalMagnification * getDimension(w: imageWidth, h: imageHeight)/2)
                            } else {
                                self.activeOffset.height = -((imageHeight/2) - (finalMagnification * getDimension(w: imageWidth, h: imageHeight)/2))
                            }
//                            else {
//                                self.activeOffset.height = (imageHeight/2) - (finalMagnification * getDimension(w: imageWidth, h: imageHeight)/2)
//
//                            }
                            
                            
                        }
                        .onEnded{drag in
                            self.finalOffset = activeOffset
                        }
                )
            Rectangle()
                .stroke(lineWidth: 1)
                .frame(width: getDimension(w: imageWidth, h: imageHeight)*activeMagnification, height: getDimension(w: imageWidth, h: imageHeight)*activeMagnification)
                .foregroundColor(.white)
                .offset(x: activeOffset.width, y: activeOffset.height)
            Rectangle()
                .stroke(lineWidth: 1)
                .frame(width: getDimension(w: imageWidth, h: imageHeight)*activeMagnification/3, height: getDimension(w: imageWidth, h: imageHeight)*activeMagnification)
                .foregroundColor(Color.white.opacity(0.6))
                .offset(x: activeOffset.width, y: activeOffset.height)
            Rectangle()
                .stroke(lineWidth: 1)
                .frame(width: getDimension(w: imageWidth, h: imageHeight)*activeMagnification, height: getDimension(w: imageWidth, h: imageHeight)*activeMagnification/3)
                .foregroundColor(Color.white.opacity(0.6))
                .offset(x: activeOffset.width, y: activeOffset.height)
            
            //UL corner icon
            Image(systemName: "arrow.up.left.and.arrow.down.right")
                .font(.system(size: 12))
                .background(Circle().frame(width: 20, height: 20).foregroundColor(dotColor))
                .frame(width: dotSize, height: dotSize)
                .foregroundColor(.black)
                .offset(x: activeOffset.width - (activeMagnification*getDimension(w: imageWidth, h: imageHeight)/2), y: activeOffset.height - (activeMagnification*getDimension(w: imageWidth, h: imageHeight)/2))
                .padding(25)
                .gesture(
                    DragGesture()
                        .onChanged{drag in
                            let calcMag = getMagnification(drag.translation)
                            let workingMagnification:CGFloat = finalMagnification * calcMag
                            
                            //**********************************
                            //This set of logic is used for calculations that prevent scaling to cause offset to go outside the actual image
                            let workingOffsetSize = (getDimension(w: imageWidth, h: imageHeight) * finalMagnification)-(getDimension(w: imageWidth, h: imageHeight) * activeMagnification)
                            let workingOffset = CGSize(width: finalOffset.width + workingOffsetSize/2, height: finalOffset.height + workingOffsetSize/2)
                            
                            let currentYOffset = workingOffset.height
                            let halfImageHeight = self.imageHeight/2
                            
                            let currentXOffset = workingOffset.width
                            let halfImageWidth = self.imageWidth/2
                            
                            let proposed_halfSquareSize = (getDimension(w: imageWidth, h: imageHeight)*activeMagnification)/2
                            //**********************************
                            
                            
                            if workingMagnification <= 1 && workingMagnification >= 0.4{
                                if proposed_halfSquareSize - currentYOffset > halfImageHeight || proposed_halfSquareSize - currentXOffset > halfImageWidth{
                                    print("scaling would extend past image bounds")
                                } else {
                                    activeMagnification = workingMagnification
                                }
                                
                            } else if workingMagnification > 1{
                                activeMagnification = 1
                            } else {
                                activeMagnification = 0.4
                            }
                            
                            let offsetSize = (getDimension(w: imageWidth, h: imageHeight) * finalMagnification)-(getDimension(w: imageWidth, h: imageHeight) * activeMagnification)
                            
                            self.activeOffset.width = finalOffset.width + offsetSize/2
                            self.activeOffset.height = finalOffset.height + offsetSize/2
                            print("current yOffset = \(currentYOffset)")
                            print("half image height = \(halfImageHeight)")
                            print("proposed half-square size = \(proposed_halfSquareSize)")
                        }
                        .onEnded{drag in
                            self.finalMagnification = activeMagnification
                            self.finalOffset = activeOffset
                            
                        }
                    
                    )
            
                
                
        }
    }
    func getSurroundingViewOffsets(horizontal:Bool, left_or_up:Bool) -> CGFloat {
        let initialOffset:CGFloat = horizontal ? imageWidth : imageHeight
        let negVal:CGFloat = left_or_up ? -1 : 1
        let compensator = horizontal ? activeOffset.width : activeOffset.height
        
        return (((negVal * initialOffset) - (negVal * (initialOffset - getDimension(w: imageWidth, h: imageHeight))/2))/2) + (compensator/2) + (-negVal * (getDimension(w: imageWidth, h: imageHeight) * (1 - activeMagnification) / 4))
    }
    func getMagnification(_ dragTranslation:CGSize) -> CGFloat {
        print(dragTranslation.width)
        if (getDimension(w: imageWidth, h: imageHeight) - dragTranslation.width)/getDimension(w: imageWidth, h: imageHeight) < (getDimension(w: imageWidth, h: imageHeight) - dragTranslation.height)/getDimension(w: imageWidth, h: imageHeight) {
            return (getDimension(w: imageWidth, h: imageHeight) - dragTranslation.width)/getDimension(w: imageWidth, h: imageHeight)
        } else {
            return (getDimension(w: imageWidth, h: imageHeight) - dragTranslation.height)/getDimension(w: imageWidth, h: imageHeight)
        }
        
    }
}

func getDimension(w:CGFloat,h:CGFloat) -> CGFloat{
    if h > w {
        return w
    } else {
        return h
    }
    
}

//struct ImageCroppingView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageCroppingView(image: UIImage(named: "lowfat")!)
//    }
//}
