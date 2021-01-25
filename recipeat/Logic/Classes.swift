//
//  Classes.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/16/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import Foundation
import SwiftUI
import LightCompressor
import Firebase
import AVFoundation



class Ingredient:NSObject, Identifiable, NSCoding {
    var id = UUID()
    var name:String
    var amount:Double
    var amountUnit: IngredientUnit
//    override func hash(into hasher: inout Hasher) {
//        hasher.combine(name)
//        hasher.combine(id)
//    }
    
    static func ==(lhs: Ingredient, rhs: Ingredient) -> Bool {
        return
                lhs.id.uuidString == rhs.id.uuidString &&
                lhs.name == rhs.name &&
                lhs.amount == rhs.amount &&
                lhs.amountUnit == rhs.amountUnit
        
    }
    
    unowned var dictionary: dictClass {
        return dictClass(value: [
        
            "id": id.uuidString,
            "name": name,
            "amount": amount,
            "amountUnit":amountUnit.rawValue
        ])
    }

    init(id:UUID = UUID(), name:String, amount:Double, amountUnit:IngredientUnit){
        self.id = id
        self.name = name
        self.amount = amount
        self.amountUnit = amountUnit
    }
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? UUID ?? UUID()
        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        amount = aDecoder.decodeObject(forKey: "amount") as? Double ?? -1
        amountUnit = IngredientUnit(rawValue: aDecoder.decodeObject(forKey: "amountUnit") as? String ?? "") ?? .none
    }
    
    func encode(with aCoder : NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(amount, forKey: "amount")
        aCoder.encode(amountUnit.rawValue, forKey: "amountUnit")
    }
    
    
}

class Step: NSObject, Identifiable, NSCoding{
    var id = UUID()
    var subtitle:String
    
    static func ==(lhs: Step, rhs: Step) -> Bool {
        return lhs.subtitle == rhs.subtitle && lhs.id.uuidString == rhs.id.uuidString
    }
    
    unowned var dictionary: dictClass {
        return dictClass(value: [
            "id": id.uuidString,
            "subtitle": subtitle
        ])
    }
    
    init(id:UUID = UUID(), subtitle:String){
        self.id = id
        self.subtitle = subtitle
    }
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? UUID ?? UUID()
        subtitle = aDecoder.decodeObject(forKey: "subtitle") as? String ?? ""
    }
    
    func encode(with aCoder : NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(subtitle, forKey: "subtitle")
    }
}

class TagEntity:NSObject, Identifiable, NSCoding{
    var id = UUID()
    var keywords:[String]
    var dbVal:String
    var displayVal:String
    
    static func ==(lhs: TagEntity, rhs: TagEntity) -> Bool {
        return
                lhs.id.uuidString == rhs.id.uuidString &&
                lhs.keywords == rhs.keywords &&
                lhs.dbVal == rhs.dbVal &&
                lhs.displayVal == rhs.displayVal
        
    }
    
    var dictionary: [String: Any] {
        return [
            "keywords": keywords,
            "dbVal":dbVal,
            "displayVal": displayVal
            
        ]
    }
    
    init(keywords:[String],dbVal:String,displayVal:String){
        self.keywords = keywords
        self.dbVal = dbVal
        self.displayVal = displayVal
    }
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? UUID ?? UUID()
        keywords = aDecoder.decodeObject(forKey: "keywords") as? [String] ?? []
        dbVal = aDecoder.decodeObject(forKey: "dbVal") as? String ?? ""
        displayVal = aDecoder.decodeObject(forKey: "displayVal") as? String ?? ""
    }
    func encode(with aCoder : NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(keywords, forKey: "keywords")
        aCoder.encode(dbVal, forKey: "dbVal")
        aCoder.encode(displayVal, forKey: "displayVal")
    }
}

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            println("error saving image: kaefg 289fj")
        }
        print("Save finished!")
    }
}

class RecipeObject:NSObject, Identifiable, ObservableObject, NSCoding{
    var id:UUID
    @Published var recipe:RecipePost
    @Published var media:[Identifiable_Media]
    
