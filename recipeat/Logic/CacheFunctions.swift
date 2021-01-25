//
//  CacheFunctions.swift
//  recipeat
//
//  Created by Christopher Guirguis on 4/29/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import Foundation
import Firebase
import CoreData

func saveImage_draft(associatedRecipeUUID: String, IDAble_image:Identifiable_UIImage, order_index:Int16){
    
    print("setting up appdelegate")
    
    //1. Boilerplate
    guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return
    }
    
    let managedContext =
        appDelegate.persistentContainer.viewContext
    
    
//    2. Check for previous value
    print("checking if image was previously present for this draft and index")
    let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "DraftImage")
    fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
        NSPredicate(format: "associatedRecipeUUID = %@", associatedRecipeUUID),
        NSPredicate(format: "index_orderImage = \(order_index)")
    ])

    func createEntry(){
        let entity =
        NSEntityDescription.entity(forEntityName: "DraftImage",
                                   in: managedContext)!
        if let new_cacheImage = NSManagedObject(entity: entity,
                                                insertInto: managedContext) as? DraftImage {
        
            new_cacheImage.croppedImage = IDAble_image.image.croppedImage?.pngData()
            new_cacheImage.filteredImage = IDAble_image.image.filtered?.pngData()
            new_cacheImage.rawImage = IDAble_image.image.raw.pngData()
            new_cacheImage.associatedRecipeUUID = associatedRecipeUUID
            new_cacheImage.index_orderImage = order_index
        
        do {
            try managedContext.save()
            print("saved successfully --- images #\(order_index)")
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            print("save error for ---")
        }
        
        } else {
            println("could not save - error typecasting nsmanagedobject as draftimage")
        }
    }
    do {
        let fetchReturn = try managedContext.fetch(fetchRequest)

        print("found existing images for this recipe")
        print("FYI - found \(fetchReturn.count) entries that satisfy the predicate")
        if fetchReturn.count > 0 {
            print("There was \(fetchReturn.count) object(s) that matched the query. Commencing deletion.")
            if let fetchReturn = fetchReturn as? [NSManagedObject]{
                delete_NSManagedObjects(objects: fetchReturn, objectType: "DraftImage", completion: {createEntry()})
            } else {
                print("could not unwrap fetchReturn to [NSManagedObejct] - \(fetchReturn)")
            }
        } else {
            print("no image already present for this entry. Will create first entry")
            createEntry()
        }
    } catch let error as NSError {
        print("Could not fetch - err - \(error), \(error.userInfo)")

        createEntry()
    }
    
}

func loadImage_draft(associatedRecipeUUID: String) -> [DraftImage]? {
    guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return nil
    }
    
    let managedContext =
        appDelegate.persistentContainer.viewContext
    
    let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "DraftImage")
    fetchRequest.predicate = NSPredicate(format: "associatedRecipeUUID = %@", associatedRecipeUUID)
 
    do {
        let fetchReturn = try managedContext.fetch(fetchRequest)

        print("found existing images for this recipe")
        print("FYI - found \(fetchReturn.count) entries that satisfy the predicate")
        if fetchReturn.count > 0 {
            print("There was \(fetchReturn.count) object(s) that matched the query. Will map them to identifiable_uiimages for use in the draft.")
            if let fetchReturn = fetchReturn as? [DraftImage]{
                print("loaded results as [DraftImage]")
                return fetchReturn
            } else {
                print("could not unwrap fetchReturn to [DraftImage] - \(fetchReturn)")
                return nil
            }
        } else {
            print("no image already present for this entry. Will create first entry")
            return nil
        }
    } catch let error as NSError {
        print("Could not fetch - err - \(error), \(error.userInfo)")

        return nil
    }
    //****************** CONTINUE HERE! Need to prepare for receiving a set of NSManagedObjects that can be read and mapped to Identifiable_Images with the proper cropped, filtered, and raw data
    
    
