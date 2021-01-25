//
//  PhotoPickerView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 10/12/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import PhotosUI
import MobileCoreServices

struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var configuration: PHPickerConfiguration
    @Binding var updater:Int
    @Binding var results:[Identifiable_Media]
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        
        
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        
        return controller
    }
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
    func makeCoordinator() -> Coordinator {
        Coordinator(self, results: $results, updater: $updater)
    }
    
    // Use a Coordinator to act as your PHPickerViewControllerDelegate
    class Coordinator: PHPickerViewControllerDelegate {
        
        private let parent: PhotoPickerView
        @Binding var results:[Identifiable_Media]
        @Binding var updater:Int
        
        init(_ parent: PhotoPickerView, results: Binding<[Identifiable_Media]>, updater: Binding<Int>) {
            
            self.parent = parent
            _results = results
            self.parent.configuration.selectionLimit = 0
            self.parent.configuration.preferredAssetRepresentationMode = .current
            _updater = updater
        }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            print(results)
            
            for image in results {
                if image.itemProvider.canLoadObject(ofClass: UIImage.self){
                    image.itemProvider.loadObject(ofClass: UIImage.self){ newImage, error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            if let newImage = newImage as? UIImage {
                                let flippedImage = UIImage(cgImage: newImage.cgImage!, scale: newImage.scale, orientation: newImage.imageOrientation)

                                self.parent.results.append(
                                    Identifiable_Media(media:
                                                        Identifiable_UIImage(rawImage: newImage.fixOrientation())
                                    )
                                )
                                print("orientation -- \((newImage as! UIImage).imageOrientation.rawValue)")
                                print("orientation -- \((newImage as! UIImage).imageOrientation )")
                                print("\(UIImage.Orientation.up)")
                                if self.updater != nil {
                                    self.updater = Int.random(in: 0...1000)
                                }
                            } else {
                                print("could not type cast newImage to UIImage")
                            }
                            
                        }
                    }
                } else if  image.itemProvider.hasItemConformingToTypeIdentifier("com.apple.quicktime-movie") || image.itemProvider.hasItemConformingToTypeIdentifier("public.mpeg-4"){
                    print("loaded asset is a video")
                    image.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.movie", completionHandler: {url, error in
                        if let error = error {
                            print("error getting url - \(error)")
                        } else if let url = url{
                            print("no error getting url - \(url)")
//                            self.parent.results.append(Identifiable_Media(media: Identifiable_Video(videoLocation: url.absoluteString)))
                            
                            let fileName = "\(Date().timeIntervalSince1970).\(url.pathExtension)"
                            let newUrl = URL(fileURLWithPath: NSTemporaryDirectory() + fileName)
                            try? FileManager.default.copyItem(at: url, to: newUrl)
                            DispatchQueue.main.async {
                                print("copied item")
                                self.parent.results.append(Identifiable_Media(media: Identifiable_Video(videoLocation: newUrl.absoluteString)))
                            }
                            
                        } else {
                            print("no error, however the URL was also invalid")
                        }
                    })
//                    image.itemProvider.loadDataRepresentation(forTypeIdentifier: "com.apple.quicktime-movie", completionHandler: {data, error in
//                        if let error = error {
//                            print(error)
//                        } else {
//                            print("no error")
//                            print("\(data)")
//                        }
//                    })
                } else {
                    print("loaded asset is neither an image or a video")
                }
            }
//            let identifiers = results.compactMap(\.assetIdentifier)
//                            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
//
//
////            let itemprovider = results.first?.itemProvider
//            print(fetchResult)
//            print("a")
//            self.results.append(contentsOf: results)
            parent.isPresented = false // Set isPresented to false because picking has finished.
        }
        
        
    }
}

//struct PhotoPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoPickerView()
//    }
//}


public extension UIImage {

    /// Extension to fix orientation of an UIImage without EXIF
    func fixOrientation() -> UIImage {

        guard let cgImage = cgImage else { return self }

        if imageOrientation == .up { return self }

        var transform = CGAffineTransform.identity

        switch imageOrientation {

        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(M_PI))

        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))

        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))

        case .up, .upMirrored:
            break
        }

        switch imageOrientation {

        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)

        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)

        case .up, .down, .left, .right:
            break
        }

        if let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {

            ctx.concatenate(transform)

            switch imageOrientation {

            case .left, .leftMirrored, .right, .rightMirrored:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))

            default:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }

            if let finalImage = ctx.makeImage() {
                return (UIImage(cgImage: finalImage))
            }
        }

        // something failed -- return original
        return self
    }
}