    init(recipe:RecipePost, media:[Identifiable_Media]){
        self.recipe = recipe
        self.media = media
        self.id = recipe.id
    }
    
    convenience override init() {
        self.init(
            recipe: RecipePost(),
            media: []
        )
    }
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? UUID ?? UUID()
        recipe = aDecoder.decodeObject(forKey: "recipe") as? RecipePost ?? RecipePost()
        media = aDecoder.decodeObject(forKey: "media") as? [Identifiable_Media] ?? []
    }
    func encode(with aCoder : NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(recipe, forKey: "recipe")
        aCoder.encode(media, forKey: "media")
    }
    
    func isEmpty() -> Bool{
        if self.recipe.isEmpty() && self.media.count == 0 {
            return true
        } else {
            return false
        }
    }
    
}
class RecipePost:NSObject, Identifiable, LikeableCommentable, ObservableObject, NSCoding {
    
    func topic_LIKE() -> String {
        return "recipe_\(self.id.uuidString)_likes"
    }
    
    func topic_COMMENT() -> String {
        return "recipe_\(self.id.uuidString)_comments"
    }
    
    var id = UUID()
    @Published var title:String
    var steps:[Step]
    var ingredients:[Ingredient]
    var isFeatureEligible:Bool
    var postingUser:trunc_user
    var subtitle:String
    var likes:[UUID]
    var dateCreate:String
    var tags:[TagEntity]
    var timePrep:Int
    var timeCook:Int
    var timeOther:Int
    var estimatedServings:String
    var flagged:Bool
    
    var truncForm:trunc_RecipePost {
        return trunc_RecipePost(id: self.id, title: self.title, subtitle: self.subtitle, dateCreate: self.dateCreate, likes:likes)
    }
    
    func isEmpty() -> Bool {
        if title == "" &&
            steps.count == 0 &&
            ingredients.count == 0 &&
            subtitle == "" {
            return true
        } else {
            return false
        }
        
    }
    static func ==(lhs: RecipePost, rhs: RecipePost) -> Bool {
        return lhs.title == rhs.title
            && lhs.steps == rhs.steps
            && lhs.ingredients == rhs.ingredients
            && lhs.isFeatureEligible == rhs.isFeatureEligible
            && lhs.postingUser == rhs.postingUser
            && lhs.subtitle == rhs.subtitle
            && lhs.likes == rhs.likes
            && lhs.dateCreate == rhs.dateCreate
            && lhs.tags == rhs.tags
            && lhs.timePrep == rhs.timePrep
            && lhs.timeCook == rhs.timeCook
            && lhs.timeOther == rhs.timeOther
            && lhs.estimatedServings == rhs.estimatedServings
            && lhs.flagged == rhs.flagged
        
    }
    
    
    var dictionary: [String: Any] {
        return [
            "id": id.uuidString,
            "title":title,
            "steps": steps.formatForFirebase(),
            "ingredients": ingredients.formatForFirebase(),
            "postingUser":postingUser.dictionary.value,
            "subtitle":subtitle,
            "likes": likes.formatForFirebase(),
            "tags": tags.dbValue_StringArray(),
            "timePrep":timePrep,
            "timeCook":timeCook,
            "timeOther":timeOther,
            "estimatedServings":estimatedServings,
            "flagged":flagged,
            "isFeatureEligible": isFeatureEligible
        ]
    }
    var fireBaseFormat: [String:Any] {
        //Setup the starting point
        var returnVal = self.dictionary
        
        //1. Obtain basic title tags
        let titleTags = title.alphanumerics_andWhiteSpace.lowercased().components(separatedBy: " ")
        returnVal["tags_title"] = titleTags
        
        //2. Obtain ingredient tags
        var ingredientTags:[String] = []
        for ingredient in ingredients {
            ingredientTags.append(ingredient.name.alphanumerics_andWhiteSpace.lowercased())
        }
        returnVal["tags_ingredients"] = ingredientTags
        
        //3. Remove info about the likes from what is being uploaded - CRUCIAL because you dont want a local knowledge of these thigns to override changes that were made on the DB while this was loaded on the user's phone
//        returnVal["quantity_likes"] = likes.count
        
        //4. Create a lowercased version of the title
        let lowerCasedTitle = title.alphanumerics_andWhiteSpace.lowercased()
        returnVal["lowercased_title"] = lowerCasedTitle
        
        //5. Enumerate the numer of likes the post has
        returnVal["quantity_ingredients"] = ingredients.count
        
        //6. Enumerate the numer of likes the post has
        returnVal["quantity_steps"] = steps.count
        
        
        
        return returnVal
        
        
    }
    
