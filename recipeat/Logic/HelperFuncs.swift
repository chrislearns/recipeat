//
//  HelperFuncs.swift
//  recipeat
//
//  Created by Christopher Guirguis on 3/9/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import FirebaseStorage
import FirebaseMessaging
import FirebaseFirestore
import Firebase
import SPAlert




func fraction_progress(lowerLimit: Double = 0, upperLimit:Double, current:Double, inverted:Bool = false) -> Double{
    var val:Double = 0
    if current >= upperLimit {
        val = 1
    } else if current <= lowerLimit {
        val = 0
    } else {
        val = (current - lowerLimit)/(upperLimit - lowerLimit)
    }
    
    if inverted {
        return (1 - val)
        
    } else {
        return val
    }
    
}



func firestoreRetrieve_document(docRef_string:String, completion: @escaping (completionHander_outcome, Any) -> Void, showDetails: Bool = false){
    
    let docRef = Firestore.firestore().document(docRef_string)
    println("fetching data - \(docRef_string)_")
    
    docRef.getDocument { (document, error) in
        if let document = document, document.exists {
            println("Document: \(String(describing: document))")
            completion(completionHander_outcome.success ,document as Any)
            
        } else {
            println("Document does not exist")
            completion(completionHander_outcome.failed, error as Any)
        }
    }
}

func firestoreSubmit_data(docRef_string:String, dataToSave:[String:Any], completion: @escaping (completionHander_outcome) -> Void, showDetails: Bool = false){
    
    var timeStampedData = dataToSave
    timeStampedData["dateCreate"] = currentTime_UTC()
    
    let docRef = Firestore.firestore().document(docRef_string)
    println("setting data")
    docRef.setData(timeStampedData){ (error) in
        if let error = error {
            println("error = \(error)")
            completion(.failed)
        } else {
            println("data uploaded successfully")
            if showDetails {
                println("dataUploaded = \(dataToSave)")
            }
            completion(.success)
        }
    }
}

func firebaseStorage_listAll(directory:String, completion: @escaping (Any) -> Void, showDetails: Bool = false){
    print("getting list of firebase storage assets")
    let storage = Storage.storage()
    let storageReference = storage.reference().child(directory)
    print("accessing reference of \(storageReference.fullPath)")
    storageReference.listAll { (result, error) in
        print("enter list completion closure")
        if let error = error {
            print(error)
            completion(false)
        } else {
        print("found the following items in \(directory)")
        
        for item in result.items {
            
            print(item.fullPath)
        }
        completion(result.items)
        }
    }
    print("finished listAll - this is not inside closure")
}

func currentTime_UTC() -> String {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss 'UTC'"
    return formatter.string(from: Date())
}

func date_fromTimeString_UTC(_ timeString:String) -> Date?{
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss 'UTC'"
    return formatter.date(from: timeString)
}
func FS_ArrayModify(docRef_string:String, field:String, value:Any, action: FSArrayAction, completion: @escaping (completionHander_outcome, Any) -> Void, showDetails: Bool = false){
    let docRef = Firestore.firestore().document(docRef_string)
    println("addting to array")
    let fieldValue = (action == .union) ? FieldValue.arrayUnion([value]) : FieldValue.arrayRemove([value])
    docRef.updateData([
        field: fieldValue
        ], completion: {(error) in
            if let error = error {
                println("err: 232f9 12dqkd = \(error)", 0)
                completion(completionHander_outcome.failed, false)
            } else {
                println("array modified successfully - \(action) + \(value)", 0)
                if showDetails {
                    println("dataUploaded = \(value)", 0)
                }
                completion(completionHander_outcome.success, true)
            }
    })
    
}
///*(1)*/FS_ArrayModify(docRef_string: "users/\(target_postingUser.id.uuidString)/publishedRecipes.\()", field: "likes", value: base_likerUser.id.uuidString, action: .union, completion: {_,_  in
///    completion(completionHander_outcome.success, nil)
///    print("")})
func firestoreUpdate_data(docRef_string:String, dataToUpdate:[String:Any], completion: @escaping (completionHander_outcome, Any) -> Void, showDetails: Bool = false){
    
    var timeStampedData = dataToUpdate
    timeStampedData["lastEdit"] = currentTime_UTC()
    
    let docRef = Firestore.firestore().document(docRef_string)
    println("updating data")
    docRef.setData(timeStampedData, merge: true){ (error) in
        if let error = error {
            println("error = \(error)")
            completion(completionHander_outcome.failed, false)
        } else {
            println("data uploaded successfully")
            if showDetails {
                println("dataUploaded = \(dataToUpdate)")
            }
            completion(completionHander_outcome.success, true)
        }
    }
}

