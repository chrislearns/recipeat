//
//  SceneDelegate.swift
//  recipeat
//
//  Created by Christopher Guirguis on 3/2/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    
    var window: UIWindow?
    @ObservedObject var env = GlobalEnvironment()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let appearance = UITabBarAppearance()
        

        appearance.configureWithTransparentBackground()

        UITabBar.appearance().standardAppearance = appearance
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        handleDeepLinkUrl(connectionOptions.urlContexts.first?.url, completion: {dest, context in
            self.executeNavigation(dest: dest, context: context)
        })
        print("29348 72634")
        print(env.currentUser)
        print(env.currentUser.username)
        print(env.currentUser.following)
        
        // Get the managed object context from the shared persistent container.
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
        // Add `@Environment(\.managedObjectContext)` in the views that will need the context.
        self.env.isLoggedIn = false
        var vc_forLogin = UIHostingController(rootView:
            TabbedRootView(NavigationUnit: $env.DeeplinkNavUnit).environmentObject(env).environment(\.managedObjectContext, context)
        )
        
        print("attempting to fetch last login objects")
        if let lastLogin_objects = UserDefaults.standard.object(forKey: UserDefaultKeys.LastLoggedInObject.rawValue) as? Data{
            do {
                print("last login objects gathered")
                if let lastSession = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(lastLogin_objects) as? [String:Any?] {
                    print("last session gathered")
                    
                    if let rememberedUser = lastSession["lastLogin_user"] as? user{
                        print("logged in successful with remembered user")
                        println(rememberedUser)
                        print(rememberedUser.username)
                        print(rememberedUser.following)
                        self.env.currentUser = rememberedUser
                        self.env.initializeListener_currentUser()
                        self.env.isLoggedIn = true
                        vc_forLogin = UIHostingController(rootView:
                            TabbedRootView(NavigationUnit: $env.DeeplinkNavUnit).environmentObject(self.env)
                                .environment(\   .managedObjectContext, context)
                        )
                        
                    } else {
                        print("couldn't unwrap user")
                        println(lastSession)
                        println(lastSession["lastLogin_user"] as Any)
                    }
                    
                    
                    
                    println("logged in successfully")
                }
            } catch {
                println("couldn't unwrap data/last session")
            }
        } else {
            println("couldn't unwrap data/lastLogin_objects")
        }
        
        print("gathering all unfinished recipes")
        self.env.load_unfinishedRecipes(completion: {loadedRecipes in
            if let loadedRecipes = loadedRecipes{
                print(loadedRecipes)
                self.env.unfinishedRecipes = loadedRecipes
            } else {
                print("loaded recipes were nil")
                self.env.unfinishedRecipes = [:]
            }
            
        })
        
        
        
        

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = vc_forLogin
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

//    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
//        print(userActivity.referrerURL)
//        print(userActivity.activityType)
//
//        print("asdgads")
//    }
//
//    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        print(URLContexts)
//        print("dsfbjkg")
//    }
//
//    func scene(_ scene: UIScene, willContinueUserActivityWithType userActivityType: String) {
//
//        print(userActivity?.referrerURL)
//        print("sgfdhetr")
//    }
//
//

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    //first launch after install
    handleDeepLinkUrl(URLContexts.first?.url, completion: {dest, context in
        self.executeNavigation(dest: dest, context: context)
    })
    print("4w98e 87fw4")
    print(env.currentUser)
    }
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    //when in background mode
        handleDeepLinkUrl(userActivity.webpageURL, completion: {dest, context in
            self.executeNavigation(dest: dest, context: context)
        })
        print("avd9r 398wi")
        print(env.currentUser)
    }
}

