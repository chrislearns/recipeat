//
//  FilteringView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 10/28/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct FilteringView: View {
    @Binding var media:[Identifiable_Media]
    @Binding var selectionIndex:Int
    @Binding var shown:Bool
    @State var ciContext = CIContext(options: nil)
    @State var ciImage:CIImage? = nil
    var body: some View {
        VStack{
            
//                Spacer()
//                    .frame(height: UniversalSafeOffsets?.top ?? 0)
                HStack{

                    Spacer()
                    Button(action: {
                        shown = false

                }){
                    Text("Done")
//                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }

                }
                .font(.system(size: 20))
                .padding(.horizontal)
            ScrollView{
                if media[selectionIndex].media is Identifiable_UIImage {
                    Image(uiImage: (media[selectionIndex].media as! Identifiable_UIImage).image.filtered == nil ? ((media[selectionIndex].media as! Identifiable_UIImage).image.croppedImage == nil ? (media[selectionIndex].media as! Identifiable_UIImage).image.raw : (media[selectionIndex].media as! Identifiable_UIImage).image.croppedImage!) : (media[selectionIndex].media as! Identifiable_UIImage).image.filtered!)
                        .resizable()
                        .scaledToFit()
                    .frame(width: UniversalSquare.width, height: UniversalSquare.width)
                }
            HStack{
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        Spacer().frame(width: 8)
                        ForEach(filters, id: \.id){filter in
                            VStack(spacing: 5){
                                HStack{
                                    Text(filter.filter.0)
                                        .font(.system(size: 13, weight: .semibold))
                                    Spacer()
                                }
                                FilterImageView(filter: CIFilter(name: filter.filter.1), media: $media, i: $selectionIndex, ciContext: $ciContext, ciImage: $ciImage, shown: $shown)
                            }
                            .frame(width: 140)
                            .padding(8)
                        }
                        Spacer().frame(width: 8)
                    }
                }
            }
            .frame(width: UniversalSquare.width, height: 200)
                Spacer()
            }
        }.onAppear{
            if let uw_data = media[selectionIndex].media as? Identifiable_UIImage {
            if let im = uw_data.image.croppedImage{
                print("im = cropped image")
                ciImage = CIImage(image: im)
            }
            }
            
        }
        
        
    }
}

//struct FilteringView_Previews: PreviewProvider {
//    static var previews: some View {
//        FilteringView()
//    }
//}