func firestoreDelete_document(docRef_string:String, completion: @escaping (completionHander_outcome) -> Void, showDetails: Bool = false){
    
    
    let docRef = Firestore.firestore().document(docRef_string)
    
    docRef.delete() { err in
        if let err = err {
            println("Error removing document: \(err)", 0)
            completion(.failed)
        } else {
            println("data deleted successfully", 0)
            if showDetails {
                println("docRef_deleted = \(docRef_string)")
            }
            completion(.success)
        }
    }
    
}

func uploadImage(_ referenceString:String, image:UIImage, resizes:[ThumbnailSizes]? = nil, completion: @escaping (completionHander_outcome, Any) -> Void, showDetails: Bool = false){
    
    var taskCounter = ThumbnailSizes.allCases.count
    var resizableImage = image
    var modified_refString = referenceString
    
    let newMetadata = StorageMetadata()
    newMetadata.cacheControl = "public,max-age=300";
    
    for size in ThumbnailSizes.allCases {
        if size != .sNone {
            resizableImage = resizeImage(image: image, targetSize: CGSize(width: CGFloat(size.rawValue), height: CGFloat(size.rawValue)))
            modified_refString = referenceString + "/\(size.rawValue)"
        }
        if let imageData = resizableImage.compressTo(4){
            let storage = Storage.storage()
            println("storing image")
            storage.reference().child(modified_refString).putData(imageData, metadata: newMetadata){
                (strgMtdta, err) in
                println("storing process attempted")
                
                if let err = err {
                    println("an error has occurred - \(err.localizedDescription)")
                    taskCounter = taskCounter - 1
                    if taskCounter == 0 {
                        completion(completionHander_outcome.failed, err)
                    }
                } else {
                    println("image uploaded successfully")
                    taskCounter = taskCounter - 1
                    if taskCounter == 0 {
                        completion(completionHander_outcome.success, true)
                    }
                    
                }
            }
        } else {
            println("couldn't unwrap image as data")
        }
    }
    
}

func uploadVideo(localURL:String, firebaseURL:String, uploadCompletion: @escaping (completionHander_outcome, Any?) -> Void, showDetails: Bool = false){
    print("attempting video upload")
    Storage.storage().reference().child(firebaseURL).putFile(from: URL(string: localURL)!, metadata: nil, completion: { (metadata, error) in
//        Storage.storage().reference().child("recipe/D4346263-0582-43AF-83E0-2FB6B676C723/vid0").putFile(from: URL(string: (media[selectionIndex].media as! Identifiable_Video).videoLocation)!, metadata: nil, completion: { (metadata, error) in
        if error == nil {
            
            print("Successful video upload")
            uploadCompletion(completionHander_outcome.success, nil)
        } else {
            print(error?.localizedDescription)
            uploadCompletion(completionHander_outcome.failed, nil)
        }
    })
}



func deleteRecipe(recipe: trunc_RecipePost, postingUser:trunc_user, completion: @escaping (Any) -> Void){
    print("deleting: \(recipe.id.uuidString)")
    print("modifying: \(postingUser.id.uuidString)")
    var tasksToComplete = 2
    firestoreDelete_document(docRef_string: "recipe/\(recipe.id.uuidString)", completion: {_ in
        tasksToComplete -= 1
        if tasksToComplete == 0 {
            completion(true)
        }
    })
    
    firestoreDelete_document(docRef_string: "users/\(postingUser.id.uuidString)/publishedRecipes/\(recipe.id.uuidString)", completion: {_ in
        tasksToComplete -= 1
        if tasksToComplete == 0 {
            completion(true)
        }
    })
    
    
}

