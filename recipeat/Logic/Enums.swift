//
//  Enums.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/15/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase


enum BannerType {
    case Info
    case Warning
    case Success
    case Error
    
    var tintColor: Color {
        switch self {
        case .Info:
            return verifiedDarkBlue.opacity(0.9)
        case .Success:
            return lightGreen.opacity(0.9)
        case .Warning:
            return lightYellow
        case .Error:
            return darkRed.opacity(0.9)
        }
    }
}

enum FSArrayAction {
    case union, remove
}
enum IngredientUnit:String, CaseIterable {
    case none = ""
    case can = "can"
    case cube = "cube"
    case cup = "cup"
    case dash = "dash"
    case drizzle = "drizzle"
    case drop = "drop"
    case g = "g"
    case kg = "kg"
    case jar = "jar"
    case L = "L"
    case lb = "lb"
    case mg = "mg"
    case mL = "mL"
    case oz = "oz"
    case package = "package"
    case piece = "piece"
    case pinch = "pinch"
    case slice = "slice"
    case strip = "strip"
    case tablespoon = "tablespoon"
    case teaspoon = "teaspoon"
    case tub = "tub"
    case whole = "whole"
}

enum new_StepOrIngredient {
    case Step, Ingredient
}

enum ContentPriority{
    case recent, popular
}

enum NavigationDestination: Int {
    case RecipePostView = 1, UserHomeView, ModifyRecipePostView, ListUser, CategoryView, EditProfileView, ClaimRewardsView, ImagePickerView, ReportView

}

enum UserDefaultKeys:String {
    case LastLoggedInObject = "lastLogin_objects"
    case UnfinishedRecipes = "unfinishedRecipes"
    
}

enum RecipeatEntity:String{
    case Recipe = "Recipe"
    case User = "User"
    case Comment = "Comment"
    func minimized() -> String{
        if self == .Recipe {
            return "rp"
        } else if self == .User {
            return "u"
        } else if self == .Comment {
            return "com"
        } else {
            return ""
        }
        
    }
}

enum completionHander_outcome{
    case success, failed, cancelled
}

enum CacheDuration:Double {
    case Now = 0
    case Min1 = 60
    case Min5 = 300
    case Min15 = 900
    case Hour1 = 3600
    case Hour6 = 21600
    case Hour12 = 43200
    case Day1 = 86400
    case Day5 = 432000
    case Day10 = 864000
}

enum ThumbnailSizes:Int, CaseIterable {
    case sNone = 0
    case s64 = 64
    case s128 = 128
    case s256 = 256
    case s512 = 512
    case s1024 = 1024
    case s2048 = 2048
}

enum DragState {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}


enum fiveInterval: Int, CaseIterable {
    case m0 = 0
    case m5 = 5
    case m10 = 10
    case m15 = 15
    case m20 = 20
    case m25 = 25
    case m30 = 30
    case m35 = 35
    case m40 = 40
    case m45 = 45
    case m50 = 50
    case m55 = 55
    case m60 = 60
    case m65 = 65
    case m70 = 70
    case m75 = 75
    case m80 = 80
    case m85 = 85
    case m90 = 90
    case m95 = 95
    case m100 = 100
    case m105 = 105
    case m110 = 110
    case m115 = 115
    case m120 = 120
    case m125 = 125
    case m130 = 130
    case m135 = 135
    case m140 = 140
    case m145 = 145
    case m150 = 150
    case m155 = 155
    case m160 = 160
    case m165 = 165
    case m170 = 170
    case m175 = 175
    case m180 = 180
    case m185 = 185
    case m190 = 190
    case m195 = 195
    case m200 = 200
    case m205 = 205
    case m210 = 210
    case m215 = 215
    case m220 = 220
    case m225 = 225
    case m230 = 230
    case m235 = 235
    case m240 = 240
    case m245 = 245
    case m250 = 250
    case m255 = 255
    case m260 = 260
    case m265 = 265
    case m270 = 270
    case m275 = 275
    case m280 = 280
    case m285 = 285
    case m290 = 290
    case m295 = 295
    case m300 = 300
}
