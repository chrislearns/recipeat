//
//  REP_TextView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 6/7/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import UIKit
import SwiftUI
import Combine
import Foundation

struct REP_TextView: View, UIViewRepresentable {
    
    @Binding var text: String
    let keyboardType: UIKeyboardType
    
    func makeUIView(context: Context) -> DoneButton {

        let field = DoneButton()
        field.keyboardType = keyboardType
        field.textBinding = $text
        field.configure()
//        field.borderStyle = .roundedRect
        
        return field
        
    }

    func updateUIView(_ uiView: DoneButton, context: Context) {
        uiView.text = text
    }
}

class DoneButton: UITextView, UITextViewDelegate, ObservableObject {
    
    var toolbar: UIToolbar?
        
    var textBinding: Binding<String>? {
        didSet {
            text = textBinding?.wrappedValue
        }
    }
    
    var subscription: AnyCancellable?
    
    func configure() {
        if toolbar == nil {
            toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: (self.window?.bounds.width ?? 300.0), height: 44.0))
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
            toolbar?.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton]
            self.inputAccessoryView = toolbar
        }
        
        self.delegate = self
     
        subscription = NotificationCenter.default.publisher(for: UITextView.textDidChangeNotification, object: self)
            .sink { _ in
                self.textBinding?.wrappedValue = self.text ?? ""
        }
    }

    @objc func handleDone() {
        self.resignFirstResponder()
    }
    
}
