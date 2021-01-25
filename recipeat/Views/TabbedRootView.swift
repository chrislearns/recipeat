    //
    //  ContentView.swift
    //  recipeat
    //
    //  Created by Christopher Guirguis on 3/2/20.
    //  Copyright © 2020 Christopher Guirguis. All rights reserved.
    //

    import SwiftUI

    struct TabbedRootView: View {
        
           
        
        
        @EnvironmentObject var env: GlobalEnvironment
        @State private var onboardingPresented = true
        @State var buttons:[MenuButton] = []
        
        @State var showSheet = false
        
        @Binding var NavigationUnit:HashableNavigationUnit
        
        @State var bar_view_Height:CGFloat = 0
        @State var view_Height:CGFloat = 0
        
        
        
        var developing = true
        var body: some View {
            ZStack{
                NavigationView{
                
                ZStack{
                    NavigationLink(destination: RecipePostView(isShown_selection: self.$NavigationUnit.navigationSelector, RP_String: NavigationUnit.navigationContext as? String ?? ""), tag: NavigationDestination.RecipePostView.hashValue, selection: self.$NavigationUnit.navigationSelector){
                        EmptyView()
                    }
                    Color.init(white: 247/255).edgesIgnoringSafeArea(.top)
                    
                    if !self.env.isLoggedIn{
                        LoginView()
                    } else {

                        
                        VStack{
                                TabView(selection: self.$env.TabSelection){
                                    
                                    HomeView(newsFeedRecipes: self.$env.NewsFeedResults.results)
                                            .navigationBarTitle("")
                                            .navigationBarHidden(true)
                                    .background(Color.white)
                                    .tag(TabOptions.Home.rawValue)
                                    SearchView()
                                        .background(Color.white)
                                        .tag(TabOptions.Search.rawValue)
                                    if developing {
//                                        NewPost_ImageSelectionView()
                                        EmptyView()
//                                            .tag(TabOptions.New.rawValue)
                                    } else {

                                        EmptyView()
                                            .background(Color.white)
                                         
                                    }
                                    
    //                                NavigationView{
                                    UserView(user_forPage: self.env.currentUser, user_forPage_string: self.env.currentUser.id.uuidString)
                                            
                                        .navigationBarTitle("")
                                                .navigationBarHidden(true)
    //                                }
                                    .background(Color.white)
                                    .tag(TabOptions.User.rawValue)
                                }.tabViewStyle(
                                    PageTabViewStyle(indexDisplayMode: .never)
                                )
                                            
                                
    //                            .overlay(GeometryReader{geo -> AnyView in
    //                                bar_view_Height = geo.size.height
    //                                return AnyView(EmptyView())
    //                            } )
    //                        Spacer().frame(height: 40)
                        }
                                            .banner(data: self.$env.bDataTabbedRoot, show: self.$env.bToggleTabbedRoot)
                                
                                
                        
                    }
                    if self.env.loaderShown{
                        CustomActivityIndicator()
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2))).zIndex(1)
                            .animation(
                                Animation.easeInOut(duration: 0.2)
                        )
                    }
                
                
                }
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarHidden(true)
                
            }
                
                .fullScreenCover(isPresented: self.$env.currentUser.firstTimeUser){
                FullScreenModalView(user_forPage: self.$env.currentUser)
            }

                CustomTabBar(selection: self.$env.TabSelection, bar_view_Height: $bar_view_Height, view_Height:$view_Height)
        
        .background(Color.clear)

            }//, content: )
        }
        
        
    }

    //struct TabbedRootView_Previews: PreviewProvider {
    //    static var previews: some View {
    //        TabbedRootView(isLoggedIn: false)
    //            .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
    //    }
    //}

    enum TabOptions:Int {
        case Home = 0, Search, New, User
    }
