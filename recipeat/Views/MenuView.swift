//
//  MenuView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 10/5/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    
    @EnvironmentObject var env: GlobalEnvironment
    
    @Binding var menuExpanded:Bool
    @State var sheetDestination:Int = 0
    @State var showSheet = false
    
    var body: some View {
        VStack{
        Button(action: {
            self.sheetDestination = NavigationDestination.EditProfileView.rawValue
            self.showSheet = true
        }){
            MediumButtonView(image: "pencil.circle", title: "Edit profile", subtitle: "Username, Password, Bio...", buttonColoring: ButtonColoring(
                titleColor: Color.init(red: 0, green: 0, blue: 0, opacity: 0.9),
                subtitleColor: Color.init(red: 0, green: 0, blue: 0, opacity: 0.6),
                backgroundColor: Color.white,
                iconColor: Color.init(red: 0, green: 0, blue: 0, opacity: 0.5)
            )
            )
        }
        
        Button(action: {
            self.sheetDestination = NavigationDestination.ClaimRewardsView.rawValue
            self.showSheet = true
        }){
            MediumButtonView(image: "app.gift", title: "More options", subtitle: "Referral codes & more", buttonColoring: ButtonColoring(
                titleColor: Color.init(red: 0, green: 0, blue: 0, opacity: 0.9),
                subtitleColor: Color.init(red: 0, green: 0, blue: 0, opacity: 0.6),
                backgroundColor: Color.white,
                iconColor: Color.init(red: 0, green: 0, blue: 0, opacity: 0.5)
            )
            )
        }
        
        Button(action: {
            menuExpanded = false
            self.env.signOut()
        }){
            MediumButtonView(image: "square.lefthalf.fill", title: "Sign out", subtitle: nil, buttonColoring:
                                ButtonColoring(
                                    titleColor: Color.init(red: 1, green: 0, blue: 0, opacity: 0.7),
                                    subtitleColor: Color.init(red: 1, green: 0, blue: 0, opacity: 0.2),
                                    backgroundColor: Color.init(red: 1, green: 0.8, blue: 0.8, opacity: 1),
                                    iconColor: Color.init(red: 1, green: 0, blue: 0, opacity: 0.5),
                                    shadowColor: Color.init(red: 1, green: 0.7, blue: 0.7, opacity: 0.5)
                                )
            )
        }
            .sheet(isPresented: $showSheet){
                if self.sheetDestination == NavigationDestination.EditProfileView.rawValue {
                UserEditProfileView(showLoader: {boolVar in
                    withAnimation{
                        self.env.loaderShown = boolVar

                    }

                }, user_forPage: self.env.currentUser, isShown: self.$showSheet) }
                else if self.sheetDestination == NavigationDestination.ClaimRewardsView.rawValue {
                    ClaimRewardsView(showLoader: {boolVar in
                        withAnimation{
                            self.env.loaderShown = boolVar
                        }

                    }, user_forPage: self.env.currentUser, isShown: self.$showSheet)
                }
        }
        }.padding(.horizontal)
        
    }
    
}

//struct MenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        MenuView()
//    }
//}
