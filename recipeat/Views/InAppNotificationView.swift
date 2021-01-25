//
//  InAppNotificationView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 10/7/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import Foundation
import SwiftUI




struct LabelView: View {
    var text:String
    var body: some View {
        VStack {
            HStack {
                
                
                Text(text)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    
                Spacer()
            }.padding(10)
            .background(verifiedDarkBlue.opacity(0.92))
            .cornerRadius(10)
            .shadow(radius: 3)
            Spacer()
        }.padding(.horizontal, 10)
        
    }
}

func InAppNotication(text:String, color:Color = verifiedDarkBlue.opacity(0.8), duration: Double = 2){
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text


        label.sizeToFit()
        return label.frame.height
    }

    let height = heightForView(text: text, font: UIFont.systemFont(ofSize: 18), width: UniversalSquare.width - 60)
    print(height)//Output : 41.0

    let keyWindow: UIView = (UIApplication.shared.windows.first ?? UIWindow())
    let yOffset:CGFloat = -100
    
    
    
    let label = UIHostingController(rootView: LabelView(text:text))
    
    
    label.view.translatesAutoresizingMaskIntoConstraints = false
    label.view.frame = CGRect.init(x: 0, y: yOffset, width: UniversalSquare.width, height: height)
    label.view.backgroundColor = .clear
    label.view.alpha = 0
    

    keyWindow.addSubview(label.view)
    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: { () -> Void in
        label.view.frame.origin.y = UniversalSafeOffsets?.top ?? 0 + 50
        label.view.alpha = 1

    }, completion: {_ in
        UIView.animate(withDuration: 0.5, delay: duration, options: [.curveEaseInOut], animations: { () -> Void in
            label.view.frame.origin.y = -100
            label.view.alpha = 0

        }, completion: {_ in

        })
    })

}