func updateRecipe(update_recipe: RecipePost, update_publishingUser:user, completion: @escaping (Any) -> Void){
    var tasksToComplete = 2
    
    firestoreUpdate_data(docRef_string: "users/\(update_publishingUser.id.uuidString)/publishedRecipes/\(update_recipe.id.uuidString)", dataToUpdate: update_recipe.fireBaseFormat, completion: {_,_  in
        tasksToComplete -= 1
        if tasksToComplete == 0 {
            completion(true)
        }
    })
    
    firestoreUpdate_data(docRef_string: "recipe/\(update_recipe.id.uuidString)", dataToUpdate: update_recipe.fireBaseFormat, completion: {_,_  in
        tasksToComplete -= 1
        if tasksToComplete == 0 {
            completion(true)
        }
    })
    
    
}

func fsData_toLocalStruct(fsData: QuerySnapshot, structType: SearchType, QueryWeight:Double) -> [Identifiable_Any]?{
    var returnVal:[Identifiable_Any]? = []
    for document in fsData.documents {
        if structType == SearchType.User {
            if let loaded_UUID = UUID(uuidString: document.documentID){
                println("converting \(structType.rawValue) -- \(document.documentID) to localStruct")
                returnVal?.append(
                    
                    Identifiable_Any(id: loaded_UUID, any: document.data().toUser(formerUUID: loaded_UUID),
                                     QueryWeight: QueryWeight
                    )
                )
                println("this user likes \(String(describing: document.data()["likes"]))", 2)
            }
        } else if structType == SearchType.Recipe {
            if let loaded_UUID = UUID(uuidString: document.documentID){
                println("converting \(structType.rawValue) -- \(document.documentID) to localStruct")
                returnVal?.append(
                    
                    Identifiable_Any(
                        id: loaded_UUID,
                        any: document.data().toRecipePost(formerUUID: loaded_UUID
                        ),
                        QueryWeight: QueryWeight
                    )
                )
                println("post liked by  \(String(describing: document.data()["likes"] as? [String]))")
            }
        } else if structType == SearchType.Comments {
            if let loaded_UUID = UUID(uuidString: document.documentID){
                println("converting \(structType.rawValue) -- \(document.documentID) to localStruct")
                returnVal?.append(
                    
                    Identifiable_Any(
                        id: loaded_UUID,
                        any: Comment(id: loaded_UUID,
                            commentingUser: document.data()["commentingUser"] as? [String:Any] ?? [:],
                            assocRecipe: document.data()["assocRecipe"] as? String ?? "assocRecipe Error",
                            message: document.data()["message"] as? String ?? "message Error",
                            dateCreate: document.data()["dateCreate"] as? String ?? "",
                            flagged: document.data()["flagged"] as? Bool ?? false
                        ),
                        QueryWeight: QueryWeight
                    )
                )
                println("post liked by  \(String(describing: document.data()["likes"] as? [String]))")
            }
        }
        
    }
    return returnVal
}

func followUser(targetUser: user, followerUser: user, follow:Bool, completion: @escaping (Any) -> Void){
    func update_quantityFollowers(){
        DistributeQueryLoads(queryRounds: [QueryRound(queryType: .order_and_Limit, refString: "users/\(targetUser.id.uuidString)/followers", field: "name", QueryWeight: 500, value: 10000, expectedReturn: .User)], completion: {results, queryTime in
        if let followers = results.map({$0.any}) as? [user] {
            print("found all followers - \(followers.count)")
            firestoreUpdate_data(docRef_string: "users/\(targetUser.id.uuidString)", dataToUpdate: ["quantity_followers":followers.count], completion: {outcome, any in print(outcome)})
            } else {print("something went wrong -- ", results.first as Any)}
        
    })
        
    }
    func update_quantityFollowing(){
        DistributeQueryLoads(queryRounds: [QueryRound(queryType: .order_and_Limit, refString: "users/\(followerUser.id.uuidString)/following", field: "name", QueryWeight: 500, value: 10000, expectedReturn: .User)], completion: {results, queryTime in
        if let following = results.map({$0.any}) as? [user] {
            print("found all following - \(following.count)")
            firestoreUpdate_data(docRef_string: "users/\(followerUser.id.uuidString)", dataToUpdate: ["quantity_following":following.count], completion: {outcome, any in print(outcome)})
            } else {print("something went wrong -- ", results.first as Any)}
        
    })
        
    }
    if follow {
        firestoreSubmit_data(docRef_string: "users/\(targetUser.id.uuidString)/followers/\(followerUser.id.uuidString)", dataToSave: followerUser.fireBaseFormat, completion: {_  in
            completion(true)
            update_quantityFollowers()
            print("running completion")})
        firestoreSubmit_data(docRef_string: "users/\(followerUser.id.uuidString)/following/\(targetUser.id.uuidString)", dataToSave: targetUser.fireBaseFormat, completion: {_  in
            update_quantityFollowing()
            print("")})
        
            notifyAboutNewFollower(targetUser: targetUser.truncForm, followerUser: followerUser.truncForm)
        
    } else {
        firestoreDelete_document(docRef_string: "users/\(targetUser.id.uuidString)/followers/\(followerUser.id.uuidString)", completion: {_  in
        
            update_quantityFollowers()
            completion(true)
        print("running completion")})
        firestoreDelete_document(docRef_string: "users/\(followerUser.id.uuidString)/following/\(targetUser.id.uuidString)", completion: {_  in
            update_quantityFollowing()
            print("")})
    }
}

