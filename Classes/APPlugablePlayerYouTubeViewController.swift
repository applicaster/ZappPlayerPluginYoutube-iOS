//
//  APPlugablePlayerYouTubeViewController.swift
//  Pods
//
//  Created by Liviu Romascanu on 16/09/2016.
//
//

import UIKit
import ApplicasterSDK
import youtube_ios_player_helper

class APPlugablePlayerYouTubeViewController: UIViewController, YTPlayerViewDelegate {
    
    var player: YTPlayerView?
    var playItem: ZPPlayable?
    
    // the default set to .landscape and you can change it to any value you need in the plugin configuration.
    public var allowedInterfaceOrientations : UIInterfaceOrientationMask = UIInterfaceOrientationMask.landscape
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.allowedInterfaceOrientations
    }
    
    // MARK: - Init
    @objc public convenience init() {
        self.init(nibName: nil, bundle: nil)
        self.player = YTPlayerView(frame: self.view.bounds)
        self.player?.delegate = self
        
        // YouTube Player doesnt handle PIP properly so disable it if in iOS 9
        if #available(iOS 9.0, *) {
            self.player?.webView?.allowsPictureInPictureMediaPlayback = false
        }
        self.addObservers()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: Bundle(for: type(of: self)))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Deallocate
    deinit {
        self.player?.stopVideo()
        self.player?.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.addSubview(self.player!)
        self.player?.matchParent()
    }
    
     // MARK: - YTPlayerDelegate
    public func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.player?.playVideo()
        ZAAppConnector.sharedInstance().analyticsDelegate?.trackEvent(name: "Play VOD Item",
                                                                      parameters: self.playItem?.analyticsParams() as? [String: Any],
                                                                      timed: true)
    }
    
    public func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState)
    {
        if state == YTPlayerState.ended {
            finishPlayback()
        }
    }
    
    public func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        finishPlayback()
    }
    
    // MARK: - Private
    func finishPlayback()
    {
        ZAAppConnector.sharedInstance().analyticsDelegate?.endTimedEvent("Play VOD Item",
                                                                         parameters: self.playItem?.analyticsParams() as? [String : Any])
        self.dismiss(animated: true, completion: nil)
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleWhenPlayingInFullScreen),
                                               name:UIWindow.didBecomeVisibleNotification,
                                               object: self.player?.window)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleWhenDoneButtonClick),
                                               name:UIWindow.didBecomeHiddenNotification,
                                               object: self.player?.window)
    }
    
    // MARK: - Observers
    @objc func handleWhenPlayingInFullScreen()
    {
        // video started playing, do nothing
    }
    
    @objc func handleWhenDoneButtonClick()
    {
        // Most likely done button clicked - Youtube hack - https://github.com/youtube/youtube-ios-player-helper/issues/149
        self.player?.stopVideo()
        finishPlayback()
    }
}
