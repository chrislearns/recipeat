//
//  ImagePicker.swift
//  recipeat
//
//  Created by Christopher Guirguis on 3/11/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import Foundation
import SwiftUI


enum PickerMultiplicityType {
    case Single, Multiple
}


//----------- imagePicker - UIViewControllerRepresentable


struct imagePicker:UIViewControllerRepresentable {
    @Binding var images: [Identifiable_UIImage]
    var allowsEditing:Bool = true
    var multiplicity = PickerMultiplicityType.Single
    var pickedClosure:(Identifiable_UIImage) -> Void = {_ in print("image picked")}
    
    typealias UIViewControllerType = UIImagePickerController
    typealias Coordinator = imagePickerCoordinator
    
    var sourceType:UIImagePickerController.SourceType = .camera
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<imagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = allowsEditing
        return picker
    }
    
    func makeCoordinator() -> imagePicker.Coordinator {
        return imagePickerCoordinator(images: $images, multiplicity: multiplicity, pickedClosure: pickedClosure)
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<imagePicker>) {
        
    }
    
}


//------------------ COORDINATOR
class imagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Binding var images: [Identifiable_UIImage]
    var pickedClosure:(Identifiable_UIImage) -> Void = {_ in print("image picked")}
    var multiplicity:PickerMultiplicityType
    
    init(images:Binding<[Identifiable_UIImage]>, multiplicity:PickerMultiplicityType, pickedClosure:@escaping (Identifiable_UIImage) -> Void) { 
        _images = images
        self.pickedClosure = pickedClosure
        self.multiplicity = multiplicity
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let uiimage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            let sanitizedImage = uiimage.sanitize_AR()
            print("picked images with AR: \(sanitizedImage.aspectRatio())")
            if multiplicity == PickerMultiplicityType.Multiple{
                images.append(
                    Identifiable_UIImage(rawImage: sanitizedImage)
                )
            } else {
                images = [Identifiable_UIImage(rawImage: sanitizedImage)]
            }
            
            pickedClosure(Identifiable_UIImage(rawImage: sanitizedImage))
        }
    }
}
