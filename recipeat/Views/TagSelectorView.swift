//
//  TagSelectorView.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/10/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI

struct TagSelectorView: View {
    
    var closure:([TagEntity]) -> Void
    @Binding var isShown:Bool
    @State var tagObjects:[TagObject] = FoodTagDictionary.map{
        TagObject(tagEntity: TagEntity(keywords: $0.value .keywords, dbVal: $0.value.dbVal, displayVal: $0.value.displayVal), selected: false)
    }.sorted{ $0.tagEntity.displayVal < $1.tagEntity.displayVal }
    
    @State var tagObjectLists:[TagObjectList] = []
    
    var body: some View {
        ZStack{
            
            
            
                
                VStack{
//                    Spacer().frame(height: UniversalSafeOffsets?.top)
                    //This helps to prevent showthrough behind the title, when paired with the spacer int he overlay
                    HStack{
                        VStack(alignment: .leading, spacing:0){
                        Text("Categories")
                            .font(.system(size: 40, weight: .heavy))
                        Text("Select at least one tag")
                            .font(.system(size: 20))
                            .foregroundColor(Color.init(white: 0.5))
                    }
                        Spacer()
                    }
                    
                    
                    List{
                        ForEach(tagObjects, id: \.id){tagObject in
                            Button(action: {
                                DispatchQueue.main.async {
                                    self.tagObjects[self.tagObjects.getIndexOf(tagObject)].selected.toggle()
                                }
                                
                            }){
                                HStack{
                                    Text("\(tagObject.tagEntity.displayVal)")
                                        .animation(.easeInOut(duration: 0.3))
                                    if tagObject.selected {
                                        Image(systemName: "checkmark.circle")
                                            .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
                                            .animation(.easeInOut(duration: 0.3))
                                    }
                                }.foregroundColor(tagObject.selected ? darkGreen : Color.black)
                                
                            }
                        }
                    }.padding(.vertical, 15)
                        .overlay(
                            VStack{
                                
                                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(1),Color.white.opacity(0)]), startPoint: .top, endPoint: .bottom).frame(height: 35)
                                Spacer()
                                
                                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0),Color.white.opacity(1)]), startPoint: .top, endPoint: .bottom).frame(height: 35)
                            }.frame(width: UniversalSquare.width)
                    )
                    
                    
                    //                        FloatingTagsView(tagObjects: tagObjects, tagRows: $tagObjectLists)
                    
                    Button(action: {
                        //                    var allTaggedObjects:[TagObject] = []
                        //                    allTaggedObjects = .filter{$0.selected == true}
                        ////                    for TO_list in self.tagObjectLists {
                        ////                        allTaggedObjects = allTaggedObjects + TO_list.tagEntities
                        ////                    }
                        let selectedEntities = self.tagObjects.filter{$0.selected == true}.map{$0.tagEntity}
                        
                        self.closure(selectedEntities)
                    }) {
                        Text("SAVE")
                    }.zIndex(20)
                        .buttonStyle(CapsuleStyle(bgColor: darkGreen, fgColor: Color.white, height: 50))
                        .padding(.bottom, 20)
                    //This accounts for the safe space
//                    Spacer().frame(height: UniversalSafeOffsets?.bottom)
                }
                .padding(.vertical, 20).padding(.horizontal, 15)
                    
                .clipped()
            
            
        }
    }
    
    
}

struct TagSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        TagSelectorView(closure: {tagEntities in print(tagEntities)}, isShown: .constant(true))
    }
}
