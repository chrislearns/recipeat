//
//  RecipeatWidgets.swift
//  RecipeatWidgets
//
//  Created by Christopher Guirguis on 9/22/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
//    }
    func placeholder(in context: Context) -> RecipeEntry {
        RecipeEntry(date: Date(), recipeTitle: "Recipe Title")
    }

//    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//        let entry = SimpleEntry(date: Date(), configuration: configuration)
//        completion(entry)
//    }
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (RecipeEntry) -> ()) {
        let entry = RecipeEntry(date: Date(), recipeTitle: "Recipe Title")
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [RecipeEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset, to: currentDate)!
            let entry = RecipeEntry(date: entryDate, recipeTitle: "Recipe Title")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct RecipeEntry: TimelineEntry {
    let date:Date
    let recipeTitle:String
}
//struct CommitLoader {
//    static func fetch(completion: @escaping (Result<Commit, Error>) -> Void) {
//        let branchContentsURL = URL(string: "https://api.github.com/repos/apple/swift/branches/master")!
//        let task = URLSession.shared.dataTask(with: branchContentsURL) { (data, response, error) in
//            guard error == nil else {
//                completion(.failure(error!))
//                return
//            }
//            let commit = getCommitInfo(fromData: data!)
//            completion(.success(commit))
//        }
//        task.resume()
//    }
//
//    static func getCommitInfo(fromData data: Foundation.Data) -> Commit {
//        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
//        let commitParentJson = json["commit"] as! [String: Any]
//        let commitJson = commitParentJson["commit"] as! [String: Any]
//        let authorJson = commitJson["author"] as! [String: Any]
//        let message = commitJson["message"] as! String
//        let author = authorJson["name"] as! String
//        let date = authorJson["date"] as! String
//        return Commit(message: message, author: author, date: date)
//    }
//}



struct RecipeatWidgetsEntryView : View {
    var entry: Provider.Entry
    

    var body: some View {
        VStack{
            Text(entry.date, style: .time)
            Text(entry.recipeTitle)
        }
    }
}

@main
struct RecipeatWidgets: Widget {
    let kind: String = "RecipeatWidgets"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            RecipeatWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct RecipeatWidgets_Previews: PreviewProvider {
    static var previews: some View {
        RecipeatWidgetsEntryView(entry: RecipeEntry(date: Date(), recipeTitle: "Recipe Title"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
