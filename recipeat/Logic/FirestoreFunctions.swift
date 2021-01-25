//
//  FirestoreFunctions.swift
//  recipeat
//
//  Created by Christopher Guirguis on 4/23/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import FirebaseStorage
import FirebaseFunctions
import FirebaseFirestore
import FirebaseMessaging
import Firebase
import SPAlert



func FS_Query(queryType: QueryType, queryFilters:[QueryFilter] = [], refString:String, queryField:String, seekValue: Any, showDetails: Bool = false, priority:Int = 0,completion: @escaping (completionHander_outcome, Date, Any?) -> Void){
    print("searching for \(seekValue) ... \(queryType) '\(queryField)' of \(refString)")
    let docRef = Firestore.firestore().collection(refString)

    var thisQuery:Query{
        if queryType == QueryType.ArrayContainsAny {
            return docRef.whereField(queryField, arrayContainsAny: seekValue as? [Any] ?? [])
        } else if queryType == QueryType.isEqualTo {
            return docRef.whereField(queryField, isEqualTo: seekValue)
        } else if queryType == QueryType.In {
            return docRef.whereField(queryField, in: seekValue as? [Any] ?? [])
        } else if queryType == .isGreaterThan {
            return docRef.whereField(queryField, isGreaterThan: seekValue)
        } else if queryType == .isLessThan {
            return docRef.whereField(queryField, isLessThan: seekValue)
        } else if queryType == .isGreaterThanOrEqualTo {
            return docRef.whereField(queryField, isGreaterThanOrEqualTo: seekValue)
        } else if queryType == .isLessThanOrEqualTo {
            return docRef.whereField(queryField, isLessThanOrEqualTo: seekValue)
        } else if queryType == .order_and_Limit {
            return docRef.order(by: queryField, descending: true).limit(to: seekValue as? Int ?? 100)
        } else {
            return docRef.whereField(queryField, isEqualTo: seekValue)
        }
    }
    
    var modifiableQuery = thisQuery
    for eachFilter in queryFilters {
        modifiableQuery = thisQuery.addFilter(queryFilter: eachFilter)
        print("query modified - \(modifiableQuery)")
    }
    modifiableQuery.getDocs(queryTime: Date(), completion: completion)
    
}

extension Query {
    func addFilter(queryFilter:QueryFilter) -> Query {
        if queryFilter.queryFilterType == .isEqualTo {
            return (self.whereField(queryFilter.field, isEqualTo: queryFilter.filterArgument))
        } else if queryFilter.queryFilterType == .isGreaterThan {
            return (self.whereField(queryFilter.field, isGreaterThan: queryFilter.filterArgument))
        } else if queryFilter.queryFilterType == .isLessThan {
            return self.whereField(queryFilter.field, isLessThan: queryFilter.filterArgument)
        } else if queryFilter.queryFilterType == .isGreaterThanOrEqualTo {
            return self.whereField(queryFilter.field, isGreaterThanOrEqualTo: queryFilter.filterArgument)
        } else if queryFilter.queryFilterType == .isLessThanOrEqualTo {
            return self.whereField(queryFilter.field, isLessThanOrEqualTo: queryFilter.filterArgument)
        } else if queryFilter.queryFilterType == .In {
            return self.whereField(queryFilter.field, in: queryFilter.filterArgument as? [Any] ?? [])
        } else {
            return self
        }
    }
    
    func getDocs(queryTime:Date, completion: @escaping (completionHander_outcome, Date, Any?) -> Void){
        self.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(completionHander_outcome.failed, queryTime, nil)
            } else {
                for document in querySnapshot!.documents {
                    println("\(document.documentID) => \(document.data())")
                }
                completion(completionHander_outcome.success,queryTime, querySnapshot)
            }
        }
    }
}





//MARK: - FirebaseFunction
///This area marks the start of things related to Firebase Function
func notifyAboutNewFollower(targetUser: trunc_user, followerUser: trunc_user){
    let message = "\(followerUser.name) started following you (@\(followerUser.username))"
    
    let functions = Functions.functions()
    functions.httpsCallable("notifyNewFollower").call(["target": "\(targetUser.id.uuidString)","message":message]) { (result, error) in
      if let error = error as NSError? {
        if error.domain == FunctionsErrorDomain {
          let code = FunctionsErrorCode(rawValue: error.code)
          let message = error.localizedDescription
          let details = error.userInfo[FunctionsErrorDetailsKey]
            print("error code - \(String(describing: code))")
            print("error message - \(message)")
            print("error details - \(String(describing: details))")
        } else {
            print(error.domain)
        }
        // ...
      }
        if let text = (result?.data as? [String: Any])?["text"] as? String {
            println(text, 0)
        } else {
            print("failed to unwrap results - \(String(describing: result?.data))")
        }
    }
}

