//
//  ReportView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 6/11/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import SwiftSMTP
import SPAlert

enum ReportReasons:String, CaseIterable {
    case nudity = "Nudity"
    case violence = "Violence"
    case harassment = "Harassment"
    case suicideSelfInjury = "Suicide or Self Injury"
    case plagiarism = "Plagiarism"
    case falseNew = "False News"
    case spam = "Spam"
    case unauthorizedSales = "Unauthorized Sales"
    case hateSpeech = "Hate Speech"
    case terrorism = "Terrorism"
    case other = "Other"
}

struct ReportView: View {
    @Binding var isShown:Bool
    @State var report_description = ""
    var report_correspondingEntityType:RecipeatEntity
    var report_correspondingEntityID:UUID
    @State var report_reason = 0
    var report_reportingUser:trunc_user
    var report_entityPath:String
    var closureAfterSubmit:(() -> Void)?
    
    
    var body: some View {
        ScrollView{
            VStack{
                HStack{
                    VStack(alignment: .leading, spacing:0){
                        Text("Report")
                            .multilineTextAlignment(.leading)
                            .lineLimit(5)
                            .font(.system(size: 40, weight: .heavy))
                        Text("Report something that is objectionable or abusive")
                            .multilineTextAlignment(.leading)
                            .lineLimit(8)
                            .font(.system(size: 15))
                            .foregroundColor(Color.init(white: 0.5))
                    }
                    Spacer()
                }
                VStack{
                    HStack{
                        Text("MORE DETAILS (OPTIONAL)")
                        Spacer()
                    }
                        
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.bottom, 3).padding(.top, 5)
                    REP_TextView(text: $report_description, keyboardType: .default)
                        
                        .autocapitalization(.sentences)
                        .padding(5).background(Color.clear)
                        .font(.system(size: 15))
                        .frame(height:90).frame(maxWidth: .infinity)
                    .modifier(RoundedOutline())
                }
                .padding(5)
                .modifier(RoundedOutline())
                .padding(.top, 20)
                
                VStack{
                    HStack{
                        Text("REASON")
                        Spacer()
                    }
                        
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.top, 5).padding(.bottom, 3)
                    Picker(selection: $report_reason, label: Text("Reason").frame(width: 0)){
                        ForEach(0..<ReportReasons.allCases.count){i in
                            Text(ReportReasons.allCases[i].rawValue).tag(i)
                        }
                    }.labelsHidden()
                }.padding(5)
                    .modifier(RoundedOutline())
                    .padding(.top, 20)
                
                Button(action: {
                    let to = Mail.User(name: "Violation Admin", email: "christopher.g.codes@gmail.com")
                    let text =
                        """
                            Violation Report
                            - Type: \(self.report_correspondingEntityType.rawValue)
                            - Entity UUID: \(self.report_correspondingEntityID)
                            - Entity Path: \(self.report_entityPath)
                            - Reason: \(ReportReasons.allCases[self.report_reason].rawValue)
                            - Optional Details: \(self.report_description == "" ? "N/A" : self.report_description)
                            - Reporting User: \(self.report_reportingUser.id.uuidString) • @\(self.report_reportingUser.username)
                        """
                    sendMail(
                        from: smtpStandardUsers().ViolationReport,
                        to: [to],
                        subject: "Violation Report",
                        text: text,
                        completion: {outcome in
                            
                            self.isShown = false
                            if let closure = self.closureAfterSubmit{
                                DispatchQueue.main.async{
                                    closure()
                                firestoreUpdate_data(docRef_string: self.report_entityPath, dataToUpdate: ["flagged":true], completion: {outcome, any in })
                                }
                            }

                    }
                    )
                    
                    
                    
                }) {
                    Text("SUBMIT REPORT")
                    
                }.buttonStyle(CapsuleStyle(bgColor: darkPink, fgColor: Color.white))
                    .padding(.top, 20)
                
            }
                
                
                
            .padding(.vertical, 20).padding(.horizontal, 15)
        }.frame(width: UniversalSquare.width)
    }
}

//struct ReportView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReportView(report_correspondingEntityType: RecipeatEntity.Recipe)
//    }
//}