////    do {
////        let fetchReturn = try managedContext.fetch(fetchRequest)
////        if fetchReturn.count > 0 {
////        if let objectFetched = fetchReturn[0] as? CacheImage {
////
////                println("fetched object")
////                println("Recovered Cached Image from \(String(describing: objectFetched.dateCached))")
////                return (objectFetched.imageData, objectFetched.dateCached)
////
////        } else {
////            println("could not unwrap - \(fetchReturn[0])")
////            return (nil, nil)
////        }
////        } else {
////            println("no object fetched - \(fetchReturn)")
////            return (nil, nil)
////        }
////
////    } catch let error as NSError {
////        println("Could not fetch. \(error), \(error.userInfo)")
////        return (nil, nil)
////    }
    
    
}

//Delete
func delete_NSManagedObjects(objects:[NSManagedObject], objectType:String, completion: () -> Void){
    
    guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return
    }
    
    var objectsToDelete = objects.count
    let managedContext =
        appDelegate.persistentContainer.viewContext
    
//    let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Potato")
//    fetchRequest.predicate = NSPredicate(format: "stringAttribute = %@", thisPotatoString)

    for object in objects {
        let objectDelete = object
        managedContext.delete(objectDelete)
        do {
            try managedContext.save()
            print("deleted successfully")
            objectsToDelete = objectsToDelete - 1
            
            if objectsToDelete == 0 {
                completion()
            }
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
        
    
}











//HERE - the first place we actually need to make major changes in the cache style
func saveImage_cache(imageName: String, imageData:Data){
    
    //1. Boilerplate
    guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return
    }
    
    let managedContext =
        appDelegate.persistentContainer.viewContext
    
    
//    2. Check for previous value
    let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "CacheImage")
    fetchRequest.predicate = NSPredicate(format: "imagePath = %@", imageName)

    func createEntry(){
        let entity =
        NSEntityDescription.entity(forEntityName: "CacheImage",
                                   in: managedContext)!
        if let new_cacheImage = NSManagedObject(entity: entity,
                                                insertInto: managedContext) as? CacheImage {
        
        new_cacheImage.imagePath = imageName
        new_cacheImage.dateCached = Date()
        new_cacheImage.imageData = imageData
        
        
        
        do {
            try managedContext.save()
            print("saved successfully -- \(imageName)")
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            print("save error for -- \(imageName)")
        }
        
        } else {
            print("could not save - error typecasting nsmanagedobject as CacheImage")
        }
    }
    do {
        let fetchReturn = try managedContext.fetch(fetchRequest)
        
        println("found an existing entry - updating imageData and dateCached")
        println("FYI - found \(fetchReturn.count) entries that satisfy the predicate")
        println("FYI - found \(fetchReturn) entries that satisfy the predicate")
        if fetchReturn.count > 0 {
            if let objectUpdate = fetchReturn[0] as? NSManagedObject{
                objectUpdate.setValue(imageData, forKey: "imageData")
                objectUpdate.setValue(Date(), forKey: "dateCached")
                
                do {
                    try managedContext.save()
                    println("updated successfully")
                } catch let error as NSError {
                    println("Could not save. \(error), \(error.userInfo)")
                }
            } else {
                println("could not unwrap fetchReturn to NSManagedObejc - \(fetchReturn)")
            }
        } else {
            println("no image already present for this entry. Will create first entry")
            createEntry()
        }
    } catch let error as NSError {
        println("Could not fetch - err - \(error), \(error.userInfo)")
        
        createEntry()
    }
    
}

//HERE - second place we actually need to make core changes in the cache style
func loadImage_cache(fileName: String) -> (Data?, Date?) {
    guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return (nil, nil)
    }
    
    let managedContext =
        appDelegate.persistentContainer.viewContext
    
    let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "CacheImage")
    fetchRequest.predicate = NSPredicate(format: "imagePath = %@", fileName)
    
    do {
        let fetchReturn = try managedContext.fetch(fetchRequest)
        if fetchReturn.count > 0 {
        if let objectFetched = fetchReturn[0] as? CacheImage {
            
                println("fetched object")
                println("Recovered Cached Image from \(String(describing: objectFetched.dateCached))")
                return (objectFetched.imageData, objectFetched.dateCached)
            
        } else {
            println("could not unwrap - \(fetchReturn[0])")
            return (nil, nil)
        }
        } else {
            println("no object fetched - \(fetchReturn)")
            return (nil, nil)
        }
        
    } catch let error as NSError {
        println("Could not fetch. \(error), \(error.userInfo)")
        return (nil, nil)
    }
    
    
}

