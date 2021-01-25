//
//  MLAlgorithms.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/12/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import UIKit
import Foundation
import NaturalLanguage

struct TaggedWord {
    var word:String
    var tag:NLTag
}

func evaluateComponents(text: String) -> [TaggedWord]{
    var returnVal:[TaggedWord] = []
    //    let text = "Slice zucchini about 1/8 of an inch (slicer is recommended) Grill zucchini slices on pan for about 1-2 minutes on each side. This will remove some of the moisture from the zucchini so that your lasagna isn’t very watery. To make your sauce, add the 4 cheese pasta sauce in a pot. Mix in  ½ cup of parmesan cheese. Then sprinkle 1/2 a tbsp of salt, pinch of onion salt, pinch of lemon pepper, and a pinch of dried basil. Mix and then turn on the stove to medium heat and let it come to a boil. Once it comes to a boil, remove it from the stove. In a separate bowl, add the ricotta cheese. Mix in 1 large egg and 1 ½ tbsp of salt. Add more salt to your tasting if needed In a 8x8 square pan spread ¼ cup of sauce and spread it around so nothing will stick to the bottom of the pan Add zucchini slices. Overlap them by about half of the zucchini slice Once you get to the last layering of zucchini, add ½ cup of mozzarella cheese and ½ cup of parmesan cheese. "
    
    // Initialize the tagger
    let tagger = NLTagger(tagSchemes: [.lexicalClass])
    // Ignore whitespace and punctuation marks
    let options : NLTagger.Options = [.omitWhitespace, .omitPunctuation]
    // Process the text for POS
    tagger.string = text
    
    // loop through all the tokens and print their POS tags
    tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
        if let tag = tag{
            let thisText = text[tokenRange].description
            
            returnVal.append(TaggedWord(word: thisText, tag: tag))
//            print("\(text[tokenRange]): \(tag.rawValue)")
        }
        return true
        
    }
    return returnVal
//    print("POS3:")
//    print(returnVal)
//    print("--------")
    
}




func embedCheck(word: String) -> [String]?{
    // Extract the language type
    let lang = NLLanguage.english
    // Get the OS embeddings for the given language
    let embedding = NLEmbedding.wordEmbedding(for: lang)
    
    // Find the 10 words that are nearest to the input word based on the embedding
    
    if let res = embedding?.neighbors(for: word, maximumCount: 10) {
        // Print the words
        //        print(res)
        return res .map{$0.0}
    } else {
        return nil
    }
}

extension String {
    func rootWord() -> [String]{
        // Initialize the NLTagger with scheme type as "lemma"
        let tagger = NLTagger(tagSchemes: [.lemma])
        // Set the string to be processed
        tagger.string = self
        var roots:[String] = []
        // Loop over all the tokens and print their lemma
        tagger.enumerateTags(in: self.startIndex..<self.endIndex, unit: .word, scheme: .lemma) { tag, tokenRange in
          if let tag = tag {
            roots.append(tag.rawValue)
            println("\(self[tokenRange]): \(tag.rawValue)")
            
          }
          return true
        }
        return roots
    }
}


//// Find words similar to cheese
//print(embedCheck(word: "coffee"))
