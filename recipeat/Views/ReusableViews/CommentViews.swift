//
//  CommentViews.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/16/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
import SPAlert


struct CommentView_Default: View {
    @EnvironmentObject var env: GlobalEnvironment
    var comment:Comment
    @State var showReporting:Bool = false
    var isOwner:Bool = false
    var isSelf:Bool = false
    var goToCommenter:() -> Void
    var completion:(completionHander_outcome) -> Void
    var commentPath:String
    
    
    @State var attemptingDelete = false
    @State var showActions = false
    var body: some View {
        ZStack{
            HStack{
                VStack(alignment: .leading){
                    Text("@\(comment.commentingUser.username)")
                        .font(.system(size: 16, weight: .semibold))
                    Text("\(comment.message)")
                        .font(.system(size: 16, weight: .medium))
                    if DateDifference_Displayable(itemDate: date_fromTimeString_UTC(comment.dateCreate)) != nil {
                        Text(DateDifference_Displayable(itemDate: date_fromTimeString_UTC(comment.dateCreate))!)
                            .font(.footnote)
                            .foregroundColor(isOwner ? Color.white.opacity(0.8) : Color.init(white:0.7).opacity(0.8))
                    }
                    
                    
                    
                }
                Spacer()
            }
            .padding(10)
            .background(isOwner ? lightPink : Color.init(white: 0.9))
            .foregroundColor(isOwner ? Color.white : Color.black)
            .cornerRadius(10, corners: isOwner ? [.topRight, .topLeft, .bottomLeft] : [.topRight, .topLeft, .bottomRight])
            .onTapGesture {
                self.showActions = true
            }
            ZStack{
                Color.white.opacity(0.8)
                Text("Deleting comment...")
                    .foregroundColor(Color.init(white: 0.3))
            }.opacity(attemptingDelete ? 1 : 0).animation(.easeInOut(duration: 0.3))
        }.actionSheet(isPresented: $showActions){
            ActionSheet(title: Text("More options"), message: Text("Choose an action from below"), buttons: [
                isSelf ? .destructive(Text("Delete Comment").foregroundColor(.red), action: {
                    self.attemptingDelete = true
                    println("deleting comment", 0)
                    deleteComment(commentID: self.comment.id.uuidString, recipeID: self.comment.assocRecipe, completion: {outcome in
                        self.completion(outcome)
                        self.attemptingDelete = false
                    })
                })
                    : .default(Text("View Profile"), action: {
                        self.goToCommenter()
                    }),
                .destructive(Text("Report"), action: {self.showReporting = true}),
                .cancel()
            ])
            
        }
    .sheet(isPresented: $showReporting){
        ReportView(
            isShown: self.$showReporting,
            report_correspondingEntityType: RecipeatEntity.Comment,
            report_correspondingEntityID: self.comment.id,
            report_reportingUser: self.env.currentUser.truncForm,
            report_entityPath: self.commentPath,
            closureAfterSubmit: {
                let alertView = SPAlertView(title: "Violation Reported", message: "Thank you for keeping our community safe. Your report has been submitted successfully", preset: SPAlertPreset.done)
                alertView.duration = 3
                alertView.present()
            }
        )
        }
    }
}


struct CommentView_Add: View {
    @EnvironmentObject var env: GlobalEnvironment
    var recipeID:String
    @State var attemptingAdd = false
    var completion:(completionHander_outcome) -> Void
    @State var message:String = ""
    var body: some View {
        ZStack{
            HStack(spacing:15){
            TextField("Message", text: $message)
                
                .padding(10)
                .background(Color.init(white: 0.95))
                .foregroundColor(Color.black)
                .cornerRadius(10)
                Button(action: {
                    if self.message.count == 0 || self.message.count > 1000 {
                        let alertView = SPAlertView(title: "Oops!", message: "Make sure your comment isn't empty but also isn't greater than 1,000 characters in length", preset: SPAlertPreset.exclamation)
                        alertView.duration = 3
                        alertView.present()
                    } else {
                        self.attemptingAdd = true
                        UIApplication.shared.endEditing()
                        println("submitting comment: \(self.message)", 0)
                        
                        createComment(msg: self.message, recipe: self.recipeID, commenter:self.env.currentUser.truncForm, completion: {outcome in
                            self.completion(outcome)
                            self.attemptingAdd = false
                        })
                        //This has to be done synchronously, from a UI standpoint, and it must be dont after the initialization of the createComment function, to make sure that the proper message is passed into that function
                        self.message = ""
                    }
                
            }){
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(lightGreen)
                    .font(.system(size: 30))
            }
        }
            ZStack{
                Color.white.opacity(0.8)
                Text("Posting comment...")
            }.opacity(attemptingAdd ? 1 : 0).animation(.easeInOut(duration: 0.3))
        }
        .frame(height:40)
//        .background(Color.blue)
    }
}

