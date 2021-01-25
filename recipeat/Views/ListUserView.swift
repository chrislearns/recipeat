//
//  ListUserView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/6/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct ListUserView: View {
    var userList:[trunc_user]
    @State var NavigationUnit = HashableNavigationUnit()
    var body: some View {
        ZStack{
            NavigationLink(
                destination: UserView(
                    //This tries to unwrap the navigation context as a user()
                    user_forPage: NavigationUnit.navigationContext as? user ?? nil,
                    //This tries to do the same as above, but if it fails, it tries to unwrap it as a string, and if THAT fails then it just gives a default string value of "". This should go on to the UserView which will then fail to retrieve a user's page and return that error with some sort of alert
                    user_forPage_string: (NavigationUnit.navigationContext as? user)?.id.uuidString ?? (NavigationUnit.navigationContext as? String ?? "")
                ),
                tag: NavigationDestination.UserHomeView.hashValue,
                selection: self.$NavigationUnit.navigationSelector){
                    EmptyView()
            }
        List{
            ForEach(userList, id: \.id){thisUser in
                Button(action: {
                    self.NavigationUnit.navigationContext = thisUser.id.uuidString
                    self.NavigationUnit.navigationSelector = NavigationDestination.UserHomeView.hashValue
                    print("navigating to profile")
                }){
                    SearchResult_User(U: thisUser, resultImage: nil)
                }
            }
        }
    }
    }
}
//
//struct ListUserView_Previews: PreviewProvider {
//    static var previews: some View {
//        ListUserView()
//    }
//}
