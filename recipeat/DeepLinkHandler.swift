//
//  DeepLinkHandler.swift
//  recipeat
//
//  Created by Christopher Guirguis on 6/10/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import Foundation
//final class DeepLinkData: ObservableObject {
// @Published var somevar:String //some deeplink data here
//    ini
//}

extension URL {
 func valueOf(_ queryParamaterName: String) -> String? {
 guard let url = URLComponents(string: self.absoluteString) else { return nil }
 return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value?.removingPercentEncoding?.removingPercentEncoding
 }
}

func handleDeepLinkUrl(_ url: URL?, completion: @escaping (String, String) -> Void){
    print(url?.description)
    guard let url = url else {return}
    if let dest = url["dest"], let context = url["context"]{
        completion(dest, context)
 }
}

extension SceneDelegate {
    func executeNavigation(dest:String, context:String){
        if dest == "recipe" {
            if let recipeUUID = UUID(uuidString: context) {
                print("navigating to (\(dest)) -- (\(recipeUUID.uuidString))")
                env.TabSelection = TabOptions.Home.rawValue
                env.DeeplinkNavUnit.navigationContext = recipeUUID.uuidString
                if env.DeeplinkNavUnit.navigationSelector == NavigationDestination.RecipePostView.hashValue {
                    env.DeeplinkNavUnit.navigationSelector = nil
                }
                env.DeeplinkNavUnit.navigationSelector = NavigationDestination.RecipePostView.hashValue
                print("nav selector: \(env.DeeplinkNavUnit.navigationSelector)")
            } else {
                print("failed to navigate to (\(dest)) -- (\(context))")
            }
        }
    }
}


/*
 This was it: https://medium.com/@fenceguest/deeplink-handler-in-swift-5-ios-13-eec88c2c5fe7
 --> Article by: NinjaMeowJi 
 */
