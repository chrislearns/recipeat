//
//  QueryCommandCentral.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/4/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import Firebase
import SPAlert
import SwiftUI
import NaturalLanguage

//These will need to go before this function gets executed
//searchResults.results = []
//self.searchState = SearchState.Searching
enum QueryType {
    case ArrayContainsAny, EqualTo, In, isGreaterThanOrEqualTo, isLessThanOrEqualTo, isLessThan, isGreaterThan, order_and_Limit, isEqualTo
}

enum QueryFilterType {
    case isGreaterThanOrEqualTo, isLessThanOrEqualTo, isLessThan, isGreaterThan, order_and_Limit, isEqualTo, In, ArrayContains
}

struct QueryFilter{
    var queryFilterType:QueryFilterType
    var field:String
    var filterArgument:Any
}

struct QueryRound:Identifiable {
    var id = UUID()
    var queryType:QueryType
    var refString:String
    var field:String
    var QueryWeight:Double
    var value:Any
    var expectedReturn:SearchType
    var filters:[QueryFilter] = []
    var QueryClosure:(([Identifiable_Any], Date) -> Void)?
}

func form_QueryRound_search(searchType:SearchType, searchTerm: String, completion: @escaping ([Identifiable_Any], Date) -> Void){
    let queryItems = searchTerm.alphanumerics_andWhiteSpace.lowercased().split(separator: " ")
    //            p/(queryItems)
    
    var userQueries:[QueryRound] = [
        QueryRound(queryType: .ArrayContainsAny, refString: "users", field: "tags_name", QueryWeight: 200, value: queryItems, expectedReturn: .User),
        QueryRound(queryType: .EqualTo, refString: "users", field: "lowercased_name", QueryWeight: 500, value: searchTerm.lowercased(), expectedReturn: .User),
        QueryRound(queryType: .EqualTo, refString: "users", field: "lowercased_username", QueryWeight: 1000, value: searchTerm.lowercased(), expectedReturn: .User),
        QueryRound(queryType: .In, refString: "users", field: "lowercased_username", QueryWeight: 100, value: queryItems, expectedReturn: .User),
        
        
           
    ]
    
    
    //This is needed to do a check of all the title word - and we have to break it up into multiple calls of groups of 10 because the arraycontainsany query can only take 10 arguments at a time
    let chunkedTitleTags = queryItems.chunked(by: 10)
    var recipeQueries:[QueryRound] = [
        QueryRound(queryType: .EqualTo, refString: "recipe", field: "lowercased_title", QueryWeight: 1000, value: searchTerm.lowercased(), expectedReturn: .Recipe)] +
        chunkedTitleTags.map({
            QueryRound(queryType: .ArrayContainsAny, refString: "recipe", field: "tags_title", QueryWeight: 200, value: $0, expectedReturn: .Recipe)
        }) +
        chunkedTitleTags.map({
            QueryRound(queryType: .In, refString: "recipe", field: "postingUser.username", QueryWeight: 100, value: $0, expectedReturn: .Recipe)
        })
    
    

    
    //This adds the "startsWith" search
    if let lastTerm = searchTerm.lowercased().split(separator: " ").last?.description {
        print("last term = \(lastTerm)")
        if let upperLimit = lastTerm.lastChar_next() {
            print("Searching between \(lastTerm) -> \(upperLimit)")
            //Add user Adjuncts
            if searchType == SearchType.User || searchType == SearchType.All{
                userQueries = userQueries +
                    [
                        QueryRound(queryType: .isGreaterThanOrEqualTo, refString: "users", field: "lowercased_name", QueryWeight: 80, value: lastTerm, expectedReturn: .User, filters: [QueryFilter(queryFilterType: .isLessThanOrEqualTo, field: "lowercased_name", filterArgument: upperLimit)]),
                        QueryRound(queryType: .isGreaterThanOrEqualTo, refString: "users", field: "lowercased_username", QueryWeight: 80, value: lastTerm, expectedReturn: .User, filters: [QueryFilter(queryFilterType: .isLessThanOrEqualTo, field: "lowercased_username", filterArgument: upperLimit)])
                ]
            }
            
            //Add recipe Adjuncts
            if searchType == SearchType.Recipe || searchType == SearchType.All{
                recipeQueries = recipeQueries +
                [QueryRound(queryType: .isGreaterThanOrEqualTo, refString: "recipe", field: "lowercased_title", QueryWeight: 80, value: lastTerm, expectedReturn: .Recipe, filters: [QueryFilter(queryFilterType: .isLessThanOrEqualTo, field: "lowercased_title", filterArgument: upperLimit)])]
            }
        
        }
    }
    
    
    
    
    if searchType == .User {
        
        
        //First Query - Search for any matching components between the name of the user and the parsed text we are searching with
        //Second Query - Search for a perfect name match. note we are searching the lowercased form of the name because we have stored it on the database in the lwoercased form, as well as the standard case
        //Third Query - Search for a perfect username match. note we are searching the lowercased form of the username because we have stored it on the database in the lwoercased form, as well as the standard case
        //Fourth Query - Search for whether a username matches at least one of the whitespace-split terms you searched. note we are searching the lowercased form of the username because we have stored it on the database in the lwoercased form, as well as the standard case
        
        
        DistributeQueryLoads(queryRounds: userQueries, completion: completion)
        
    } else if searchType == .Recipe {
        
        ///First Query - Search for a perfec title match
        ///Second Query - Search for a title with a word in our search
        ///Third Query - Search for recipes with a posting user's username that matches one of the word in the split search items
        
        
        
        
        DistributeQueryLoads(queryRounds: recipeQueries, completion: completion)
    }
    else if searchType == .All {
           
           ///This will combine all query options
            let allQueries = userQueries + recipeQueries
        
           DistributeQueryLoads(queryRounds: allQueries, completion: completion)
        
    }
}

