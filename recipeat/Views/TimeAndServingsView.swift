//
//  TimeAndServingsView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 10/12/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct TimeAndServingsView:View{
    @Binding var estimatedServings:String
    
    @Binding var timePrep:Int
    @Binding var timeCook:Int
    @Binding var timeOther:Int
    var standardTF:Bool = false
    var midSpacer:CGFloat = 20
    
    @Binding var servingsValid:Bool
    
    var body: some View {
        VStack{
            if standardTF {
                HStack{
                    Text("Servings:")
                    TextField_Detectable(text: $estimatedServings, title: "Number of servings",
                                         
                                         onEditingChanged: { isChanging in
                                            print("isChanging = \(isChanging)")
                                            servingsValid = validate_estimatedServings(estimatedServings)
                                            
                    },
                                         onValChanged: {tfContent in
                                            DispatchQueue.main.async{
                                                print("change detected: \(tfContent)")
                                            
                                                servingsValid = validate_estimatedServings(tfContent)
                                            }
                                            
                    },
                                         onCommit: {
                                            print("committed")
                                            DispatchQueue.main.async{
                                                servingsValid = validate_estimatedServings(estimatedServings)
                                            }
                                            
                                            
                    })
                        .padding().background(Color.clear)
                        .frame(height:35)
                    .modifier(RoundedOutline())
                        .onAppear(){
                            servingsValid = validate_estimatedServings(estimatedServings)
                        }
                    
                }
                .keyboardType(.numbersAndPunctuation)
                
                .padding()
                .zIndex(15)
                
            } else {
                HStack{
                    TextField("Number of servings", text: $estimatedServings)
                    Text("Servings")
                }
                .keyboardType(.numbersAndPunctuation)
                .foregroundColor(Color.black)
                .padding()
                    .zIndex(15)
                    .background(Color.init(white: 0.9
                    ).shadow(radius: 3, y: 2))
            }
            if !servingsValid {
                Text("Servings entered should be a number")
                    .font(.system(size: 12)).foregroundColor(darkPink)
                    .frame(width: UniversalSquare.width - 80)
            }
                
            Spacer().frame(minWidth: 0, maxWidth: .infinity).frame(height: midSpacer)
                HStack(spacing:0){
                    VStack {
                        Text(
                            """
                                Prep time
                                (minutes)
                            """
                        ).font(.system(size: 13, weight: .semibold))
                        .frame(height: 50)
                            .multilineTextAlignment(.center)
                        Picker(selection: $timePrep, label: Text("").frame(width: 0)){
                            
                            TimePickerGroup()
                        }.frame(width: UniversalSquare.width/3).frame(height: 100).clipped()
                    }.frame(width: (UniversalSquare.width/3)-20).clipped()
                    VStack {
                        Text(
                            """
                                Cook time
                                (minutes)
                            """
                        ).font(.system(size: 13, weight: .semibold))
                        .frame(height: 50)
                            .multilineTextAlignment(.center)
                        Picker(selection: $timeCook, label: Text("").frame(width: 0)){
                            TimePickerGroup()
                        }.frame(width: UniversalSquare.width/3).frame(height: 100).clipped()
                    }.frame(width: (UniversalSquare.width/3)-20).clipped()
                    VStack {
                        Text(
                            """
                                Other time
                                (minutes)
                            """
                        ).font(.system(size: 13, weight: .semibold))
                        .frame(height: 50)
                            .multilineTextAlignment(.center)
                        Picker(selection: $timeOther, label: Text("").frame(width: 0)){
                            TimePickerGroup()
                        }.frame(width: UniversalSquare.width/3).frame(height: 100).clipped()
                    }.frame(width: (UniversalSquare.width/3)-20).clipped()
                }.foregroundColor(Color.black)
                
                .padding(15)
                .background(Color.init(white: 0.95))
                .cornerRadius(10)
                .clipped()
                
            
            Spacer().frame(minWidth: 0, maxWidth: .infinity)
        }.zIndex(20)
        .onChange(of: estimatedServings){estimatedServings in
            print(estimatedServings)
        }
            .animation(.easeInOut(duration: 0.3))
            .frame(minWidth: 0, maxWidth:.infinity)
            .background(Color.white)
    }
    
    
}

func validate_estimatedServings(_ validationString:String) -> Bool{
    if possible_stringToDouble(validationString) == nil || possible_stringToDouble(validationString) == -1 {
        return false
    } else {
        return true
    }
}
//struct TimeAndServingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TimeAndServingsView()
//    }
//}

struct TimePickerGroup: View {
    var body: some View {
        Group{
            Group{
                Text("0").tag(0)
                Text("5").tag(5)
                Text("10").tag(10)
                Text("15").tag(15)
                Text("20").tag(20)
                Text("25").tag(25)
                Text("30").tag(30)
                Text("35").tag(35)
                Text("40").tag(40)
                Text("45").tag(45)
            }
            Group{
                Text("50").tag(50)
                Text("55").tag(55)
                Text("60").tag(60)
                Text("65").tag(65)
                Text("70").tag(70)
                Text("75").tag(75)
                Text("80").tag(80)
                Text("85").tag(85)
                Text("90").tag(90)
                Text("95").tag(95)
            }
            Group{
                Text("100").tag(100)
                Text("105").tag(105)
                Text("110").tag(110)
                Text("115").tag(115)
                Text("120").tag(120)
                Text("125").tag(125)
                Text("130").tag(130)
                Text("135").tag(135)
                Text("140").tag(140)
                Text("145").tag(145)
            }
            Group{
                Text("150").tag(150)
                Text("155").tag(155)
                Text("160").tag(160)
                Text("165").tag(165)
                Text("170").tag(170)
                Text("175").tag(175)
                Text("180").tag(180)
                Text("185").tag(185)
                Text("190").tag(190)
                Text("195").tag(195)
            }
            Group{
                Text("200").tag(200)
                Text("205").tag(205)
                Text("210").tag(210)
                Text("215").tag(215)
                Text("220").tag(220)
                Text("225").tag(225)
                Text("230").tag(230)
                Text("235").tag(235)
                Text("240").tag(240)
                Text("245").tag(245)
            }
            Group{
                Text("250").tag(250)
                Text("255").tag(255)
                Text("260").tag(260)
                Text("265").tag(265)
                Text("270").tag(270)
                Text("275").tag(275)
                Text("280").tag(280)
                Text("285").tag(285)
                Text("290").tag(290)
                Text("295").tag(295)
            }
            Group{
                Text("300").tag(300)
            }
        }
    }
}

