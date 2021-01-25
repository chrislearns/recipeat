    //
    //  OnboardingSlideView.swift
    //  recipeat
    //
    //  Created by Christopher Guirguis on 9/24/20.
    //  Copyright © 2020 Christopher Guirguis. All rights reserved.
    //

    import SwiftUI


    struct OnboardingFonts{
    var buttonFont = Font.system(size: 15, weight: .semibold)
    var headingFont = Font.system(size: 25, weight: .semibold)
    var subheadingFont = Font.system(size: 15, weight: .semibold)
    }
    
    struct OnboardingButton{
        var text:String
        var action:() -> Void
    }


    struct FullScreenModalView: View {
        @EnvironmentObject var env: GlobalEnvironment
     @Environment(\.presentationMode) var presentationMode
        
        @Binding var user_forPage:user
    @State var currentSlide = 0

    var totalSlides = 4
    var body: some View {
        
    ZStack{
            
        ProfilePicSelectView(user_forPage: $user_forPage, closureAfterUpload: {_ in presentationMode.wrappedValue.dismiss()})
        ZStack{
            OnboardingSlideView(
            currentSlide: $currentSlide,
            slideNumber: 3,
            PreviousOnboardingButton: OnboardingButton(text: "PREVIOUS", action: {currentSlide = currentSlide - 1}),
            NextOnboardingButton: OnboardingButton(text: "LET'S GO", action: {currentSlide = currentSlide + 1}),
            heading: "Learn how to make new things, yourself!",
            subheading: "If you're looking for inspiration, you'll find no shortage here! From friends to top chefs, we have it all!",
            image: "onboard_pancakes"
        )
        OnboardingSlideView(
            currentSlide: $currentSlide,
            slideNumber: 2,
            PreviousOnboardingButton: OnboardingButton(text: "PREVIOUS", action: {currentSlide = currentSlide - 1}),
            NextOnboardingButton: OnboardingButton(text: "NEXT", action: {currentSlide = currentSlide + 1}),
            heading: "Save those recipes for later!",
            subheading: "Find things now - make them later! Why wait until your stuck in order to find your next new idea?",
            image: "onboard_list"
        )
        OnboardingSlideView(
            currentSlide: $currentSlide,
            slideNumber: 1,
            PreviousOnboardingButton: OnboardingButton(text: "PREVIOUS", action: {currentSlide = currentSlide - 1}),
            NextOnboardingButton: OnboardingButton(text: "NEXT", action: {currentSlide = currentSlide + 1}),
            heading: "Find food you like from people you’ll love!",
            subheading: "Explore dishes through our discovery page, or see what your friends are posting!",
            image: "onboard_rollingPin"
        )
        OnboardingSlideView(
            currentSlide: $currentSlide,
            slideNumber: 0,
            PreviousOnboardingButton: nil,
            NextOnboardingButton: OnboardingButton(text: "NEXT", action: {currentSlide = currentSlide + 1}),
            heading: "Share your favorite recipes with the world",
            subheading: "Whether you're experimenting with something new, or cooking a timeless classic, we'd love to see it!",
            image: "onboard_dish"
        )
        
        
    }.background(
        Image("onboard_background")
                    .resizable()
                    .scaledToFill()
                    .offset(x: CGFloat(currentSlide) * -100)
                    .animation(Animation.interpolatingSpring(stiffness: 310, damping: 16.0, initialVelocity: 6))
    )
        .opacity(currentSlide == totalSlides ? 0 : 1).animation(.easeIn(duration: 0.3))

    }
    }

    }

    struct OnboardingSlideView: View {
    @Binding var currentSlide:Int
    var slideNumber:Int
    
        var PreviousOnboardingButton:OnboardingButton?
        var NextOnboardingButton:OnboardingButton?
        
        var heading:String
        var subheading:String
        var image:String
        
    var body: some View {
        ZStack{
            Color.clear
            VStack(alignment: .center){
                Spacer().frame(height:UniversalSafeOffsets?.top)
                Spacer()
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UniversalSquare.width/2, height: UniversalSquare.width/2, alignment: .center)
                    .opacity(currentSlide > slideNumber ? 0 : 1)
                    .offset(x:0)
//                    .animation(
//                        Animation.easeInOut(duration: 0.3)
//                    )
                    .animation(Animation.interpolatingSpring(stiffness: 300, damping: 15.0, initialVelocity: 7))
                
                Spacer().frame(height:50)
                HStack{
                    VStack(alignment: .leading){
                    Text(heading)
                        .font(OnboardingFonts().headingFont).foregroundColor(.init(white: 0.0))
                        .frame(maxHeight:80)
                        
                    Text(subheading)
                        .font(OnboardingFonts().subheadingFont).foregroundColor(.init(white: 0.3))
                    
                    Spacer().frame(height: 20)
                    
            }
            .frame(width: UniversalSquare.width * 0.8).padding()
                Spacer()
                    EmptyView()
                    Spacer()
        }
                Spacer()
                HStack{
                    if PreviousOnboardingButton != nil {
                    Button(action: {
                        PreviousOnboardingButton?.action()
        
                }){
                        Text(PreviousOnboardingButton!.text)
                            .font(OnboardingFonts().buttonFont).foregroundColor(darkGreen)
            }
                    }
                    Spacer()
                    if NextOnboardingButton != nil {
                    Button(action: {
                        NextOnboardingButton?.action()
        
                }){
                        Text(NextOnboardingButton!.text)
                            .font(OnboardingFonts().buttonFont).foregroundColor(darkGreen)
            }
                    }
                }.padding()
                
                Spacer().frame(height:UniversalSafeOffsets?.bottom ?? 20 * 2)
    }
            
}
        
        
        .frame(width:UniversalSquare.width, height:UniversalSquare.height)
        .offset(x: CGFloat(currentSlide - slideNumber) * -UIScreen.main.bounds.width)
        //        .offset(x: currentSlide > slideNumber ? -UIScreen.main.bounds.width : 0)
//                .animation(
//                    Animation.easeInOut(duration: 0.4).delay(0.1)
//                )
        .animation(Animation.interpolatingSpring(stiffness: 330, damping: 20.0, initialVelocity: 5.5))
        

        
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
//        .edgesIgnoringSafeArea(.all)
        
    }
    }

//    struct OnboardingSlideView_Previews: PreviewProvider {
//    static var previews: some View {
//        OnboardingSlideView(currentSlide: .constant(0), slideNumber: 0){
//            Text("Sample")
//        }
//    }
//    }