    init(id:UUID, title:String, subtitle:String, steps:[Any], ingredients:[Any], postingUser:Any, likes:[Any], dateCreate:String = "", tags: [Any], timePrep:Int, timeCook:Int, timeOther:Int, estimatedServings: String, flagged:Bool, isFeatureEligible: Bool){
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.steps = steps.toSteps()
        self.ingredients = ingredients.toIngredients()
        
        self.flagged = flagged
        
        self.likes = likes.toUUID()
        self.tags = tags.toTags()
        self.isFeatureEligible = isFeatureEligible
        
        self.dateCreate = dateCreate
        
        if let postingUser = postingUser as? trunc_user {
            self.postingUser = postingUser
        } else if let postingUser = postingUser as? [String:Any] {
            self.postingUser = trunc_user(
                id: UUID(uuidString: postingUser["id"] as? String ?? UUID().uuidString) ?? UUID(),
                username: postingUser["username"] as? String ?? "Username Error",
                name: postingUser["name"] as? String ?? "Name Error",
                verified: false)
        } else {
            println("failed to unwrap posting user - resorted to truncated form of convenience initialized user")
            self.postingUser = user().truncForm
        }
        
        self.timePrep = timePrep
        self.timeCook = timeCook
        self.timeOther = timeOther
        self.estimatedServings = estimatedServings
    }
    convenience override init() {
        self.init(
            id: UUID(),
            title: "",
            subtitle: "",
            steps: [],
            ingredients: [],
            postingUser: trunc_user(id: UUID(), username: "", name: "", verified: false),
            likes: [],
            dateCreate:"",
            tags: [],
            timePrep:0,
            timeCook:0,
            timeOther:0,
            estimatedServings: "",
            flagged:false,
            isFeatureEligible:false
        )
        
    }
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? UUID ?? UUID()
        title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        steps = aDecoder.decodeObject(forKey: "steps") as? [Step] ?? []
        ingredients = aDecoder.decodeObject(forKey: "ingredients") as? [Ingredient] ?? []
        isFeatureEligible = aDecoder.decodeObject(forKey: "isFeatureEligible") as? Bool ?? false
        postingUser = aDecoder.decodeObject(forKey: "followers") as? trunc_user ?? user().truncForm
        subtitle = aDecoder.decodeObject(forKey: "subtitle") as? String ?? ""
        dateCreate = aDecoder.decodeObject(forKey: "subtitle") as? String ?? ""
        likes = aDecoder.decodeObject(forKey: "likes") as? [UUID] ?? []
        tags = aDecoder.decodeObject(forKey: "tags") as? [TagEntity] ?? []
        timePrep = aDecoder.decodeObject(forKey: "timePrep") as? Int ?? 0
        timeCook = aDecoder.decodeObject(forKey: "timeCook") as? Int ?? 0
        timeOther = aDecoder.decodeObject(forKey: "timeOther") as? Int ?? 0
        estimatedServings = aDecoder.decodeObject(forKey: "estimatedServings") as? String ?? ""
        flagged = aDecoder.decodeObject(forKey: "flagged") as? Bool ?? false
    }
    func encode(with aCoder : NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(steps, forKey: "steps")
        aCoder.encode(ingredients, forKey: "ingredients")
        aCoder.encode(isFeatureEligible, forKey: "isFeatureEligible")
        aCoder.encode(postingUser, forKey: "postingUser")
        aCoder.encode(subtitle, forKey: "subtitle")
        aCoder.encode(likes, forKey: "likes")
        aCoder.encode(dateCreate, forKey: "dateCreate")
        aCoder.encode(tags, forKey: "tags")
        aCoder.encode(timePrep, forKey: "timePrep")
        aCoder.encode(timeCook, forKey: "timeCook")
        aCoder.encode(timeOther, forKey: "timeOther")
        aCoder.encode(estimatedServings, forKey: "estimatedServings")
        aCoder.encode(flagged, forKey: "flagged")
        
    }
}


