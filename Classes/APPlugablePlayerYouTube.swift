//
//  APPlugablePlayerYouTube
//  APYoutePlayer-iOS
//
//  Created by Liviu Romascanu on 23/05/2016.
//  Copyright © 2016 Applicaster Ltd. All rights reserved.
//

import ZappPlugins
import ApplicasterSDK
import youtube_ios_player_helper

let youtubeIDKey = "youtube_id"

@objc(APPlugablePlayerYouTube)
public class APPlugablePlayerYouTube: APPlugablePlayerBase
{
    
    static let interfaceOrientationJsonValues: Dictionary<String, UIInterfaceOrientationMask> = [
        "Landscape" : .landscape,
        "Portrait" : .portrait,
        "All" : .all
    ]
    
    // MARK: - Properties
    var playerViewController: APPlugablePlayerYouTubeViewController?
    
    // MARK: - Deallocate
    deinit {
    }
    
    //--------------------------- ZPPlayerProtocol ---------------------------//
    
    
    
    public static func pluggablePlayerInit(playableItem item: ZPPlayable?) -> ZPPlayerProtocol? {
        if let item = item {
            return self.pluggablePlayerInit(playableItems: [item])
        }
        return nil
    }
    
    public static func pluggablePlayerInit(playableItems items: [ZPPlayable]?, configurationJSON: NSDictionary? = nil) -> ZPPlayerProtocol?{
        let instance = APPlugablePlayerYouTube()
        instance.playerViewController = APPlugablePlayerYouTubeViewController()
        
        if let configurationJSON = configurationJSON,
            let interfaceOrientationJsonValue = configurationJSON.object(forKey: "interface_orientation") as? String {
            if let interfaceOrientation = interfaceOrientationJsonValues[interfaceOrientationJsonValue] {
                instance.playerViewController?.allowedInterfaceOrientations = interfaceOrientation
            }
        }

        let playerVariables: [String : Any] = [
            "controls":1,
            "playsinline":0,
            "autohide":1,
            "showinfo":0,
            "modestbranding":1,
            "autoplay":1,
            //fix to copyright issue warning - https://github.com/youtube/youtube-ios-player-helper/issues/104
            "origin":"http://localhost"
        ]
        
        if let videoPath = items?.first?.contentVideoURLPath() {
            if items?.first?.isPlaylist == true{
                instance.playerViewController?.player?.load(withPlaylistId: videoPath, playerVars: playerVariables)
            }
            else{
                 instance.playerViewController?.player?.load(withVideoId: videoPath, playerVars: playerVariables)
            }
            instance.playerViewController?.playItem = items?.first
        }
        
        instance.currentPlayableItems = items
        return instance
    }
    
    public override func pluggablePlayerViewController() -> UIViewController? {
        return self.playerViewController
    }
    
    public override func pluggablePlayerType() -> ZPPlayerType {
        return APPlugablePlayerYouTube.pluggablePlayerType()
    }
    
    public static func pluggablePlayerType() -> ZPPlayerType {
        return .playerYoutube
    }
    
    //--------------------------- Available only in Full screen mode ---------------------------//
    
    public override func presentPlayerFullScreen(_ rootViewController: UIViewController, configuration: ZPPlayerConfiguration?) {
        let animated : Bool = configuration?.animated ?? true;
        
        let rootVC : UIViewController = rootViewController.topmostModal()
        //Present player
        rootVC.present(self.playerViewController!, animated:animated, completion: {
            self.playerViewController?.player?.playVideo()
        })
    }
    
    //--------------------------- Available only in Inline mode ---------------------------//
    
    public override func pluggablePlayerPlay(_ configuration: ZPPlayerConfiguration?) {
        self.playerViewController?.player?.playVideo()
    }
    
    public override func pluggablePlayerPause() {
        self.playerViewController?.player?.pauseVideo()
    }
    
    public override func pluggablePlayerStop() {
        self.playerViewController?.player?.stopVideo()
    }
    
    public override func pluggablePlayerIsPlaying() -> Bool {
        return (self.playerViewController?.player?.playbackRate() == 1.0)
    }
}
