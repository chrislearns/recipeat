    //
    //  CustomTabBar.swift
    //  recipeat
    //
    //  Created by Christopher Guirguis on 10/3/20.
    //  Copyright © 2020 Christopher Guirguis. All rights reserved.
    //

    import SwiftUI

    struct CustomTabBar: View {
        @Binding var selection:Int
        @State var expanded = false
        @State var showNewRecipe = false
        
        @EnvironmentObject var env: GlobalEnvironment
        
        //These two variables serve a very simple purpose of tracking the tabBarHeight
        @Binding var bar_view_Height:CGFloat
        @Binding var view_Height:CGFloat
        
        var body: some View {
            ZStack{
                
                VStack(){
                    if expanded{
                    
                    VisualEffectView(effect: UIBlurEffect(style: .regular))
//                        .background(Color.white.opacity(0.5))
                    .edgesIgnoringSafeArea(.vertical)
                    
                    }
                }.animation(.linear(duration: 0.2))
                VStack{
                    Spacer()
    //                Color.init(white: 0.95)
                    Color.white.opacity(0.1)
    //                    .background(Color.black.opacity(0.5))
                        
                    .edgesIgnoringSafeArea(.bottom)
                        //The height accounts for the bar_view_Height, view_Height, the height of the safe layout guideline, and 20 more for aesthetics above the actual buttons
                        .frame(height: self.env.isLoggedIn ? 40 + (UniversalSafeOffsets?.bottom ?? 0) : 0)
                        .cornerRadius(30, corners: [.topRight, .topLeft])
                }
                .edgesIgnoringSafeArea(.bottom)
                .shadow(radius: 3)
                .animation(Animation.interpolatingSpring(stiffness: 330, damping: 18.0, initialVelocity: 4))
                VStack{
                    Spacer()
    //                Color.init(white: 0.95)
                    VisualEffectView(effect: UIBlurEffect(style: .extraLight))
    //                    .background(Color.black.opacity(0.3))
    //                    .opacity(0.9)
                        
                    .edgesIgnoringSafeArea(.bottom)
                        //The height accounts for the bar_view_Height, view_Height, the height of the safe layout guideline, and 20 more for aesthetics above the actual buttons
                        .frame(height: self.env.isLoggedIn ? 40 + (UniversalSafeOffsets?.bottom ?? 0) : 0)
                        .cornerRadius(30, corners: [.topRight, .topLeft])
                }
                .edgesIgnoringSafeArea(.bottom)
                .shadow(radius: 3)
                .animation(Animation.interpolatingSpring(stiffness: 330, damping: 18.0, initialVelocity: 4))
                VStack(spacing:0){
                    if expanded{
                        HStack{
                            Text("Menu")
                            .multilineTextAlignment(.leading)
                            .lineLimit(5)
                            .font(.system(size: 40, weight: .heavy))
                            .foregroundColor(.black)
    //                        .background(Color.blue)
                                
                            Spacer()
                            Button(action: {expanded = false}){
                                
                            
                            Image(systemName:"xmark")
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundColor(.black)
                            }
                            
                        }
                        .padding(.horizontal)
                        Spacer().frame(height: 15)
                        ScrollView{
                            MenuView(menuExpanded: $expanded)
                            
                                
                        }.frame(width: UniversalSquare.width)
    //                    .background(Color.red)
                    } else {
                        Spacer()
                    }
                    HStack{
                        
                        HStack(spacing: 0){
                            Spacer()

                                Image(systemName: "house")
                                    .resizable()
                                    .scaledToFit()
                                    .modifier(TabBarImage())
                                    .foregroundColor(selection == TabOptions.Home.rawValue ? lightGreen : Color.init(white: 0.6))
                                    .onTapGesture {
                                        withAnimation{
                                            selection = SubmitNewSelection(TabOptions.Home.rawValue, currentSelection: selection)
                                            
                                        }
                                            expanded = false
                                    }
                            Spacer()
                            Image(systemName:"magnifyingglass")
                                .resizable()
                                .scaledToFit()
                                .modifier(TabBarImage())
                                .foregroundColor(selection == TabOptions.Search.rawValue ? lightGreen : Color.init(white: 0.6))
                                .onTapGesture {
                                    withAnimation{
                                        selection = SubmitNewSelection(TabOptions.Search.rawValue, currentSelection: selection)
                                    }
                                        expanded = false
                                }
                            Spacer()

                                Image(systemName:"plus.square")
                                    .resizable()
                                    .scaledToFit()
                                    .modifier(TabBarImage())
                                    .foregroundColor(selection == TabOptions.New.rawValue ? lightGreen : Color.init(white: 0.6))
                                    .onTapGesture {
                                        withAnimation{
                                            self.showNewRecipe = true
                                        }
                                            expanded = false
                                    }
                            Spacer()
                            
                            Image(systemName:"person.circle")
                                .resizable()
                                .scaledToFit()
                                .modifier(TabBarImage())
                                .foregroundColor(selection == TabOptions.User.rawValue ? lightGreen : Color.init(white: 0.6))
                                .onTapGesture {
                                    withAnimation{
                                        selection = SubmitNewSelection(TabOptions.User.rawValue, currentSelection: selection)
                                        
                                    }
                                        expanded = false
                                }
                            Spacer()
                            if true {
                                Button(action: {
                                if expanded {
                                    expanded = false
                                } else {
                                    expanded = true
                                }
                            }){
                                Image(systemName: expanded ? "xmark" : "line.horizontal.3")
                                    .resizable()
                                    .scaledToFit()
                                .modifier(TabBarImage())
                                .foregroundColor(expanded ? darkRed : Color.init(white: 0.6))
                            }
                            Spacer()
                            }
                            

                            }
                            .padding(5)
                            .clipped()
                        
                        
                            
                            
                        
                    }
                        
                    .edgesIgnoringSafeArea(.bottom)
                    .frame(height: self.env.isLoggedIn ? 40 + (UniversalSafeOffsets?.bottom ?? 0) : 0)
                        .cornerRadius(30, corners: [.topRight, .topLeft])
                    
                    .animation(Animation.interpolatingSpring(stiffness: 330, damping: 18.0, initialVelocity: 4))
                }
                .animation(Animation.interpolatingSpring(stiffness: 330, damping: 18.0, initialVelocity: 4))
                .edgesIgnoringSafeArea(.bottom)
            }
            .fullScreenCover(isPresented: self.$showNewRecipe){
                NewPost_ImageSelectionView(shown: $showNewRecipe)
            }
        }
        
        
        func SubmitNewSelection(_ newSelection: Int, currentSelection: Int) -> Int{
            if (currentSelection == TabOptions.New.rawValue) && (newSelection != currentSelection){
                self.env.bToggleTabbedRoot = true
//                InAppNotication(text: "You started a recipe but did not finish it. You can always come back to finish it later.", duration: 4)
            }

            return newSelection
        }
    }

    