class Identifiable_Video:MediaTypeProtocol{
    var id:UUID = UUID()
    var videoLocation:String
    func getVideoDimensions() -> CGSize? {
        
        guard let track = AVURLAsset(url: URL(string: self.videoLocation)!).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return size
    }
    init(videoLocation: String){
        self.videoLocation = videoLocation
    }
    
    func getCompressedVideo(compressionCompletion: @escaping (completionHander_outcome, URL?) -> Void){
        let videoCompressor = LightCompressor()
        guard let sourceURL = URL(string: videoLocation) else {return}
//        guard let destURL = URL(fileURLWithPath: "temp\(UUID().uuidString)_compressed") else {return}
        let destURL = URL(fileURLWithPath: "temp\(UUID().uuidString)_compressed")
        let compression: Compression = videoCompressor.compressVideo(
            source: sourceURL,
            destination: destURL,
                                        quality: .medium,
                                        isMinBitRateEnabled: true,
                                        keepOriginalResolution: false,
                                        progressQueue: .main,
                                        progressHandler: { progress in
                                            // progress
//                                            print("progress - \(progress.fractionCompleted)")
                                        },
                                        completion: {[weak self] result in
                                            guard let `self` = self else { return }
                                                     
                                            switch result {
                                            case .onSuccess(let path):
                                                // success
                                            print("success")
                                                
                                                compressionCompletion(completionHander_outcome.success, path)
                                                         
                                            case .onStart:
                                                // when compression starts
                                                print("started")
                                                
                                                         
                                            case .onFailure(let error):
                                                // failure error
                                                print("failed - \(error.localizedDescription)")
                                                compressionCompletion(completionHander_outcome.failed, nil)
                                                         
                                            case .onCancelled:
                                                // if cancelled
                                                print("cancelled")
                                                compressionCompletion(completionHander_outcome.cancelled, nil)
                                            }
                                        }
         )

    }

}

class trunc_RecipePost:NSObject, Identifiable, NSCoding, LikeableCommentable {
    func topic_LIKE() -> String {
        return "recipe_\(self.id.uuidString)_likes"
    }
    
    func topic_COMMENT() -> String {
        return "recipe_\(self.id.uuidString)_comments"
    }
    var id = UUID()
    var title:String
    var subtitle:String
    var dateCreate:String
    var likes:[UUID]
    
    var imageDict:[ThumbnailSizes:UIImage] = [:]
    
    var dictionary: [String: Any] {
        return [
            "id": id.uuidString,
            "title": title,
            "subtitle":subtitle,
            "dateCreate":dateCreate,
            "likes": likes.formatForFirebase()
        ]
    }
    
    init(id:UUID? = nil, title:String, subtitle:String, dateCreate:String, likes:[Any]){
        if let id = id {
            self.id = id
        } else {
            self.id = UUID()
        }
        
        self.title = title
        self.subtitle = subtitle
        self.dateCreate = dateCreate
        self.likes = likes.toUUID()
    }
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? UUID ?? UUID()
        title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        subtitle = aDecoder.decodeObject(forKey: "subtitle") as? String ?? ""
        dateCreate = aDecoder.decodeObject(forKey: "dateCreate") as? String ?? ""
        likes = aDecoder.decodeObject(forKey: "likes") as? [UUID] ?? []
    }
    func encode(with aCoder : NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(subtitle, forKey: "subtitle")
        aCoder.encode(dateCreate, forKey: "dateCreate")
        aCoder.encode(likes, forKey: "likes")
    }
    
    
}