func notifyComment(targetRecipe: trunc_RecipePost, commentingUser: trunc_user){
    print("notifying - \(targetRecipe.id.uuidString) - of new comment")
    let data = [
        "target":targetRecipe.id.uuidString,
        "title":"Comment",
        "message":"\(commentingUser.username) commented on your post - \(targetRecipe.title)",
        "context":""
    ]
    let functions = Functions.functions()
    functions.httpsCallable("notifyComment").call(data) { (result, error) in
      if let error = error as NSError? {
        if error.domain == FunctionsErrorDomain {
          let code = FunctionsErrorCode(rawValue: error.code)
          let message = error.localizedDescription
          let details = error.userInfo[FunctionsErrorDetailsKey]
            print("error code - \(String(describing: code))")
            print("error message - \(message)")
            print("error details - \(String(describing: details))")
        } else {
            print(error.domain)
        }
        // ...
      }
        if let text = (result?.data as? [String: Any])?["text"] as? String {
            println(text, 0)
        } else {
            print("failed to unwrap results - \(String(describing: result?.data))")
        }
    }
}
func notifyLike(targetRecipe: trunc_RecipePost, likingUser: trunc_user){
    print("notifying - \(targetRecipe.id.uuidString) - of new like")
    let data = [
        "target":targetRecipe.id.uuidString,
        "title":"New Like",
        "message":"\(likingUser.username) liked your post - \(targetRecipe.title)"
    ]
    let functions = Functions.functions()
    functions.httpsCallable("notifyLike").call(data) { (result, error) in
      if let error = error as NSError? {
        if error.domain == FunctionsErrorDomain {
          let code = FunctionsErrorCode(rawValue: error.code)
          let message = error.localizedDescription
          let details = error.userInfo[FunctionsErrorDetailsKey]
            print("error code - \(String(describing: code))")
            print("error message - \(message)")
            print("error details - \(String(describing: details))")
        } else {
            print(error.domain)
        }
        // ...
      }
        if let text = (result?.data as? [String: Any])?["text"] as? String {
            println(text, 0)
        } else {
            print("failed to unwrap results - \(String(describing: result?.data))")
        }
    }
}

func recoverPassword(recoveringUser:user){
    let alertView = SPAlertView(title: "Email Sent", message: "Check your emails within the next 15 minutes for the recovery of your password", preset: SPAlertPreset.done)
    alertView.duration = 3
    alertView.present()
    let functions = Functions.functions()
    functions.httpsCallable("sendEmail").call(["name": recoveringUser.name,"username":recoveringUser.username,"password":recoveringUser.password,"email":recoveringUser.email]) { (result, error) in
      if let error = error as NSError? {
        if error.domain == FunctionsErrorDomain {
          let code = FunctionsErrorCode(rawValue: error.code)
          let message = error.localizedDescription
          let details = error.userInfo[FunctionsErrorDetailsKey]
            print("error code - \(String(describing: code))")
            print("error message - \(message)")
            print("error details - \(String(describing: details))")
        } else {
            print(error.domain)
        }
        // ...
      }
        if let text = (result?.data as? [String: Any])?["text"] as? String {
            println(text)
        } else {
            print("failed to unwrap results - \(String(describing: result?.data))")
        }
    }
}

extension GlobalEnvironment {
    func subscribeToTopic(_ topic:String){
        if subscriptionCatalog.firstIndex(of: topic) == nil {
            
        print("going to subscribe to -- (\(topic))")
        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let error = error {
                print("Failed to SUBscribe to \(topic)")
                print(error)
            } else {
                print("Successfully SUBscribed to \(topic)")
                self.subscriptionCatalog.append(topic)
            }
        }
        } else {
            print("user already subscribed to this topic - \(topic)")
        }
    }
    func unsubscribeToTopic(_ topic:String){
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            if let error = error {
                print("Failed to UNSUBscribe from \(topic)")
                print(error)
            } else {
                print("Successfully UNSUBscribed from \(topic)")
                self.subscriptionCatalog.removeAll{$0 == topic}
            }
        }
    }
}



