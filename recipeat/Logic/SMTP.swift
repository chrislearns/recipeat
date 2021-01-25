//
//  SMTP.swift
//  recipeat
//
//  Created by Christopher Guirguis on 6/12/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import Foundation
import SwiftSMTP

class smtpStandardUsers {
    let ViolationReport = Mail.User(name: "Recipeat - Violation Report", email: "DO-NOT-REPLY@recipeat.app")
    let Support = Mail.User(name: "Recipeat - Support", email: "DO-NOT-REPLY@recipeat.app")
}


let smtp = SMTP(
    hostname: "smtp.gmail.com",     // SMTP server address
    email: "christopher.g.codes@gmail.com",        // username to login
    password: "mwggymttrgiuqdtk",            // password to login
    //public init(hostname: String,
    //email: String,
//    password: String,
    port: 465,
    tlsMode: .requireTLS, //.requireSTARTTLS,
    tlsConfiguration: nil,
    authMethods: [],
//    domainName: "localhost",
    timeout: 10

)

func sendMail(from:Mail.User, to: [Mail.User], subject:String, text: String, completion: @escaping (completionHander_outcome) -> Void){
                       
                       let mail = Mail(
                           from: from,
                           to: to,
                           subject: subject,
                           text: text
                       )

                       smtp.send(mail) { (error) in
                           if let error = error {
                               print("error sending email")
                               print(error)
                            completion(completionHander_outcome.failed)
                                
                           } else {
                               print("email sent! yay!")
                            completion(completionHander_outcome.success)
                           }
                       }
}