func likePost(postingUser:user?, postingUser_trunc:trunc_user, recipeToLike: trunc_RecipePost, likerUser: user, completion: @escaping (user?) -> Void){
    if let postingUser = postingUser{
        likeRecipe(
            target_trunkRecipe: recipeToLike,
            target_postingUser: postingUser,
            likerUser: likerUser,
            like: !userLikesRecipe(user: likerUser, recipe: recipeToLike),
            completion: {outcome, _ in
                //            p/(outcome)
                completion(postingUser)
        })
    } else {
        let query = [QueryRound(queryType: QueryType.isEqualTo, refString: "users", field: "id", QueryWeight: 500, value: postingUser_trunc.id.uuidString, expectedReturn: SearchType.User, filters: [])]
        DistributeQueryLoads(queryRounds: query, completion: {results, queryTime in
            //            p/("finished fetching the user for this recipe.")
            let alertView = SPAlertView(title: "Hmmm...", message: "We encountered an issue liking this photo. Please try again late.", preset: SPAlertPreset.done)
            alertView.duration = 3
            if results.count < 1 {
                alertView.present()
            } else {
                if let postingUser = results[0].any as? user {

                    likeRecipe(
                        target_trunkRecipe: recipeToLike,
                        target_postingUser: postingUser,
                        likerUser: likerUser,
                        like: !userLikesRecipe(user: likerUser, recipe: recipeToLike),
                        completion: {outcome, _ in
                            //            p/(outcome)
                            completion(postingUser)
                    })
                    
                } else {
                    alertView.present()
                }
            }
        })
    }
}