func DistributeQueryLoads(queryRounds:[QueryRound], qDate: Date = Date(), completion: @escaping ([Identifiable_Any], Date) -> Void){
    var queriesLeft = 0
    var unfiltered_results:[Identifiable_Any] = []
    
     
    
    //FIRST - all queries in the list of query rounds will circulate and loop through here
    func performQuery(queryRound:QueryRound){
        FS_Query(queryType: queryRound.queryType, queryFilters: queryRound.filters, refString: queryRound.refString, queryField: queryRound.field, seekValue: queryRound.value, completion: {
            (outcome, queryTime, values)  in
//            p/rint(outcome)
//            p/rint(queryTime)
//            p/rint(values as Any)
            
            println("performing query: \(queryRound.queryType) -- Field: \(queryRound.field) -- Value: \(queryRound.value)", 0 )
            
                process_preliminaryQuery(outcome: outcome, queryTime: queryTime, values: values, QueryWeight: queryRound.QueryWeight, expectedType: queryRound.expectedReturn)
        })
    }
    
    //SECOND - This function will process all preliminary query results - this is just to make sure all queries are back - this has not even started the point assigning process OR display of results
    func process_preliminaryQuery(outcome: completionHander_outcome, queryTime: Date, values: Any?, QueryWeight: Double, expectedType: SearchType){
        if outcome == completionHander_outcome.success {
            //            p/("query was successful")
            //            p/("\(queryTime) || \(Date())")
            
            if let values = values as? QuerySnapshot {
                if let fetchedSearch = fsData_toLocalStruct(fsData: values, structType: expectedType, QueryWeight: QueryWeight) {
                    
                    //            p/("previousResult count = \(unfiltered_results.count)")
                    //            p/("fetchedResult count = \(fetchedSearch.count)")
                    unfiltered_results = unfiltered_results + fetchedSearch
                    //            p/("currentResult count = \(unfiltered_results.count)")
                    
                } else {
                    //            p/("err - could not unwrap fs->locstructs")
                    //            p/("\(String(describing: fsData_toLocalStruct(fsData: values, structType: expectedType, QueryWeight: QueryWeight)))")
                    
                }
            } else {
                let alertView = SPAlertView(title: "Couldn't unwrap search results - \(String(describing: values))", message: "err: 9asvm 47ssk", preset: SPAlertPreset.error)
                alertView.duration = 3
                alertView.present()
            }
        } else {
            let alertView = SPAlertView(title: "Search failed", message: "err: 3r9va v2394", preset: SPAlertPreset.error)
            alertView.duration = 3
            alertView.present()
        }
        queriesLeft -= 1
        if queriesLeft == 0 {
            secondaryProcessing(queryTime: queryTime)
        }
    }
    
    //THIRD - This function will finish processing the data, both filtering duplicates and sorting results. It will then fire the closure of DistributeQueryLoads()
    func secondaryProcessing(queryTime:Date){
        //            p/("found all queries - queriesLeft = \(queriesLeft)")
        //            p/("Total query results = \(unfiltered_results)")
        
        //The filtering is essentially removing duplicates in the different queries that are being compounded
        var filteredResults:[Identifiable_Any] = []
        //Need to remove duplicates while adding up their weights as duplicates are found
        print(unfiltered_results.map({($0.any as? user)?.username}))
        
        for unfilteredResult in unfiltered_results {
            //            p/(filteredResults[unfilteredResult.id.uuidString])
            if let presentResult = filteredResults.firstIndex(where: {$0.id.uuidString == unfilteredResult.id.uuidString}){
                //            p/("result present - Old QueryWeight: \(filteredResults[unfilteredResult.id.uuidString]!.QueryWeight)")
                filteredResults[presentResult].QueryWeight = filteredResults[presentResult].QueryWeight + unfilteredResult.QueryWeight
                //            p/("New QueryWeight: \(filteredResults[unfilteredResult.id.uuidString]!.QueryWeight)")
            } else {
                filteredResults.append(unfilteredResult)
            }
        }
        print(unfiltered_results.map({($0.any as? user)?.username}))
        
        //We can sort them BY QUERYWEIGHT - but i only want this done if there is actually a differential in the weights. Otherwise we end up ruining the order if we didnt need to do this
        let sortedResults = filteredResults.sorted{ $0.QueryWeight > $1.QueryWeight }
        if let sortedFirst = sortedResults.first, let sortedLast = sortedResults.last{
            if sortedFirst.QueryWeight != sortedLast.QueryWeight {
                //Now need to sort
                completion(sortedResults, queryTime)
            } else {
                completion(filteredResults, queryTime)
            }
        } else {
            completion(filteredResults, queryTime)
        }
        
    }
    
    queriesLeft = queryRounds.count
    
    if queryRounds.count == 0 {
        //            p/("no queries to perform")
        completion([], qDate)
    }
    for this_QR in queryRounds {
        performQuery(queryRound: this_QR)
    }
    
    
    
    
}
