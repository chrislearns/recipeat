//
//  FloatingTagsView.swift
//  monospaced_trial
//
//  Created by Christopher Guirguis on 5/10/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
struct TagObject:Identifiable {
    var id = UUID()
    var tagEntity:TagEntity
    var selected:Bool
}

struct TagObjectList:Identifiable {
    var id = UUID()
    var tagEntities:[TagObject]
}

struct StandardTagViewAttributes{
    var fontSize:CGFloat = 15
    var wordPadding:CGFloat = 8
    var tagSpacing:CGFloat = 7
}

struct FloatingTagsView: View {
    
    var tagObjects:[TagObject]
    @Binding var tagRows:[TagObjectList]
    @State var modifiable = true
    var containerWidth = UniversalSquare.width
    
    var containerPadding:CGFloat = 10
    var body: some View {
        VStack(spacing: StandardTagViewAttributes().tagSpacing){
            ForEach(tagRows, id: \.id){thisRow -> AnyView in
                return AnyView(HStack(spacing:StandardTagViewAttributes().tagSpacing){
                    ForEach(thisRow.tagEntities, id: \.id){thisTagObject in
                        Button(action: {
                            let i = self.tagRows.getIndexOf(thisRow)
                            let j = thisRow.tagEntities.getIndexOf(thisTagObject)
                            self.tagRows[i].tagEntities[j].selected.toggle()
                        }){
                            TagItemView(fontSize: StandardTagViewAttributes().fontSize, wordPadding: StandardTagViewAttributes().wordPadding,  text: self.$tagRows[self.tagRows.getIndexOf(thisRow)].tagEntities[thisRow.tagEntities.getIndexOf(thisTagObject)].tagEntity.displayVal,
                                        selected: self.$tagRows[self.tagRows.getIndexOf(thisRow)].tagEntities[thisRow.tagEntities.getIndexOf(thisTagObject)].selected)
                        }
                        
                    }
                    
                })
            }
        }
        .padding(containerPadding)
        .frame(width: containerWidth)
    
        .onAppear(){
            self.tagRows = self.buildLists(
                tagObjs: self.tagObjects,
                distribution: self.assignRows(
                    fontSize: StandardTagViewAttributes().fontSize,
                    containerWidth: self.containerWidth - (2 * self.containerPadding),
                    wordPadding: StandardTagViewAttributes().wordPadding, tagSpacing: StandardTagViewAttributes().tagSpacing, floatingWords: self.tagObjects)
            )
        }
    }
    func assignRows(fontSize: CGFloat, containerWidth: CGFloat, wordPadding:CGFloat, tagSpacing:CGFloat, floatingWords:[TagObject]) -> [Int]{

        var _:[Identifiable_AnyView] = []
        //First I will cycle through and determine the elements in each row
        var remainingWidth = containerWidth
        
        var viewsPerRow:[Int] = []
        var wordCount = 0
        print("remaining width = \(remainingWidth)")
        for i in 0..<floatingWords.count {
            let word = floatingWords[i]
            let wordWidth = getMonospacedTextWidth(word: word.tagEntity.displayVal, fontSize: fontSize)
            let requireSpace = wordWidth + (2 * wordPadding) + (2 * tagSpacing)
//            print("requires: \(requireSpace) - remaining: \(remainingWidth)")
            if remainingWidth > requireSpace {
                wordCount += 1
                remainingWidth = remainingWidth - requireSpace
                if i == floatingWords.count - 1 {
                    print("reached the last index - adding the views perRow to the array")
                    viewsPerRow.append(wordCount)
                    remainingWidth = containerWidth - (2*containerPadding)
                    wordCount = 0
                }
            } else {
                print("\(word.tagEntity.displayVal) requires: \(requireSpace) - remaining: \(remainingWidth)")
                viewsPerRow.append(wordCount)
                remainingWidth = containerWidth - (2*containerPadding)
                remainingWidth = remainingWidth - requireSpace
                //This is not resetting back to 0 BECAUSE we are technically a) acknowledging that this word needs to end up on a new row, and b) putting it on that row (i.e. wordCount = 0 + 1 because the 1 is use taking the new word into account)
                wordCount = 1
            }
        }
        
        return viewsPerRow
        //Second I will cycle through the categories and create those views
        
    }
    
    func buildLists(tagObjs:[TagObject], distribution:[Int]) -> [TagObjectList]{
        var returnVal:[TagObjectList] = []
        var index = 0
        for row in distribution{
            var rowItems:[TagObject] = []
            for _ in 0..<row{
                
                rowItems.append(tagObjs[index])
                index = index + 1
            }
            returnVal.append(TagObjectList(tagEntities: rowItems))
            
        }
        return returnVal
    }
    
    
    
}

func getMonospacedTextWidth(word: String, fontSize: CGFloat) -> CGFloat{
    return CGFloat(word.count) * (fontSize) * (0.63)
}
//
//struct FloatingTagsView_Previews: PreviewProvider {
//    static var previews: some View {
//        FloatingTagsView()
//    }
//}

struct TagItemView: View {
    var fontSize:CGFloat?
    var wordPadding:CGFloat
    var bgColor:Color? = nil
    var fgColor:Color? = nil
    var font:Font? = nil
    @Binding var text:String
    @Binding var selected:Bool
    
var body: some View {
    
    Text(text)
        .font(font == nil ? ( .system(size: self.fontSize == nil ? StandardTagViewAttributes().fontSize : self.fontSize!, weight: .medium, design: .monospaced)) : font)
        .foregroundColor(fgColor == nil ? (selected ? Color.white : Color.init(white: 0.5)) : fgColor!)
        .frame(
//            width: getMonospacedTextWidth(word: text, fontSize: self.fontSize),
            height: 30
    ).clipped()
        .lineLimit(1)
        .padding(.horizontal, self.wordPadding)
        .background(bgColor == nil ? (selected ? lightGreen : Color.init(white: 0.9)) : bgColor!)
//        .animation(.linear(duration: 0.2))
        .cornerRadius(5)
        .clipped()
}
}
