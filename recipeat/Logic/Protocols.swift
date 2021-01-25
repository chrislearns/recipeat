//
//  Protocols.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/18/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import Foundation
protocol LikeableCommentable {
  func topic_LIKE() -> String
    func topic_COMMENT() -> String
}


protocol TruncableRP {
    var truncked: trunc_RecipePost { get }
}

extension RecipePost: TruncableRP {
    
    var truncked: trunc_RecipePost {
        get {
            return trunc_RecipePost(id: self.id, title: self.title, subtitle: self.subtitle, dateCreate: self.dateCreate, likes:self.likes)
        }
        set {
            self.id = newValue.id
            self.title = newValue.title
            self.subtitle = newValue.subtitle
            self.dateCreate = newValue.dateCreate
            self.likes = newValue.likes
            
        }
    }
}

protocol MediaTypeProtocol {
}
