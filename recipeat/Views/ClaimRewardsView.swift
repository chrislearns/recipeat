//
//  ClaimRewardsView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/27/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import SPAlert
struct ClaimRewardsView: View {
    var showLoader:(Bool) -> Void
    var user_forPage:user
    @Binding var isShown:Bool
    @State var referralCode:String = ""
    var body: some View {
        ScrollView{
            HStack{
                Text("Claim a Referral Code")
                    .multilineTextAlignment(.leading)
                .lineLimit(5)
                    .font(.system(size: 35, weight: .heavy))
                .padding(.vertical, 10)
            Spacer()
            }
            
            VStack{
            if user_forPage.referralCode_claimed == "" {
                VStack(alignment: .leading){
                    Text("Enter a referral code. This cannot be changed once confirmed.")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.init(white: 0.6))
                        .lineLimit(5)
                    HStack{
                        TextField("Referral code", text: $referralCode)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding().background(Color.clear)
                            .frame(height:35)
                            .modifier(RoundedOutline())
                            
                        Button(action: {
                            UIApplication.shared.endEditing()
                            var errorMessage = ""
                            var returnVal = true
                            
                            
                            
                            if self.referralCode.alphanumerics.count != self.referralCode.count {
                                returnVal = false
                                errorMessage = "Please make sure your referral code is only numbers and letters"
                            } else if self.referralCode.alphanumerics.count != 8 {
                                returnVal = false
                                errorMessage = "Referral codes should only be 8 characters long."
                            } else {
                                print("submitting referral code")
                                
                                firestoreUpdate_data(docRef_string: "users/\(self.user_forPage.id.uuidString)", dataToUpdate: [
                                    "referralCode_claimed":self.referralCode.lowercased(),
                                ], completion: {_,_ in
                                    self.isShown = false
                                })
                            }
                            
                            if returnVal == false {
                                let alertView = SPAlertView(title: "Something is off...", message: errorMessage, preset: SPAlertPreset.exclamation)
                                alertView.duration = 3
                                alertView.present()
                            }
                        }){
                            Text("SUBMIT")
                                .foregroundColor(darkGreen)
                        }
                    }
                    
                    
                }
                    
                    .padding(.horizontal, 15).padding(.vertical, 10)
                    .modifier(RoundedOutline(color: darkGreen))
                    .KeyboardAwarePadding().animation(.easeIn(duration: 0.3))
            } else {
                VStack{
                    Text("You have already claimed a referral code.")
                        .lineLimit(5)
                        .frame(maxHeight: 40)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.init(white: 0.6))
                    
                    TextField("Referral code", text: .constant(self.user_forPage.referralCode_claimed))
                            .autocapitalization(.none)
                            .disabled(true)
                            .disableAutocorrection(true)
                            .padding().background(Color.clear)
                            .frame(height:35)
                            .modifier(RoundedOutline())
                            
                        
                    
                    
                }
                    
                    .padding(.horizontal, 15).padding(.vertical, 10)
                    .modifier(RoundedOutline(color: darkGreen))
                    .KeyboardAwarePadding().animation(.easeIn(duration: 0.3))
            }
            
            
            
            }
            
        }.padding(.vertical, 20).padding(.horizontal, 15)
        
    }
}

//struct ClaimRewardsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ClaimRewardsView()
//    }
//}