func likeRecipe(target_trunkRecipe: trunc_RecipePost, target_postingUser:user, likerUser: user, like:Bool, completion: @escaping (completionHander_outcome, Any?) -> Void){
    
    ///(1) Go to the truncated form of this recipe in the hosting user's published recipes and update who the "likes" array publishedRecipes attribute
    ///(2) Go to the person who is doing the ~liking~ and update the their list of liked-recipes with the id of this recipe
    ///(3) Go to the actual document for this complete recipe and update who the "likes" array
//    var base_targetTrunkRecipe = target_trunkRecipe
//    var base_targetPostingUser = target_postingUser
//    var base_likerUser = likerUser
    
//    func sendUpdate(recipeIndex:Int){
//        print("updating user: \(base_targetPostingUser.publishedRecipes[recipeIndex].likes.formatForFirebase())")
//        firestoreUpdate_data(docRef_string: "users/\(target_postingUser.id.uuidString)", dataToUpdate: ["publishedRecipes": base_targetPostingUser.publishedRecipes.formatForFirebase()], completion: {_,_  in print("")})
//        firestoreUpdate_data(docRef_string: "users/\(likerUser.id.uuidString)", dataToUpdate: ["likes":base_likerUser.likes.formatForFirebase()], completion: {_,_  in print("")})
//        firestoreUpdate_data(docRef_string: "recipe/\(target_trunkRecipe.id.uuidString)", dataToUpdate: [
//            "likes":base_targetPostingUser.publishedRecipes[recipeIndex].likes.formatForFirebase(),
//            "quantity_likes":base_targetPostingUser.publishedRecipes[recipeIndex].likes.formatForFirebase().count
//            ], completion: {
//                _,_  in
//                completion(completionHander_outcome.success, nil)
//                print("")})
//    }
    
    func update_quantityLikes(){
        DistributeQueryLoads(queryRounds: [QueryRound(queryType: .isEqualTo, refString: "recipe", field: "id", QueryWeight: 500, value: target_trunkRecipe.id.uuidString, expectedReturn: .Recipe)], completion: {results, queryTime in
            if let recipes = results.map({$0.any}) as? [RecipePost] {
                if recipes.count == 1 {
                    let thisrecipe = recipes[0]
                    print("found recipe - \(thisrecipe.title)")
                    
                    firestoreUpdate_data(docRef_string: "recipe/\(thisrecipe.id.uuidString)", dataToUpdate: ["quantity_likes":thisrecipe.likes.count], completion: {outcome, any in print("updating: recipe/{id}", outcome)})
                    firestoreUpdate_data(docRef_string: "users/\(target_postingUser.id.uuidString)/publishedRecipes/\(thisrecipe.id.uuidString)", dataToUpdate: ["quantity_likes":thisrecipe.likes.count], completion: {outcome, any in print("updating: users/{id}/recipe/{id}", outcome)})
                } else {
                    print("returned unexpected number of recipes \(recipes.count)")
                    
                }
            } else {
                print("could not unwrap results - \(results) - to RP")
            }
            
            
        })
        
    }
    
    /*(1)*/FS_ArrayModify(docRef_string: "users/\(target_postingUser.id.uuidString)/publishedRecipes/\(target_trunkRecipe.id.uuidString)", field: "likes", value: likerUser.id.uuidString, action: like ? .union : .remove, completion: {_,_  in
        print("")})
    /*(2)*/FS_ArrayModify(docRef_string: "users/\(likerUser.id.uuidString)", field: "likes", value: target_trunkRecipe.id.uuidString, action: like ? .union : .remove, completion: {_,_  in
        print("")})
    
    /*(3)*/FS_ArrayModify(docRef_string: "recipe/\(target_trunkRecipe.id.uuidString)", field: "likes", value: likerUser.id.uuidString, action: like ? .union : .remove, completion: {_,_  in
        completion(completionHander_outcome.success, nil)
        update_quantityLikes()
        print("")})
    
    if like && target_postingUser.id.uuidString != likerUser.id.uuidString {
        notifyLike(targetRecipe: target_trunkRecipe, likingUser: likerUser.truncForm)
    }
    ///(1) Go to the truncated form of this recipe in the hosting user's published recipes and update who the "likes" array publihsedRecipes attribute
    ///(2) Go to the person who is doing the ~liking~ and update the their list of liked-recipes with the id of this recipe
    ///(3) Go to the actual document for this complete recipe and update who the "likes" array
}

func checkFollowUser(userList: [trunc_user], searchObject: trunc_user) -> Bool{
    let userIDs = userList.map({$0.id.uuidString})
    if let _ = userIDs.firstIndex(of: searchObject.id.uuidString){
        return true
    } else {
        return false
    }
    
}

func is_sameUser(user_forPage:trunc_user?, comparingUser: trunc_user) -> Bool {
    if let uw_user_forPage = user_forPage {
        if uw_user_forPage.username == comparingUser.username {
            return true
        } else {
            return false
        }
    } else {
        return false
    }
}


extension Collection {
    
    func chunked(by distance: Int) -> [[Element]] {
        precondition(distance > 0, "distance must be greater than 0") // prevents infinite loop
        
        var index = startIndex
        let iterator: AnyIterator<Array<Element>> = AnyIterator({
            let newIndex = self.index(index, offsetBy: distance, limitedBy: self.endIndex) ?? self.endIndex
            defer { index = newIndex }
            let range = index ..< newIndex
            return index != self.endIndex ? Array(self[range]) : nil
        })
        
        return Array(iterator)
    }
    
}

