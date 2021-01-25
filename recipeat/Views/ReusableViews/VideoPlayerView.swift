//
//  VideoPlayerView.swift
//  trial_customVideoPlayer
//
//  Created by Christopher Guirguis on 11/9/20.
//

//
//  ContentView.swift
//  videoSample
//
//  Created by Benoit PASQUIER on 24/09/2020.
//
import AVFoundation
import SwiftUI
import Combine

enum PlayerGravity {
    case aspectFill
    case resize
    case aspectFit
}

class PlayerView: UIView {
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    let gravity: PlayerGravity
    
    init(player: AVPlayer, gravity: PlayerGravity) {
        self.gravity = gravity
        super.init(frame: .zero)
        self.player = player
        self.backgroundColor = .black
        setupLayer()
    }
    
    func setupLayer() {
        switch gravity {
        
        case .aspectFill:
            playerLayer.contentsGravity = .resizeAspectFill
            playerLayer.videoGravity = .resizeAspectFill
            
        case .aspectFit:
            playerLayer.contentsGravity = .resizeAspect
            playerLayer.videoGravity = .resizeAspect
            
        case .resize:
            playerLayer.contentsGravity = .resize
            playerLayer.videoGravity = .resize
            
        }
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

final class PlayerContainerView: UIViewRepresentable {
    typealias UIViewType = PlayerView
    
    let player: AVPlayer
    let gravity: PlayerGravity
    
    init(player: AVPlayer, gravity: PlayerGravity) {
        self.player = player
        self.gravity = gravity
    }
    
    func makeUIView(context: Context) -> PlayerView {
        return PlayerView(player: player, gravity: gravity)
    }
    
    func updateUIView(_ uiView: PlayerView, context: Context) { }
}

class PlayerViewModel: ObservableObject {

    let player: AVPlayer
    
    init(_ loc: String) {
//        let url = Bundle.main.url(forResource: fileName, withExtension: "mp4")
        print("loc: " + loc)
                let url = URL(string: loc)
        let playerItem = AVPlayerItem(url: url!)
        self.player = AVPlayer(playerItem: playerItem)
        print("duration --- \(playerItem.asset.duration.seconds)")
        self.player.volume = 0
        play()
        player.actionAtItemEnd = .none
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
        
    }
    @objc func playerItemDidReachEnd(notification: Notification) {
        setToZero(notification.object as? AVPlayerItem)
    }
    
    func setToZero(_ avplayeritem:AVPlayerItem?){
        if let playerItem = avplayeritem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
        }
    }
    
    @Published var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                play()
            } else {
                pause()
            }
        }
    }
    
    func play() {
        let currentItem = player.currentItem
        if currentItem?.currentTime() == currentItem?.duration {
            currentItem?.seek(to: .zero, completionHandler: nil)
        }
        
        player.play()
    }
    
    func pause() {
        player.pause()
    }
}

struct VideoPlayerView: View {

    @Binding var selection:Int
    @State var baseIndex:Int
    @ObservedObject var model: PlayerViewModel
    @State var volOn = false
    @State var present = false
//    init(pSelection: Int, pBaseIndex: Int, loc:String) {
//        model = PlayerViewModel(loc)
//        self.selection = pSelection
//        baseIndex = pBaseIndex
//    }
    
    var playerWidth = UIScreen.main.bounds.width
    var playerHeight = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {
            if present{
                PlayerContainerView(player: model.player, gravity: .aspectFit)
                    .frame(width: playerWidth, height: playerHeight)
                    .onTapGesture {
                        
                        volOn.toggle()
                        print("tapped - volOn = \(volOn)")
                        model.player.volume = volOn ? 1 : 0
                    }
            } else {
                Color.black
            }
        }
        .onChange(of: selection, perform: {sel in
                    print("selection changed --- \(sel) .|. \(baseIndex)")
            model.player.play()
            if selection == baseIndex {
                present = true
                model.play()
            } else {
                print("scrolled away")
                model.setToZero(model.player.currentItem)
                
                model.player.pause()
            }
            
        })
        .onAppear{
             
            present = true
            print("present = \(present)")
        }
        .onDisappear{
            
            present = false
            print("present = \(present)")
        }
        .ignoresSafeArea()
    }
}