class Comment:Identifiable {
    var id = UUID()
    var commentingUser:trunc_user
    var assocRecipe:String
    var message:String
    var dateCreate:String
    var flagged:Bool
    
    var dictionary: [String: Any] {
        return [
            "id": id.uuidString,
            "commentingUser":commentingUser.dictionary.value,
            "assocRecipe":assocRecipe,
            "message":message,
            "dateCreate":dateCreate,
            "flagged":flagged
        ]
    }
    
    init(id:UUID? = nil, commentingUser:Any, assocRecipe:String, message:String, dateCreate:String = "", flagged:Bool){
        if let id = id {
            self.id = id
        } else {
            self.id = UUID()
        }
        
        self.flagged = flagged
        if let commentingUser = commentingUser as? trunc_user {
            self.commentingUser = commentingUser
        } else if let commentingUser = commentingUser as? [String:Any] {
            self.commentingUser = trunc_user(
                id: UUID(uuidString: commentingUser["id"] as? String ?? UUID().uuidString) ?? UUID(),
                username: commentingUser["username"] as? String ?? "Username Error",
                name: commentingUser["name"] as? String ?? "Name Error",
                verified: false)
        } else {
            println("failed to unwrap posting user - resorted to truncated form of convenience initialized user")
            self.commentingUser = user().truncForm
        }
        
        
        self.assocRecipe = assocRecipe
        self.message = message
        
        self.dateCreate = dateCreate
    }
    
    convenience init() {
        self.init(
            id: UUID(),
            commentingUser: user().truncForm,
            assocRecipe: "",
            message: "",
            dateCreate: "",
            flagged:false
        )
        
    }
    
    
}

class user:NSObject, Identifiable, NSCoding{
    var id = UUID()
    var username:String
    var password:String
    var bio:String
    var verified:Bool
    var isAdmin:Bool
    var name:String
    var email:String
    var publishedRecipes:[trunc_RecipePost]?
    var followers:[trunc_user]?
    var following:[trunc_user]?
    var quantity_followers:Int
    var quantity_following:Int
    var likes:[UUID]
    var firstTimeUser:Bool
    var referralCode_distributal:String
    var referralCode_claimed:String
    var flagged:Bool
    var blocked:[UUID]
    var blockedBy:[UUID]
    var hiddenContent:[String]
    
    unowned var truncForm:trunc_user {
        return trunc_user(id: self.id, username: self.username, name: self.name, verified: self.verified)
    }
    
    unowned var dictionary: dictClass {
        return dictClass(value: [
            "id": id.uuidString,
            "bio": bio,
            "verified": verified,
            "username": username,
            "password":password,
            "name":name,
            "email":email,
            "likes":likes.formatForFirebase(),
            "firstTimeUser":firstTimeUser,
            "referralCode_distributal":referralCode_distributal,
            "referralCode_claimed":referralCode_claimed,
            "flagged":flagged,
            "isAdmin":isAdmin
        ])
    }
    
    var fireBaseFormat: [String:Any] {
        //Setup the starting point
        var returnVal = self.dictionary.value
        
        //1. Obtain basic name tags
        let nameTags = name.alphanumerics_andWhiteSpace.lowercased().components(separatedBy: " ")
        returnVal["tags_name"] = nameTags
        
        //2. Create a lowercased versions of the name
        let lowerCasedName = name.alphanumerics_andWhiteSpace.lowercased()
        returnVal["lowercased_name"] = lowerCasedName
        
        //3. Create a lowercased version of the username
        let lowerCasedUserName = username.alphanumerics_andWhiteSpace.lowercased()
        returnVal["lowercased_username"] = lowerCasedUserName
        
        return returnVal
    }
    