func validateRecipe(_ recipePost:RecipePost, _ media: [Identifiable_Media]) -> String?{
    var alertmessage:String? = nil
    
    if recipePost.ingredients.count < 1 {
        alertmessage = "Please add at least one ingredient."
    } else if recipePost.steps.count < 1 {
        alertmessage = "Please add at least one step."
    } else if recipePost.title == "" {
        alertmessage = "Please add a name for this work of art!"
    } else if recipePost.subtitle == "" {
        alertmessage = "Can you tell use a little more about this masterpiece with a description?"
    } else if media.count < 1 {
        alertmessage = "Don't you want to show us this dish with at least one picture or video?"
    } else if recipePost.tags.count < 1{
        alertmessage = "Let us know what kind of dish you made! Please select at least one categorical tag."
    } else if possible_stringToDouble(recipePost.estimatedServings) == nil {
        alertmessage = "Please make sure your estimated number of servings has only numbers."
    } else if possible_stringToDouble(recipePost.estimatedServings) == -1 {
        alertmessage = "Please make sure to put an estimated number of servings that is greater than 0 and contains only numbers (1234567890)"
    } else if recipePost.title.count > 1000 || recipePost.subtitle.count > 1000 || recipePost.estimatedServings.count > 1000 {
           alertmessage = "Please make sure none of your textfields contain more than 1000 characters (like the title, subtitle, and estimated number of servings)"
    }
    return alertmessage
}

func possible_stringToDouble(_ stringToValidate:String) -> Double?{
    let val:Double? = Double(stringToValidate) ?? nil
    
    if let val = val {
        return val
    } else {
        if stringToValidate == "" {
            return -1
        } else {
            return nil
        }
        
    }
    
}

func DateDifference_Displayable(itemDate:Date?, comparedAgainst:Date = Date()) -> String?{
    if let itemDate = itemDate {
        
        
        let componentDifference = Calendar.current.dateComponents([
            Calendar.Component.year,
            Calendar.Component.month,
            Calendar.Component.day,
            Calendar.Component.hour,
            Calendar.Component.minute,
            Calendar.Component.second,
        ], from: itemDate, to: comparedAgainst)
        let dateFormatter = DateFormatter()
        
        
        if componentDifference.year! > 0 {
            dateFormatter.dateFormat = "MMMM d yyyy"
            return dateFormatter.string(from: itemDate)
        } else if componentDifference.day! > 0 {
            dateFormatter.dateFormat = "MMMM d"
            return dateFormatter.string(from: itemDate)
        } else if componentDifference.hour! > 0 {
            return "\(componentDifference.hour!) hour\(componentDifference.hour! > 1 ? "s" : "") ago"
        } else if componentDifference.minute! > 0 {
            return "\(componentDifference.minute!) minute\(componentDifference.minute! > 1 ? "s" : "") ago"
        } else if componentDifference.second! > 0 {
            return "\(componentDifference.second!) second\(componentDifference.second! > 1 ? "s" : "") ago"
        } else {
            return nil
        }
    }
    
    return nil
    
}



func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}

func isSquare(in_uii:UIImage) -> Bool{
    
    
    if let in_cgi = in_uii.cgImage {
        
        let originalWidth:CGFloat = CGFloat(in_cgi.width)
        let originalHeight:CGFloat = CGFloat(in_cgi.height)
        if originalWidth/originalHeight > 1 {
            return true
        } else {
            return false
        }
        
        
    } else {
        return false
        
    }
}

func centerImage(in_uii:UIImage) -> UIImage?{
    enum LongEdge {
        case Vertical, Horizontal
    }
    
    if let in_cgi = in_uii.cgImage {
        
        var longEdge = LongEdge.Vertical
        let originalWidth:CGFloat = CGFloat(in_cgi.width)
        let originalHeight:CGFloat = CGFloat(in_cgi.height)
        
        if originalWidth >= originalHeight {
            
            longEdge = .Horizontal
        } else {
            longEdge = .Vertical
        }
        
        let squareLeg = (longEdge == .Vertical ? originalWidth : originalHeight)
        
        let width:CGFloat = squareLeg
        let height:CGFloat = squareLeg
        let x:CGFloat = ((originalWidth - squareLeg)/2)
        let y:CGFloat = ((originalHeight - squareLeg)/2)
        if let croppedImage = in_cgi.cropping(to: CGRect(x: x, y: y, width: width, height: height)){
            return UIImage(cgImage: croppedImage)
        } else {
            return nil
        }
    } else {
        return nil
        
    }
}