func loadImage_cache_FireStore(imageString: String, needsReprocessing:Bool = false, resized: ThumbnailSizes? = nil, minimumRecency:CacheDuration = CacheDuration.Now, completion: @escaping (Data?) -> Void){
    //Important note about designating whether or not we want to check cache first. By setting the minimum recency to ".Now" we are automatically telling it that we need the most recent item because it is impossible for any cached item to match this recencys
    
    var modifiedImageString = imageString
    
    if let resized = resized {
        println("resize requested - \(resized.rawValue)")
        modifiedImageString = modifiedImageString + "/\(resized.rawValue)"
        println("attempting to grab - \(modifiedImageString)")
    }
    
    
    println("resized - if needed = \(String(describing: resized))")
    func executeFirestore(){
        
        Storage.storage().reference().child(modifiedImageString).getData(maxSize: 15 * 1024 * 1024){
            (imageData, err) in
            if let err = err {
                println("an error has occurred - \(err.localizedDescription)")
                
                if resized != nil {
                    //If we failed while attempting to grab the resize then try without the resize
                    println("failed to grab the resized image - reattempting with the non-resized image")
                    loadImage_cache_FireStore(imageString: imageString, needsReprocessing: true, resized: nil, minimumRecency: minimumRecency, completion: completion)
                } else {
                    //Otherwise this was a true failure and you can carry on
                    completion(nil)
                }
            } else {
                if let imageData = imageData {
                    if let resized = resized {
                        println("grabbed resized image of \(resized)")
                    }
                    println("image downloaded")
                    
                    if needsReprocessing{
                        println("needs reprocessing")
                        reprocess(image: UIImage(data: imageData), refString: imageString)
                    }
                    completion(imageData)
                    
                    
                    println("saving \(modifiedImageString)")
                    _ = saveImage_cache(imageName: modifiedImageString, imageData: imageData)
                    
                } else {
                    println("couldn't unwrap image data image")
                    completion(nil)
                }
                
            }
            //            }
        }
        
    }
    
    let thisCacheCheck = loadImage_cache(fileName: modifiedImageString)
    if let thisImage = thisCacheCheck.0 {
        println("Found image in file manager")
        println("\(modifiedImageString)")
        if let cacheDate = thisCacheCheck.1 {
            let expiryDate = Date(timeInterval: minimumRecency.rawValue, since: cacheDate)
            println("Date unwrapped successfully - will check time since cache")
            println("Cache Date = \(cacheDate) ")
            println("Cache Will expire on = \(expiryDate) ")
            println("Current Date = \(Date()) ")
            if Date() <= expiryDate {
                println("Cached item valid and satisfies recency - loading cached item")
                if needsReprocessing{
                    println("needs reprocessing")
                    reprocess(image: UIImage(data: thisImage), refString: imageString)
                }
                completion(thisImage)
                
            } else {
                println("Cached item has expired - reloading resource")
                executeFirestore()
            }
            
        } else {
            println("could not unwrap the date of the returned image from the cache - will assume the un-dated cached item is invalid and will reload the resource")
            executeFirestore()
        }
    } else {
        println("image not found in file manager - ")
        println("\(modifiedImageString)")
        executeFirestore()
    }
    
    
    
}

func reprocess(image:UIImage?, refString:String){
    
    if let image = image {
        if isSquare(in_uii: image){
            uploadImage(refString, image: image, completion: {outcome, secondObject  in
                if outcome == .failed {
                    println("failed to reprocess image -- \(refString)")
                } else {
                    println("image reprocessed -- \(refString)")
                }
            })
        } else {
            if let centeredImage = centerImage(in_uii: image) {
                uploadImage(refString, image: centeredImage, completion: {outcome, secondObject  in
                    if outcome == .failed {
                        println("failed to reprocess image -- \(refString)")
                    } else {
                        println("image reprocessed -- \(refString)")
                    }
                })
            } else {
                println("failed to center image")
            }
        }
    } else {
        println("couldn't unwrap image ")
    }
    
}