    init(id: UUID, username:String, password:String, name:String, email:String, publishedRecipes:[Any]?, following:[Any]?, followers:[Any]?, quantity_followers:Int, quantity_following:Int, bio:String, verified:Bool, likes:[Any], blocked:[Any], blockedBy:[Any], firstTimeUser:Bool, referralCode_distributal:String, referralCode_claimed:String, flagged:Bool, hiddenContent:[String], isAdmin:Bool){
        self.username = username
        self.verified = verified
        self.bio = bio
        self.password = password
        self.name = name
        self.email = email
        self.id = id
        self.likes = likes.toUUID()
        self.blocked = blocked.toUUID()
        self.blockedBy = blockedBy.toUUID()
        self.firstTimeUser = firstTimeUser
        self.referralCode_distributal = referralCode_distributal
        self.referralCode_claimed = referralCode_claimed
        self.flagged = flagged
        self.hiddenContent = hiddenContent
        self.isAdmin = isAdmin
        
        
        if let publishedRecipes = publishedRecipes {
            self.publishedRecipes = publishedRecipes.toTruncRecipe()
        }

        if let followers = followers {
            self.followers = followers.toTruncUser()
        }

        if let following = following {
            self.following = following.toTruncUser()
        }
        
        self.quantity_followers = quantity_followers
        self.quantity_following = quantity_following
        
    }
    convenience override init() {
        self.init(id: UUID(),
                  username: "",
                  password: "",
                  name: "",
                  email: "",
                  publishedRecipes: nil,
                  following: nil,
                  followers: nil,
                  quantity_followers: 0,
                  quantity_following: 0,
                  bio: "",
                  verified: false,
                  likes:[],
                  blocked:[],
                  blockedBy:[],
                  firstTimeUser:false,
                  referralCode_distributal:"",
                  referralCode_claimed:"",
                  flagged:false,
                  hiddenContent:[],
                  isAdmin: false
            
        )
        
    }
    
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? UUID ?? UUID()
        bio = aDecoder.decodeObject(forKey: "bio") as? String ?? ""
        verified = aDecoder.decodeObject(forKey: "verified") as? Bool ?? false
        username = aDecoder.decodeObject(forKey: "username") as? String ?? ""
        password = aDecoder.decodeObject(forKey: "password") as? String ?? ""
        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        email = aDecoder.decodeObject(forKey: "email") as? String ?? ""
        publishedRecipes = aDecoder.decodeObject(forKey: "publishedRecipes") as? [trunc_RecipePost] ?? []
        followers = aDecoder.decodeObject(forKey: "followers") as? [trunc_user] ?? []
        following = aDecoder.decodeObject(forKey: "following") as? [trunc_user] ?? []
        quantity_followers = aDecoder.decodeObject(forKey: "quantity_followers") as? Int ?? 0
        quantity_following = aDecoder.decodeObject(forKey: "quantity_following") as? Int ?? 0
        likes = aDecoder.decodeObject(forKey: "likes") as? [UUID] ?? []
        blocked = aDecoder.decodeObject(forKey: "blocked") as? [UUID] ?? []
        blockedBy = aDecoder.decodeObject(forKey: "blockedBy") as? [UUID] ?? []
        firstTimeUser = aDecoder.decodeObject(forKey: "firstTimeUser") as? Bool ?? false
        referralCode_distributal = aDecoder.decodeObject(forKey: "referralCode_distributal") as? String ?? ""
        referralCode_claimed = aDecoder.decodeObject(forKey: "referralCode_claimed") as? String ?? ""
        flagged = aDecoder.decodeObject(forKey: "flagged") as? Bool ?? false
        hiddenContent = aDecoder.decodeObject(forKey: "hiddenContent") as? [String] ?? []
        isAdmin = aDecoder.decodeObject(forKey: "isAdmin") as? Bool ?? false
    }
    func encode(with aCoder : NSCoder) {
        aCoder.encode(id, forKey: "id")
        
        aCoder.encode(bio, forKey: "bio")
        aCoder.encode(verified, forKey: "verified")
        
        aCoder.encode(username, forKey: "username")
        aCoder.encode(password, forKey: "password")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(publishedRecipes, forKey: "publishedRecipes")
        aCoder.encode(followers, forKey: "followers")
        aCoder.encode(following, forKey: "following")
        aCoder.encode(quantity_followers, forKey: "quantity_followers")
        aCoder.encode(quantity_following, forKey: "quantity_following")
        aCoder.encode(likes, forKey: "likes")
        aCoder.encode(blocked, forKey: "blocked")
        aCoder.encode(blockedBy, forKey: "blockedBy")
        aCoder.encode(firstTimeUser, forKey: "firstTimeUser")
        aCoder.encode(referralCode_distributal, forKey: "referralCode_distributal")
        aCoder.encode(referralCode_claimed, forKey: "referralCode_claimed")
        aCoder.encode(flagged, forKey: "flagged")
        aCoder.encode(hiddenContent, forKey: "hiddenContent")
        aCoder.encode(isAdmin, forKey: "isAdmin")
    }
    
}

