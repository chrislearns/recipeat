//
//  BannerViewModifier.swift
//  recipeat
//
//  Created by Christopher Guirguis on 10/13/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import SwiftUI
//
//  Banner.swift
//  BannersSwiftUI
//
//  Created by Jean-Marc Boullianne on 11/30/19.
//  Copyright © 2019 Jean-Marc Boullianne. All rights reserved.
//
import SwiftUI

struct BannerModifier: ViewModifier {
    
    struct BannerData {
        var title:String
        var detail:String
        var type: BannerType
    }
    
//    enum BannerType {
//        case Info
//        case Warning
//        case Success
//        case Error
//
//        var tintColor: Color {
//            switch self {
//            case .Info:
//                return verifiedDarkBlue.opacity(0.9)
//            case .Success:
//                return Color.green
//            case .Warning:
//                return Color.yellow
//            case .Error:
//                return darkRed.opacity(0.9)
//            }
//        }
//    }
    
    // Members for the Banner
    @Binding var data:BannerData
    @Binding var show:Bool
    @State var duration:Double = 4
    

    
    func body(content: Content) -> some View {
        ZStack {
            content
            if show {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(data.title)
                                .bold()
                            Text(data.detail)
                                .font(Font.system(size: 15, weight: Font.Weight.light, design: Font.Design.default))
                        }
                        Spacer()
                    }
                    .foregroundColor(Color.white)
                    .padding(12)
                    .background(data.type.tintColor)
                    .cornerRadius(8)
                    Spacer()
                }
                .padding()
                .animation(.easeInOut(duration: 0.5))
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                .onTapGesture {
                    withAnimation {
                        self.show = false
                    }
                }.onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation {
                            self.show = false
                        }
                    }
                })
            }
        }
    }

}

extension View {
    func banner(data: Binding<BannerModifier.BannerData>, show: Binding<Bool>) -> some View {
        self.modifier(BannerModifier(data: data, show: show))
    }
}

struct Banner_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Hello")
        }
    }
}