public var debugLvl = 0

func println(_ msg:Any, _ lvl:Int = 1){
    if lvl <= debugLvl {
        print(msg)
    }
}

func createComment(msg: String, recipe: String, commenter:trunc_user, completion: @escaping (completionHander_outcome) -> Void){
    let comment = Comment(commentingUser: commenter, assocRecipe: recipe, message: msg, flagged: false)
    let path = "recipe/\(comment.assocRecipe)/comments/\(comment.id.uuidString)"
    firestoreSubmit_data(docRef_string: path, dataToSave: comment.dictionary, completion: {outcome in
        if outcome == .success {
            println("upload succeeded", 0)
            completion(.success)
        } else if outcome == .failed{
            println("upload failed", 0)
            completion(.failed)
        }
        
        
    })
}

func deleteComment(commentID:String, recipeID: String, completion: @escaping (completionHander_outcome) -> Void){
    let path = "recipe/\(recipeID)/comments/\(commentID)"
    println("delete path: \(path)", 0)
    firestoreDelete_document(docRef_string: path, completion: {outcome in
        if outcome == .success {
            println("delete succeeded", 0)
            completion(.success)
        } else if outcome == .failed{
            println("delete failed", 0)
            completion(.failed)
        }
    })
}

func loadComments(recipePost:String, completion: @escaping (completionHander_outcome, [Identifiable_Any]?, Date) -> Void){
    println("Fetching all comments")
    let path = "recipe/\(recipePost)/comments"
    let commentsQuery = QueryRound(queryType: .order_and_Limit, refString: path, field: "dateCreate", QueryWeight: 500, value: 30, expectedReturn: SearchType.Comments)
    DistributeQueryLoads(queryRounds: [commentsQuery], completion: {results, queryTime in
        println("finished grabbing comments")
        let sortedResults = results.sorted{ ($0.any as? Comment)?.dateCreate ?? "" < ($1.any as? Comment)?.dateCreate ?? "" }
        println("Total comments: \(results.count)", 0)
        
        
        completion(.success, sortedResults, queryTime)
        
        
    })
    
}

func reloadRecipe(recipeString:String, completion: @escaping (RecipePost) -> Void){
    let query = [QueryRound(queryType: QueryType.isEqualTo, refString: "recipe", field: "id", QueryWeight: 500, value: recipeString, expectedReturn: SearchType.Recipe, filters: [])]
    DistributeQueryLoads(queryRounds: query, completion: {results, queryTime in
        //            p/("finished fetching the user for this recipe.")
        let alertView = SPAlertView(title: "Hmmm...", message: "We encountered an reloading this post.", preset: SPAlertPreset.done)
        alertView.duration = 3
        if results.count < 1 {
            alertView.present()
        } else {
            if let thisRP = results[0].any as? RecipePost {
                print("thisRP - \(thisRP)")
                completion(thisRP)
                
            } else {
                alertView.present()
            }
        }
    })
}

func randomString(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}

func userIsBlocked(listOfBlockedUser:[UUID], checkingFor:UUID) -> Bool{
    print("checking if user is in blockList \(listOfBlockedUser.map{$0.uuidString})")
    if listOfBlockedUser.first(where: {$0.uuidString == checkingFor.uuidString}) != nil{
        print("user (\(checkingFor.uuidString)) is present in the list of UUID's that have been blocked")
        return true
    } else {
        print("user (\(checkingFor.uuidString)) is NOT present in the list of UUID's that have been blocked")
        return false
    }
}

func set_hiddenContent(directingUser:user, contentID:UUID, type:RecipeatEntity, overrideAction: FSArrayAction? = nil){
    var act = FSArrayAction.union
    let comparableString = "\(type.minimized()).\(contentID.uuidString)"
    print("checking for \(comparableString)")
    if directingUser.hiddenContent.first(where: {$0 == comparableString}) == nil {
        act = .union
    } else {
        act = .remove
    }
    
    if let overrideAction = overrideAction {
        act = overrideAction
    }
    FS_ArrayModify(docRef_string: "users/\(directingUser.id.uuidString)", field: "hiddenContent", value: comparableString, action: act, completion: {_,_  in
        print("")})
}