class trunc_user:NSObject, Identifiable, NSCoding  {
    var id = UUID()
    var username:String
    var name:String
    var verified:Bool
    
    
    var dictionary: dictClass {
        return dictClass(value: [
            "id": id.uuidString,
            "username": username,
            "name":name,
            "verified":verified
        ])
    }
    
    static func ==(lhs: trunc_user, rhs: trunc_user) -> Bool {
        return
                lhs.id.uuidString == rhs.id.uuidString &&
                lhs.username == rhs.username &&
                lhs.name == rhs.name &&
                lhs.verified == rhs.verified
        
    }
    
    init(username:String, name:String, verified:Bool){
        self.username = username
        self.name = name
        self.verified = verified
    }
    init(id: UUID, username:String, name:String, verified:Bool){
        self.id = id
        self.username = username
        self.name = name
        self.verified = verified
    }
    deinit {
        println("truncuser \(name) is being deinitialized", 2)
    }
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? UUID ?? UUID()
        username = aDecoder.decodeObject(forKey: "username") as? String ?? ""
        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        verified = aDecoder.decodeObject(forKey: "verified") as? Bool ?? false
    }
    func encode(with aCoder : NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(verified, forKey: "verified")
    }
}

class dictClass {
    var value:[String: Any]
    
    init(value: [String:Any]){
        self.value = value
    }
    
    deinit {
        println("dictClass is being deinitialized", 2)
    }
}

class GlobalEnvironment: ObservableObject {
    
    //These items let us control the tab selection as well as the status of the NavigationUnit of the home tab. It will be used for deeplinking purposes
    @Published var TabSelection = 0
    @Published var DeeplinkNavUnit = HashableNavigationUnit()
    
    @Published var alertShown = false
    
    @Published var isLoggedIn = false
    
    //Banner Toggles ----------------/
    @Published var bToggleTabbedRoot = false
    @Published var bDataTabbedRoot: BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Info)
    //Banner Toggles END ----------------/
    
    @Published var tabBarHeight:CGFloat = 40
    
    
    
    @Published var currentUser: user = user.init(id: UUID(), username: "", password: "", name: "", email: "", publishedRecipes: [] , following: [], followers: [], quantity_followers: 0, quantity_following: 0, bio: "", verified: false, likes: [], blocked: [], blockedBy: [], firstTimeUser: false, referralCode_distributal: "", referralCode_claimed: "", flagged: false, hiddenContent: [], isAdmin: false)
    
    
    @Published var unfinishedRecipes:[String:RecipePost] = [
        UUID().uuidString:RecipePost(id: UUID(), title: "Potato soup", subtitle: "yum", steps: [], ingredients: [], postingUser: user().truncForm, likes: [], tags: [], timePrep: 0, timeCook: 0, timeOther: 0, estimatedServings: "0", flagged: false, isFeatureEligible: false)
    ]
    
    @Published var listenerCatalog:[String:ListenerRegistration] = [:]
    @Published var subscriptionCatalog:[String] = []
    
    @Published var loaderShown = false
    @Published var loaderText = ""//"Something's cookin' in the kitchen..."
    
    @Published var PopularRecipes = SearchResults(results: [], timeStamp: nil)
    @Published var NewRecipes = RecipeResults(results: [], timeStamp: nil)
    @Published var PopularUser = SearchResults(results: [], timeStamp: nil)
    
    @Published var NewsFeedResults = RecipeResults(results: [], timeStamp: nil)
    
    
}

