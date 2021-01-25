//
//  GalleryView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 3/30/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import SPAlert

struct GalleryView: View {
    
    @GestureState private var dragState = DragState.inactive
    
//    @GestureState var magnifyBy = CGFloat(1.0)

//    var magnification: some Gesture {
//        MagnificationGesture()
//            .updating($magnifyBy) { currentState, gestureState, transaction in
//            if gestureState >= 1 { gestureState = currentState}
//            }
//    }
    
    @State var galleryLocation_index:CGFloat = 0
    var hasIndicators = true
    var isDebugging = false
    var bgColor = Color.white
    var indicatorColor_focus = lightGreen
    var indicatorColor_peripheral = lightGreen.opacity(0.5)
    var actionButton:ActionableButton?
    
    @State var showActionSheet:Bool = false
    
    var contentMode = ContentMode.fill
    
    var galleryHeight:CGFloat
    var galleryWidth:CGFloat
    
    var imageWidth:CGFloat
    var imageHeight:CGFloat
    
    var spacing:CGFloat = 0
    var contents:[Identifiable_UIImage]
    
    var onDrag_completionHandler:((Int) -> Void)?
    
    //IoI = Image of Interest - it's to be used in the ActionSheet for things like saving the image
    @State var IoI:UIImage? = nil
    
    var body: some View {
        
        
        
        ZStack{
            ForEach(contents, id: \.id){IDable_AnyView in
                ZStack{
                    Color.black.opacity(0.0001)
                    
                    ZStack{
                        ImageContainer(
                            contentMode:contentMode,
                            image: IDable_AnyView.image.filtered == nil ? (IDable_AnyView.image.croppedImage == nil ? UIImage(systemName: "photo")! : IDable_AnyView.image.croppedImage!) : IDable_AnyView.image.filtered!,
                            imageWidth: imageWidth,
                            imageHeight: imageHeight)
                        }.frame(width: self.imageWidth, height: self.imageHeight, alignment: .center).clipped()
                    
                    if self.actionButton != nil {
                        Button(action: {
                            if self.galleryLocation_index > 0 {
                                self.galleryLocation_index -= 1
                            }
                            self.actionButton!.action(
                                self.contents.getIndexOf(IDable_AnyView)
                            )
                        }){
                            Image(systemName: self.actionButton!.sfsymbol).foregroundColor(.init(red: 1, green: 0.3, blue: 0.3)).opacity(0.9).frame(width: 25, height: 5)
                        }
                        .offset(x:(self.imageWidth/2) - 20, y: (-1 * self.imageHeight/2) + 20)
                    }
                    
                    
                }
                .offset(x:
                    (
                        //This first number sets the offset assuming you were on the first image
                        CGFloat(self.contents.getIndexOf(IDable_AnyView)) * (self.imageWidth + self.spacing))
                        //This second mumber accounts for your uncommited drag
                        
                        + ((self.galleryLocation_index == 0 && self.dragState.translation.width > 0) ? self.dragState.translation.width.squareRoot() :  (((Int(self.galleryLocation_index) == self.contents.count - 1 && self.dragState.translation.width < 0) ? -1 * ((-1 * self.dragState.translation.width).squareRoot()) : self.dragState.translation.width)))
                        //This third number accounts for the offset of where you are in the gallery
                        - ((self.imageWidth + self.spacing) * self.galleryLocation_index)
                )
                    
                    .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
                    
                .gesture(
                    DragGesture()
                        .updating(self.$dragState) { drag, state, transaction in
                            state = .dragging(translation: drag.translation)
                    }
                    .onEnded{value in
                        let deltaX = value.location.x - value.startLocation.x
                        let threshold = self.galleryWidth/4
                        print("endX = \(deltaX)")
                        //if dragged to the right, past the thrsehold
                        if deltaX < (-1 * threshold) {
                            //if not the last item
                            if Int(self.galleryLocation_index) != self.contents.count - 1 {
                                self.galleryLocation_index += 1
                                if let completion = onDrag_completionHandler {
                                    completion(Int(self.galleryLocation_index))
                                }
                            }
                        } else
                            //If dragged to the left, past the thrshold
                            if deltaX > threshold {
                                
                                //If not the first item
                                if self.galleryLocation_index != 0 {
                                    self.galleryLocation_index -= 1
                                    if let completion = onDrag_completionHandler {
                                        completion(Int(self.galleryLocation_index))
                                    }
                                }
                        }
                        
                    }
                )
//                    .gesture(self.magnification)
                    .onLongPressGesture {
                        self.IoI = IDable_AnyView.image.raw
                            self.showActionSheet = true
                    }
                    .zIndex(500 - Double(self.contents.getIndexOf(IDable_AnyView)))
            }
            if hasIndicators {
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        ForEach(contents, id: \.id){IDable_AnyView in
                            
                            Circle()
                                .foregroundColor(CGFloat(self.contents.getIndexOf(IDable_AnyView)) == self.galleryLocation_index ? self.indicatorColor_focus : self.indicatorColor_peripheral)
                                
                                .frame(width:CGFloat(self.contents.getIndexOf(IDable_AnyView)) == self.galleryLocation_index ? 10 : 6,
                                       height:CGFloat(self.contents.getIndexOf(IDable_AnyView)) == self.galleryLocation_index ? 10 : 6)
                                
                                
                                .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
                        }
                        Spacer()
                    }
                    Spacer().frame(height:10)
                }
                .zIndex(1000)
            }
            if isDebugging {
                VStack{
                    Text("location: \(galleryLocation_index)")
                    Text("threshold: \(galleryWidth/4)")
                    Text("translation: \(dragState.translation.debugDescription)")
                }
            }
        }.frame(width: galleryWidth, height: galleryHeight)
            .actionSheet(isPresented: $showActionSheet){
                ActionSheet(title: Text("More options"), message: Text("Choose an action from below"), buttons:
                    
                    {
                        var buttons:[ActionSheet.Button] = []
                        buttons.append(ActionSheet.Button.default(Text("Save Image"), action: {
                            let imageSaver = ImageSaver()
                            if let IoI = self.IoI {
                                imageSaver.writeToPhotoAlbum(image: IoI)
                            } else {
                                let alertView = SPAlertView(title: "Failed to save image", message: "err: 328w9 gi459", preset: SPAlertPreset.error)
                                alertView.duration = 3
                                alertView.present()
                            }
                            
                        }))
                        buttons.append(ActionSheet.Button.cancel({self.IoI = nil}))
                        
                        return buttons
                }()
                )
                
        }
        .clipped()
        .background(bgColor)
        
    }
    
    
    
    
}

struct ImageContainer: View {
    
//    @GestureState var magnifyBy = CGFloat(1.0)
    
//    var magnification: some Gesture {
//        MagnificationGesture()
//            .updating($magnifyBy) { currentState, gestureState, transaction in
//                print(magnifyBy)
//            if gestureState >= 1 { gestureState = currentState}
//
//            }
//    }
    
    var contentMode:ContentMode
    var image:UIImage
    var imageWidth:CGFloat
    var imageHeight:CGFloat
    var body: some View {
        ZStack {
//            Color.black
            Image(uiImage: image)
                
                .resizable()
                .aspectRatio(contentMode: self.contentMode)
                .frame(width: self.imageWidth, height: self.imageHeight, alignment: .center)
                
                .foregroundColor(.white)
                .clipped()
//                .resizable()
//                .scaledToFill()
//                .frame(width: self.imageWidth * magnifyBy, height: self.imageHeight * magnifyBy)
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .gesture(self.magnification)
        }
    }
}
